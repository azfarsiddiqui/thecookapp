//
//  FacebookSuggestButtonView.m
//  FacebookStoreButtonDemo
//
//  Created by Jeff Tan-Ang on 8/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "FacebookSuggestButtonView.h"
#import "CKActivityIndicatorView.h"
#import "UIColor+Expanded.h"

@interface FacebookSuggestButtonView ()

@property (nonatomic, weak) id<FacebookSuggestButtonViewDelegate> delegate;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL disableText;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;

@end

@implementation FacebookSuggestButtonView

#define kSize           (CGSize) { 156.0, 219.0 }
#define kButtonTextGap  -7.0

- (id)initWithDelegate:(id<FacebookSuggestButtonViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = delegate;
        self.frame = (CGRect) { 0.0, 0.0, kSize.width, kSize.height };
        
        [self addSubview:self.facebookButton];
        [self addSubview:self.label];
        [self updateViews];
    }
    return self;
}

- (void)enableActivity:(BOOL)activity {
    self.userInteractionEnabled = !activity;
    if (activity) {
        [self.facebookButton setBackgroundImage:[self blankFacebookImage] forState:UIControlStateNormal];
        [self.facebookButton setBackgroundImage:[self blankFacebookImage] forState:UIControlStateHighlighted];
        
        // Spinner.
        self.activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        self.activityView.frame = (CGRect){
            floorf((self.facebookButton.bounds.size.width - self.activityView.frame.size.width) / 2.0) - 6.0,
            floorf((self.facebookButton.bounds.size.height - self.activityView.frame.size.height) / 2.0) + 2.0,
            self.activityView.frame.size.width,
            self.activityView.frame.size.height
        };
        [self.facebookButton addSubview:self.activityView];
        [self.activityView startAnimating];
        
    } else {
        
        [self.facebookButton setBackgroundImage:[self facebookImageSelected:NO] forState:UIControlStateNormal];
        [self.facebookButton setBackgroundImage:[self facebookImageSelected:YES] forState:UIControlStateHighlighted];
        
        // Stop the spinner.
        [self.activityView stopAnimating];
        [self.activityView removeFromSuperview];
        self.activityView = nil;
    }
}

- (void)showText:(BOOL)show {
    self.disableText = !show;
    [self updateViews];
}

#pragma mark - Properties

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        UIImage *facebookImage = [self facebookImageSelected:NO];
        _facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_facebookButton setBackgroundImage:facebookImage forState:UIControlStateNormal];
        [_facebookButton setBackgroundImage:[self facebookImageSelected:YES] forState:UIControlStateHighlighted];
        [_facebookButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_facebookButton setFrame:CGRectMake(0.0, 0.0, facebookImage.size.width, facebookImage.size.height)];
    }
    return _facebookButton;
}

- (UILabel *)label {
    if (!_label) {
        NSAttributedString *textDisplay = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"GET FACEBOOK%@SUGGESTIONS", @"\u2028"]
                                                                          attributes:[self labelTextAttributes]];
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.attributedText = textDisplay;
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = [_label sizeThatFits:self.bounds.size];
        _label.frame = CGRectIntegral(CGRectMake(0.0, 0.0, size.width, size.height));
    }
    return _label;
}

#pragma mark - Private methods

- (UIImage *)blankFacebookImage {
    return [UIImage imageNamed:@"cook_library_btn_facebook_blank.png"];
}

- (UIImage *)facebookImageSelected:(BOOL)selected {
    return selected ? [UIImage imageNamed:@"cook_library_btn_facebook_onpress.png"] : [UIImage imageNamed:@"cook_library_btn_facebook.png"];
}

- (void)buttonTapped:(id)sender {
    [self.delegate facebookSuggestButtonViewTapped];
}

- (NSDictionary *)labelTextAttributes {
    
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.paragraphSpacingBefore = -3;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0], NSFontAttributeName,
            [UIColor colorWithHexString:@"8e8e8d"], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

- (void)updateViews {
    // Facebook button and text.
    CGRect buttonFrame = self.facebookButton.frame;
    CGRect labelFrame = self.label.frame;
    
    // Reposition based on combined height, and if text is displayed.
    CGFloat requiredHeight = 0.0;
    if (self.disableText) {
        requiredHeight = buttonFrame.size.height;
    } else {
        requiredHeight = buttonFrame.size.height + kButtonTextGap + labelFrame.size.height;
    }
    
    buttonFrame.origin = (CGPoint) {
        floorf((self.bounds.size.width - buttonFrame.size.width) / 2.0) + 6.0,
        floorf((self.bounds.size.height - requiredHeight) / 2.0),
    };
    labelFrame.origin = (CGPoint) {
        floorf((self.bounds.size.width - labelFrame.size.width) / 2.0),
        buttonFrame.origin.y + buttonFrame.size.height + kButtonTextGap
    };
    self.facebookButton.frame = buttonFrame;
    self.label.frame = labelFrame;
    self.label.hidden = self.disableText;
}

@end
