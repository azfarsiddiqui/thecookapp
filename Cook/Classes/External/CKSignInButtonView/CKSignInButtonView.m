//
//  CKButtonView.m
//  CKButtonDemo
//
//  Created by Jeff Tan-Ang on 29/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKSignInButtonView.h"

@interface CKSignInButtonView ()

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL activity;
@property (nonatomic, assign) id<CKSignInButtonViewDelegate> delegate;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, assign) BOOL animating;

@end

@implementation CKSignInButtonView

- (id)initWithWidth:(CGFloat)width image:(UIImage *)image text:(NSString *)text activity:(BOOL)activity
           delegate:(id<CKSignInButtonViewDelegate>)delegate {

    return [self initWithSize:CGSizeMake(width, image.size.height) image:image text:text activity:activity
                     delegate:delegate];
}

- (id)initWithImage:(UIImage *)image text:(NSString *)text activity:(BOOL)activity
           delegate:(id<CKSignInButtonViewDelegate>)delegate {
    
    return [self initWithSize:image.size image:image text:text activity:activity delegate:delegate];
}

- (id)initWithSize:(CGSize)size image:(UIImage *)image text:(NSString *)text activity:(BOOL)activity
     delegate:(id<CKSignInButtonViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)]) {
        self.size = size;
        self.image = image;
        self.text = text;
        self.activity = activity;
        self.delegate = delegate;
 
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.button];
        [self setText:text activity:activity];
    }
    return self;
}

- (void)setText:(NSString *)text activity:(BOOL)activity {
    [self setText:text activity:activity animated:NO];
}

- (void)setText:(NSString *)text activity:(BOOL)activity animated:(BOOL)animated {
    [self setText:text activity:activity animated:animated enabled:YES];
}

- (void)setText:(NSString *)text activity:(BOOL)activity animated:(BOOL)animated enabled:(BOOL)enabled {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    self.button.userInteractionEnabled = NO;
    
    // Prep new label to be faded in.
    UILabel *label = [self labelWithText:text activity:activity];
    label.alpha = 0.0;
    label.hidden = NO;
    [self.button addSubview:label];
    
    // Prep activity to be faded in.
    if (!self.activity && activity) {
        self.activityView.alpha = 0.0;
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
        [self.button addSubview:self.activityView];
    }
    
    if (animated) {
        
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.textLabel.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:0.15
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  self.activityView.alpha = activity ? 1.0 : 0.0;
                                                  label.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                                  // Swap the labels.
                                                  [self.textLabel removeFromSuperview];
                                                  self.textLabel = label;
                                                  
                                                  if (!activity) {
                                                      [self.activityView stopAnimating];
                                                      [self.activityView removeFromSuperview];
                                                  }
                                                  
                                                  self.text = text;
                                                  self.activity = activity;
                                                  self.animating = NO;
                                                  self.button.userInteractionEnabled = enabled;
                                                  
                                                  [self holdLabel:!enabled];
                                              }];
                             
                         }];
        
    } else {
        self.textLabel.alpha = 0.0;
        self.activityView.alpha = activity ? 1.0 : 0.0;
        label.alpha = 1.0;
        
        // Swap the labels.
        [self.textLabel removeFromSuperview];
        self.textLabel = label;
        
        if (!activity) {
            [self.activityView stopAnimating];
            [self.activityView removeFromSuperview];
        }
        
        self.text = text;
        self.activity = activity;
        self.animating = NO;
        self.button.userInteractionEnabled = enabled;
        [self holdLabel:!enabled];
    }
    
}

#pragma mark - Properties

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setBackgroundImage:self.image forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter|UIControlEventTouchDragInside];
        [_button addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchDragOutside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        [_button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_button setFrame:self.bounds];
        _button.autoresizingMask = UIViewAutoresizingNone;
    }
    return _button;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.hidesWhenStopped = YES;
        _activityView.frame = CGRectMake(20.0,
                                         floorf((self.button.bounds.size.height - _activityView.frame.size.height) / 2.0) - 2.0,
                                         _activityView.frame.size.width,
                                         _activityView.frame.size.height);
    }
    return _activityView;
}

#pragma mark - Private methods

- (void)buttonTouchDown:(id)sender {
    [self holdLabel:YES];
}

- (void)buttonTouchUpOutside:(id)sender {
    [self holdLabel:NO];
}

- (void)buttonTapped:(id)sender {
    [self holdLabel:NO];
    [self.delegate signInTappedForButtonView:self];
}

- (UILabel *)labelWithText:(NSString *)text activity:(BOOL)activity {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:16];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    label.shadowOffset = CGSizeMake(0.0, 2.0);
    label.backgroundColor = [UIColor clearColor];

    // Update frame.
    label.text = text;
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = floorf((self.button.bounds.size.width - frame.size.width) / 2.0);
    frame.origin.y = floorf((self.button.bounds.size.height - frame.size.height) / 2.0) - 2.0;
    
    if (activity) {
//        CGFloat offset = self.activityView.frame.origin.x + self.activityView.frame.size.width + kActivityTextGap;
//        frame.origin.x = offset + floorf((self.button.bounds.size.width - offset - frame.size.width) / 2.0);
        frame.origin.x += 5.0;
    }
    
    label.frame = frame;
    
    return label;
}

- (void)holdLabel:(BOOL)hold {
    self.textLabel.alpha = hold ? 0.7 : 1.0;
}

@end
