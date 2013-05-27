//
//  SignupViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "SignupViewController.h"
#import "AppHelper.h"
#import "CKTextFieldView.h"
#import "ViewHelper.h"

@interface SignupViewController () <CKTextFieldViewDelegate>

@property (nonatomic, strong) UILabel *signupTitleLabel;
@property (nonatomic, strong) UILabel *signupSubtitleLabel;
@property (nonatomic, strong) UIView *emailContainerView;
@property (nonatomic, strong) CKTextFieldView *emailNameView;
@property (nonatomic, strong) CKTextFieldView *emailAddressView;
@property (nonatomic, strong) CKTextFieldView *emailPasswordView;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *signUpToggleButton;
@property (nonatomic, assign) BOOL signUpMode;

@end

@implementation SignupViewController

#define kEmailSignupSize    CGSizeMake(345.0, 257.0)
#define kEmailSignInSize    CGSizeMake(345.0, 207.0)
#define kTextFieldSize      CGSizeMake(300.0, 50.0)
#define kButtonTextFont     [UIFont fontWithName:@"BrandonGrotesque-Bold" size:16]
#define kButtonTextColour   [UIColor whiteColor]
#define kFooterTextFont     [UIFont fontWithName:@"BrandonGrotesque-Bold" size:14]

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    self.view.backgroundColor = [UIColor clearColor];
    self.signUpMode = YES;
    
    [self initEmailContainerView];
    [self initHeaderView];
    [self initButtons];
    [self initFooterView];
}

#pragma mark - CKTextFieldViewDelegate methods

- (void)textFieldViewDidSubmit:(CKTextFieldView *)textFieldView {
    
}

- (BOOL)textFieldViewShouldSubmit:(CKTextFieldView *)textFieldView {
    return YES;
}

#pragma mark - Properties

- (UILabel *)signupTitleLabel {
    if (!_signupTitleLabel) {
        _signupTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _signupTitleLabel.backgroundColor = [UIColor clearColor];
        _signupTitleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:62];
        _signupTitleLabel.textColor = [UIColor whiteColor];
        _signupTitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _signupTitleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    }
    return _signupTitleLabel;
}

- (UILabel *)signupSubtitleLabel {
    if (!_signupSubtitleLabel) {
        _signupSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _signupSubtitleLabel.backgroundColor = [UIColor clearColor];
        _signupSubtitleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:26];
        _signupSubtitleLabel.textColor = [UIColor whiteColor];
        _signupSubtitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _signupSubtitleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    }
    return _signupSubtitleLabel;
}

- (UIButton *)emailButton {
    if (!_emailButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(20.0, 20.0, 18.0, 20.0);
        CGSize availableSize = CGSizeMake(self.emailContainerView.bounds.size.width - insets.left - insets.right,
                                          self.emailContainerView.bounds.size.height - insets.top - insets.bottom);
        
        UIImage *emailButtonImage = [[UIImage imageNamed:@"cook_login_btn_signup.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _emailButton = [ViewHelper buttonWithTitle:[self emailButtonTextFor:YES] backgroundImage:emailButtonImage
                                              size:CGSizeMake(availableSize.width, emailButtonImage.size.height)
                                            target:self selector:@selector(emailButtonTapped:)];
        _emailButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 3.0, 0.0);
        _emailButton.titleLabel.font = kButtonTextFont;
        _emailButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [_emailButton setTitleColor:kButtonTextColour forState:UIControlStateNormal];
        _emailButton.frame = CGRectMake(floorf((self.emailContainerView.bounds.size.width - _emailButton.frame.size.width) / 2.0),
                                        self.emailContainerView.bounds.size.height - _emailButton.frame.size.height - insets.bottom,
                                        _emailButton.frame.size.width,
                                        _emailButton.frame.size.height);
    }
    return _emailButton;
}

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(20.0, 20.0, 18.0, 20.0);
        CGSize availableSize = CGSizeMake(self.emailContainerView.bounds.size.width - insets.left - insets.right,
                                          self.emailContainerView.bounds.size.height - insets.top - insets.bottom);
        
        UIImage *emailButtonImage = [[UIImage imageNamed:@"cook_login_btn_facebook.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _facebookButton = [ViewHelper buttonWithTitle:[self facebookButtonTextFor:YES] backgroundImage:emailButtonImage
                                              size:CGSizeMake(availableSize.width, emailButtonImage.size.height)
                                            target:self selector:@selector(facebookButtonTapped:)];
        _facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 3.0, 0.0);
        _facebookButton.titleLabel.font = kButtonTextFont;
        [_facebookButton setTitleColor:kButtonTextColour forState:UIControlStateNormal];
        _facebookButton.frame = CGRectMake(floorf((self.view.bounds.size.width - _facebookButton.frame.size.width) / 2.0),
                                           self.emailContainerView.frame.origin.y + self.emailContainerView.bounds.size.height + 20.0,
                                           _facebookButton.frame.size.width,
                                           _facebookButton.frame.size.height);
    }
    return _facebookButton;
}

