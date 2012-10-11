//
//  CKLoginView.m
//  CKFacebookLoginButton
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKLoginView.h"

@interface CKLoginView ()

@property (nonatomic, assign) id<CKLoginViewDelegate> delegate;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation CKLoginView

#define kLoginIconSize  CGSizeMake(35.0, 35.0)
#define kTextFont       [UIFont boldSystemFontOfSize:11.0];

- (id)initWithDelegate:(id<CKLoginViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
        [self initLoginView];
    }
    return self;
}

- (void)loginStarted {
    [self setButtonText:[self facebookLoginStartedText] activity:YES icon:nil enabled:NO];
}

- (void)loginDone {
    [self setButtonText:[self facebookLoginDoneText] activity:NO icon:[self tickIconImage] enabled:NO];
    // [self performSelector:@selector(loginReset) withObject:nil afterDelay:1.0];
}

- (void)loginReset {
    [self setButtonText:[self facebookLoginText] activity:NO icon:[self facebookIconImage] enabled:YES];
}

#pragma mark - Private

- (void)initLoginView {
    UIImage *loginImage = [UIImage imageNamed:@"cook_signin_btn.png"];
    self.frame = CGRectMake(0.0, 0.0, loginImage.size.width, loginImage.size.height);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:loginImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, loginImage.size.width, loginImage.size.height)];
    button.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:button];
    self.loginButton = button;
    
    [self loginReset];
}

- (void)setButtonText:(NSString *)text activity:(BOOL)activity icon:(UIImage *)icon enabled:(BOOL)enabled {
    
    // Icon
    [self.iconImageView removeFromSuperview];
    if (icon) {
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:icon];
        iconImageView.frame = CGRectMake(ceilf((kLoginIconSize.width - iconImageView.frame.size.width) / 2),
                                         ceilf((kLoginIconSize.height - iconImageView.frame.size.height) / 2) - 1.0,
                                         iconImageView.frame.size.width,
                                         iconImageView.frame.size.height);
        [self addSubview:iconImageView];
        self.iconImageView = iconImageView;
    }
    
    // Spinner on button.
    if (activity) {
        if (!self.activityView) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityView.frame = CGRectMake(ceilf((kLoginIconSize.width - activityView.frame.size.width) / 2),
                                            ceilf((kLoginIconSize.height - activityView.frame.size.height) / 2) - 1.0,
                                            activityView.frame.size.width,
                                            activityView.frame.size.height);
            [activityView startAnimating];
            [self addSubview:activityView];
            self.activityView = activityView;
        } else {
            [self.activityView startAnimating];
        }
        
    } else {
        [self.activityView stopAnimating];
        [self.activityView removeFromSuperview];
        self.activityView = nil;
    }
    
    // Button text.
    [self.textLabel removeFromSuperview];
    UIFont *buttonFont = kTextFont;
    CGSize textSize = [text sizeWithFont:buttonFont constrainedToSize:self.bounds.size
                           lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(floorf((self.bounds.size.width - kLoginIconSize.width - textSize.width) / 2) + kLoginIconSize.width - 1.0,
                                                                   floorf((self.bounds.size.height - textSize.height) / 2),
                                                                   textSize.width,
                                                                   textSize.height)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.shadowColor = [UIColor blackColor];
    textLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    textLabel.text = text;
    textLabel.font = buttonFont;
    [self addSubview:textLabel];
    self.textLabel = textLabel;
    
    // Enabled?
    self.loginButton.userInteractionEnabled = enabled;
}

- (void)loginTapped {
    if ([self.activityView isAnimating]) {
        return;
    }
    return [self.delegate loginViewTapped];
}

- (UIImage *)facebookIconImage {
    return [UIImage imageNamed:@"cook_btn_dark_facebook_icon.png"];
}

- (UIImage *)tickIconImage {
    return [UIImage imageNamed:@"cook_btn_dark_facebook_tick.png"];
}

- (NSString *)facebookLoginText {
    return @"LOGIN WITH FACEBOOK";
}

- (NSString *)facebookLoginStartedText {
    return @"LOGIN WITH FACEBOOK";
}

- (NSString *)facebookLoginDoneText {
    return @"LOGIN WITH FACEBOOK";
}

@end
