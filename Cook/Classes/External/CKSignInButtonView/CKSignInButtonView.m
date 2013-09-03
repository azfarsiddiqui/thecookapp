//
//  CKButtonView.m
//  CKButtonDemo
//
//  Created by Jeff Tan-Ang on 29/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKSignInButtonView.h"
#import "Theme.h"
#import "ViewHelper.h"
#import "CKActivityIndicatorView.h"

@interface CKSignInButtonView ()

@property (nonatomic, assign) CGSize size;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL activity;
@property (nonatomic, assign) id<CKSignInButtonViewDelegate> delegate;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, assign) BOOL animating;

@end

@implementation CKSignInButtonView

#define kIconOffset 20.0

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                                  object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification
                                                  object:[UIApplication sharedApplication]];
}

- (id)initWithWidth:(CGFloat)width text:(NSString *)text activity:(BOOL)activity
           delegate:(id<CKSignInButtonViewDelegate>)delegate {

    return [self initWithSize:CGSizeMake(width, [self normalBackgroundImage].size.height) text:text activity:activity
                     delegate:delegate];
}

- (id)initWithSize:(CGSize)size text:(NSString *)text activity:(BOOL)activity
          delegate:(id<CKSignInButtonViewDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)]) {
        self.size = size;
        self.text = text;
        self.activity = activity;
        self.delegate = delegate;
 
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.button];
        [self setText:text activity:activity];
        
        // Register for notification that app did enter background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pauseActivityIfRequired)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        // Register for notification that app did enter foreground
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeActivityIfRequired)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
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
    [self setText:text done:NO activity:activity animated:animated enabled:enabled];
}

- (void)setText:(NSString *)text done:(BOOL)done activity:(BOOL)activity animated:(BOOL)animated enabled:(BOOL)enabled {
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
    
    // Icon.
    if (!activity && !self.iconImageView.superview) {
        [self.button addSubview:self.iconImageView];
    }
    
    UIImage *iconImage = done ? [self doneIconImage] : [self iconImage];
    self.iconImageView.image = iconImage;
    self.iconImageView.frame = (CGRect) {
        kIconOffset,
        floorf((self.button.bounds.size.height - iconImage.size.height) / 2.0),
        iconImage.size.width,
        iconImage.size.height
    };
    
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
                                                  self.iconImageView.alpha = activity ? 0.0 : 1.0;
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
        self.iconImageView.alpha = activity ? 0.0 : 1.0;
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

- (UIFont *)textLabelFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:15];
}

- (UIColor *)textLabelColour {
    return [UIColor colorWithHexString:@"333333"];
}

- (UIImage *)normalBackgroundImage {
    return [[UIImage imageNamed:@"cook_login_btn_signup_white.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
}

- (UIImage *)onPressBackgroundImage {
    return [[UIImage imageNamed:@"cook_login_btn_signup_white_onpress.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
}

- (UIImage *)iconImage {
    return nil;
}

- (UIImage *)doneIconImage {
    return [UIImage imageNamed:@"cook_login_icon_tick_dark.png"];
}

- (CKActivityIndicatorViewStyle)activityViewStyle {
    return CKActivityIndicatorViewStyleTinyDark;
}

#pragma mark - Properties

- (UIButton *)button {
    if (!_button) {
        _button = [ViewHelper buttonWithImage:[self normalBackgroundImage] selectedImage:[self onPressBackgroundImage]
                                       target:self selector:@selector(buttonTapped:)];
        [_button setFrame:self.bounds];
        _button.autoresizingMask = UIViewAutoresizingNone;
    }
    return _button;
}

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:[self activityViewStyle]];
        _activityView.hidesWhenStopped = YES;
        _activityView.frame = CGRectMake(20.0,
                                         floorf((self.button.bounds.size.height - _activityView.frame.size.height) / 2.0),
                                         _activityView.frame.size.width,
                                         _activityView.frame.size.height);
    }
    return _activityView;
}

- (UIImageView *)iconImageView {
    UIImage *iconImage = [self iconImage];
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        _iconImageView.frame = CGRectMake(kIconOffset,
                                         floorf((self.button.bounds.size.height - _iconImageView.frame.size.height) / 2.0),
                                         _iconImageView.frame.size.width,
                                         _iconImageView.frame.size.height);
    }
    return _iconImageView;
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
    label.font = [self textLabelFont];
    label.textColor = [self textLabelColour];
    label.backgroundColor = [UIColor clearColor];

    // Update frame.
    label.text = text;
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = floorf((self.button.bounds.size.width - frame.size.width) / 2.0);
    frame.origin.y = floorf((self.button.bounds.size.height - frame.size.height) / 2.0) + 2.0;
    
    if (activity) {
        frame.origin.x += 5.0;
    } else if (self.iconImageView.image) {
        frame.origin.x += 10.0;
    }
    
    label.frame = frame;
    
    return label;
}

- (void)holdLabel:(BOOL)hold {
    self.textLabel.alpha = hold ? 0.7 : 1.0;
}

- (void)pauseActivityIfRequired {
    if (self.activityView.superview) {
        [self.activityView stopAnimating];
    }
}

- (void)resumeActivityIfRequired {
    if (self.activityView.superview) {
        [self.activityView startAnimating];
    }
}

@end