- (UIButton *)signUpToggleButton {
    if (!_signUpToggleButton) {
        _signUpToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _signUpToggleButton.titleLabel.font = kFooterTextFont;
        _signUpToggleButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _signUpToggleButton.userInteractionEnabled = YES;
        [_signUpToggleButton setTitleShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] forState:UIControlStateNormal];
        [_signUpToggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signUpToggleButton setTitleColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5] forState:UIControlStateHighlighted];
        [_signUpToggleButton addTarget:self action:@selector(footerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signUpToggleButton;
}

#pragma mark - Private methods

- (void)initEmailContainerView {
    UIEdgeInsets emailInsets = UIEdgeInsetsMake(20.0, 20.0, 18.0, 20.0);
    
    UIImage *emailBoxImage = [[UIImage imageNamed:@"cook_login_bg_whitepanel.png"]
                              resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 12.0, 14.0, 12.0)];
    UIView *emailContainerView = [[UIImageView alloc] initWithImage:emailBoxImage];
    emailContainerView.frame = CGRectMake(floorf((self.view.bounds.size.width - kEmailSignupSize.width) / 2.0),
                                           floorf((self.view.bounds.size.height - kEmailSignupSize.height) / 2.0),
                                           kEmailSignupSize.width,
                                           kEmailSignupSize.height);
    emailContainerView.userInteractionEnabled = YES;
    emailContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:emailContainerView];
    self.emailContainerView = emailContainerView;
    
    CGSize availableSize = CGSizeMake(emailContainerView.bounds.size.width - emailInsets.left - emailInsets.right,
                                      emailContainerView.bounds.size.height - emailInsets.top - emailInsets.bottom);
    
    // Name field anchor to the top.
    CKTextFieldView *emailNameView = [[CKTextFieldView alloc] initWithFrame:CGRectMake(emailInsets.left,
                                                                                       emailInsets.top,
                                                                                       availableSize.width,
                                                                                       kTextFieldSize.height)
                                                                   delegate:self placeholder:@"YOUR NAME"];
    emailNameView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailNameView];
    self.emailNameView = emailNameView;
    
    // Email field anchor to the bottom.
    CKTextFieldView *emailAddressView = [[CKTextFieldView alloc] initWithFrame:CGRectMake(emailInsets.left,
                                                                                          emailNameView.frame.origin.y + emailNameView.frame.size.height,
                                                                                          availableSize.width,
                                                                                          kTextFieldSize.height)
                                                                   delegate:self placeholder:@"EMAIL ADDRESS"];
    emailAddressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailAddressView];
    self.emailAddressView = emailAddressView;

    // Password field anchor to the bottom.
    CKTextFieldView *emailPasswordView = [[CKTextFieldView alloc] initWithFrame:CGRectMake(emailInsets.left,
                                                                                           emailAddressView.frame.origin.y + emailAddressView.frame.size.height,
                                                                                           availableSize.width,
                                                                                           kTextFieldSize.height)
                                                                      delegate:self placeholder:@"PASSWORD" password:YES];
    emailPasswordView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailPasswordView];
    self.emailPasswordView = emailPasswordView;
}

- (void)emailButtonTapped:(id)sender {
    DLog();
}

- (void)facebookButtonTapped:(id)sender {
    DLog();
}

- (void)initHeaderView {
    [self updateHeaderForSignUp:YES];
}

- (void)initButtons {
    [self updateButtonsForSignUp:YES];
}

- (void)initFooterView {
    [self updateFooterButtonForSignUp:YES];
}

- (void)updateHeaderForSignUp:(BOOL)signUp {
    
    // Title
    if (!self.signupTitleLabel.superview) {
        [self.view addSubview:self.signupTitleLabel];
    }
    self.signupTitleLabel.text = [self headerTitleForSignUp:signUp];
    [self.signupTitleLabel sizeToFit];
    self.signupTitleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - self.signupTitleLabel.frame.size.width) / 2.0),
                                             self.emailContainerView.frame.origin.y - self.signupTitleLabel.frame.size.height - 30.0,
                                             self.signupTitleLabel.frame.size.width,
                                             self.signupTitleLabel.frame.size.height);
    
    // Subtitle
    if (!self.signupSubtitleLabel.superview) {
        [self.view addSubview:self.signupSubtitleLabel];
    }
    self.signupSubtitleLabel.text = [self headerSubtitleForSignUp:signUp];
    [self.signupSubtitleLabel sizeToFit];
    self.signupSubtitleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - self.signupSubtitleLabel.frame.size.width) / 2.0),
                                                self.signupTitleLabel.frame.origin.y + self.signupTitleLabel.frame.size.height - 20.0,
                                                self.signupSubtitleLabel.frame.size.width,
                                                self.signupSubtitleLabel.frame.size.height);
}

- (void)updateButtonsForSignUp:(BOOL)signUp {
    
    // Email button.
    if (!self.emailButton.superview) {
        [self.emailContainerView addSubview:self.emailButton];
    }
    [self.emailButton setTitle:[self emailButtonTextFor:signUp] forState:UIControlStateNormal];
    
    // Facebook button.
    if (!self.facebookButton.superview) {
        [self.view addSubview:self.facebookButton];
    }
    [self.facebookButton setTitle:[self facebookButtonTextFor:signUp] forState:UIControlStateNormal];
}

- (void)updateFooterButtonForSignUp:(BOOL)signUp {
    if (!self.signUpToggleButton.superview) {
        [self.view addSubview:self.signUpToggleButton];
    }
    [self.signUpToggleButton setTitle:[self footerTextForSignUp:YES] forState:UIControlStateNormal];
    [self.signUpToggleButton sizeToFit];
    self.signUpToggleButton.frame = CGRectMake(floorf((self.view.bounds.size.width - self.signUpToggleButton.frame.size.width) / 2.0),
                                        self.view.bounds.size.height - self.signUpToggleButton.frame.size.height - 20.0,
                                        self.signUpToggleButton.frame.size.width,
                                        self.signUpToggleButton.frame.size.height);
}

- (void)footerButtonTapped:(id)sender {
    [self enableSignUpMode:!self.signUpMode];
}

- (NSString *)headerTitleForSignUp:(BOOL)signUp {
    return signUp ? @"GET STARTED" : @"SIGN IN";
}

- (NSString *)headerSubtitleForSignUp:(BOOL)signUp {
    return signUp ? @"Just choose a way to signup below..." : @"";
}

- (NSString *)footerTextForSignUp:(BOOL)signUp {
    return signUp ? @"ALREADY HAVE AN ACCOUNT? SIGN IN" : @"DON'T HAVE AN ACCOUNT? SIGN UP!";
}

- (NSString *)emailButtonTextFor:(BOOL)signUp {
    return signUp ? @"SIGN UP WITH EMAIL" : @"SIGN IN";
}

- (NSString *)facebookButtonTextFor:(BOOL)signUp {
    return signUp ? @"SIGNUP WITH FACEBOOK" : @"SIGNIN WITH FACEBOOK";
}

- (void)enableSignUpMode:(BOOL)signUp {
    DLog(@"signUp: %@", signUp ? @"YES" : @"NO");
    self.signUpMode = signUp;
    
    if (signUp) {
        self.emailNameView.alpha = 0.0;
        self.emailNameView.hidden = NO;
        self.signupSubtitleLabel.alpha = 0.0;
        self.signupSubtitleLabel.hidden = NO;
    }
    
    // [self updateHeaderForSignUp:signUp];
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.emailContainerView.frame = [self emailContainerFrameForSignUp:signUp];
                         self.signupTitleLabel.frame = [self titleFrameForSignUp:signUp];
                         self.emailNameView.alpha = signUp ? 1.0 : 0.0;
                         self.signupSubtitleLabel.alpha = signUp ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         if (signUp) {
                             
                         } else {
                             self.emailNameView.hidden = YES;
                             self.signupSubtitleLabel.hidden = NO;
                         }
                         
                     }];
}

- (CGRect)emailContainerFrameForSignUp:(BOOL)signUp {
    CGSize size = signUp ? kEmailSignupSize : kEmailSignInSize;
    return CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                      floorf((self.view.bounds.size.height - size.height) / 2.0),
                      size.width,
                      size.height);
}

- (CGRect)titleFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.view.bounds.size.width - self.signupTitleLabel.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y - self.signupTitleLabel.frame.size.height - 30.0,
                      self.signupTitleLabel.frame.size.width,
                      self.signupTitleLabel.frame.size.height);
}

@end
