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
#import "Theme.h"

@interface SignupViewController () <CKTextFieldViewDelegate>

@property (nonatomic, assign) id<SignupViewControllerDelegate> delegate;
@property (nonatomic, strong) UILabel *signupTitleLabel;
@property (nonatomic, strong) UILabel *signinTitleLabel;
@property (nonatomic, strong) UILabel *signupSubtitleLabel;
@property (nonatomic, strong) UIView *emailContainerView;
@property (nonatomic, strong) CKTextFieldView *emailNameView;
@property (nonatomic, strong) CKTextFieldView *emailAddressView;
@property (nonatomic, strong) CKTextFieldView *emailPasswordView;
@property (nonatomic, strong) UIView *emailNameDivider;
@property (nonatomic, strong) UIView *emailAddressDivider;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UILabel *emailSignUpLabel;
@property (nonatomic, strong) UILabel *emailSignInLabel;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UILabel *facebookSignUpLabel;
@property (nonatomic, strong) UILabel *facebookSignInLabel;
@property (nonatomic, strong) UIButton *signUpToggleButton;
@property (nonatomic, assign) BOOL signUpMode;
@property (nonatomic, assign) BOOL animating;

@end

@implementation SignupViewController

#define kEmailSignupSize    CGSizeMake(345.0, 257.0)
#define kEmailSignInSize    CGSizeMake(345.0, 207.0)
#define kTextFieldSize      CGSizeMake(300.0, 50.0)
#define kDividerInsets      UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)

- (id)initWithDelegate:(id<SignupViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    self.view.backgroundColor = [UIColor clearColor];
    self.signUpMode = YES;
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    [self initEmailContainerView];
    [self initHeaderView];
    [self initButtons];
    [self initFooterView];
    
    // Register for keyboard events.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)enableSignUpMode:(BOOL)signUp {
    [self enableSignUpMode:signUp animated:YES];
}

- (void)enableSignUpMode:(BOOL)signUp animated:(BOOL)animated {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    self.signUpMode = signUp;
    
    if (signUp) {
        self.emailNameView.alpha = 0.0;
        self.emailNameView.hidden = NO;
        self.signupSubtitleLabel.alpha = 0.0;
        self.signupSubtitleLabel.hidden = NO;
        self.emailSignUpLabel.alpha = 0.0;
        self.emailSignUpLabel.hidden = NO;
        self.facebookSignUpLabel.alpha = 0.0;
        self.facebookSignUpLabel.hidden = NO;
        self.emailNameDivider.alpha = 0.0;
        self.emailNameDivider.hidden = NO;
    } else {
        self.signinTitleLabel.alpha = 0.0;
        self.signinTitleLabel.hidden = NO;
        self.emailSignInLabel.alpha = 0.0;
        self.emailSignInLabel.hidden = NO;
        self.facebookSignInLabel.alpha = 0.0;
        self.facebookSignInLabel.hidden = NO;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.emailContainerView.frame = [self emailContainerFrameForSignUp:signUp];
                             self.signupTitleLabel.frame = [self signUpTitleFrameForSignUp:signUp];
                             self.signinTitleLabel.frame = [self signInTitleFrameForSignUp:signUp];
                             self.signupSubtitleLabel.frame = [self signupSubtitleFrameForSignUp:signUp];
                             self.facebookButton.frame = [self facebookFrameForSignUp:signUp];
                             
                             self.signupTitleLabel.alpha = signUp ? 1.0 : 0.0;
                             self.signinTitleLabel.alpha = signUp ? 0.0 : 1.0;
                             self.signupSubtitleLabel.alpha = signUp ? 1.0 : 0.0;
                             self.emailNameView.alpha = signUp ? 1.0 : 0.0;
                             self.emailNameDivider.alpha = signUp ? 1.0 : 0.0;
                             self.emailSignUpLabel.alpha = signUp ? 1.0 : 0.0;
                             self.emailSignInLabel.alpha = signUp ? 0.0 : 1.0;
                             self.facebookSignUpLabel.alpha = signUp ? 1.0 : 0.0;
                             self.facebookSignInLabel.alpha = signUp ? 0.0 : 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [self updateFooterButtonForSignUp:signUp];
                             
                             if (signUp) {
                                 self.signinTitleLabel.hidden = YES;
                                 self.emailSignInLabel.hidden = YES;
                                 self.facebookSignInLabel.hidden = YES;
                             } else {
                                 self.emailNameView.hidden = YES;
                                 self.emailSignUpLabel.hidden = YES;
                                 self.emailNameDivider.hidden = YES;
                                 self.facebookSignUpLabel.hidden = YES;
                                 self.signupSubtitleLabel.hidden = NO;
                             }
                             
                             self.animating = NO;
                             
                         }];
    } else {
         self.emailContainerView.frame = [self emailContainerFrameForSignUp:signUp];
         self.signupTitleLabel.frame = [self signUpTitleFrameForSignUp:signUp];
         self.signinTitleLabel.frame = [self signInTitleFrameForSignUp:signUp];
         self.signupSubtitleLabel.frame = [self signupSubtitleFrameForSignUp:signUp];
         self.facebookButton.frame = [self facebookFrameForSignUp:signUp];
         
         self.signupTitleLabel.alpha = signUp ? 1.0 : 0.0;
         self.signinTitleLabel.alpha = signUp ? 0.0 : 1.0;
         self.signupSubtitleLabel.alpha = signUp ? 1.0 : 0.0;
         self.emailNameView.alpha = signUp ? 1.0 : 0.0;
         self.emailSignUpLabel.alpha = signUp ? 1.0 : 0.0;
         self.emailSignInLabel.alpha = signUp ? 0.0 : 1.0;
         self.facebookSignUpLabel.alpha = signUp ? 1.0 : 0.0;
         self.facebookSignInLabel.alpha = signUp ? 0.0 : 1.0;
        
         [self updateFooterButtonForSignUp:signUp];
        
         if (signUp) {
             self.signinTitleLabel.hidden = YES;
             self.emailSignInLabel.hidden = YES;
             self.facebookSignInLabel.hidden = YES;
         } else {
             self.emailNameView.hidden = YES;
             self.emailSignUpLabel.hidden = YES;
             self.facebookSignUpLabel.hidden = YES;
             self.signupSubtitleLabel.hidden = NO;
         }
         
         self.animating = NO;
    }
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

- (UILabel *)signinTitleLabel {
    if (!_signinTitleLabel) {
        _signinTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _signinTitleLabel.backgroundColor = [UIColor clearColor];
        _signinTitleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:62];
        _signinTitleLabel.textColor = [UIColor whiteColor];
        _signinTitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _signinTitleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    }
    return _signinTitleLabel;
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
        _emailButton = [ViewHelper buttonWithImage:emailButtonImage target:self selector:@selector(emailButtonTapped:)];
        _emailButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _emailButton.frame = CGRectMake(floorf((self.emailContainerView.bounds.size.width - availableSize.width) / 2.0),
                                        self.emailContainerView.bounds.size.height - emailButtonImage.size.height - insets.bottom,
                                        availableSize.width,
                                        emailButtonImage.size.height);
    }
    return _emailButton;
}

- (UILabel *)emailSignUpLabel {
    if (!_emailSignUpLabel) {
        _emailSignUpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emailSignUpLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:16];
        _emailSignUpLabel.textColor = [UIColor whiteColor];
        _emailSignUpLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _emailSignUpLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _emailSignUpLabel.backgroundColor = [UIColor clearColor];
        _emailSignUpLabel.text = [self emailButtonTextForSignUp:YES];
        [_emailSignUpLabel sizeToFit];
        _emailSignUpLabel.frame = CGRectMake(floorf((self.emailButton.bounds.size.width - _emailSignUpLabel.frame.size.width) / 2.0),
                                             floorf((self.emailButton.bounds.size.height - _emailSignUpLabel.frame.size.height) / 2.0) - 2.0,
                                             _emailSignUpLabel.frame.size.width,
                                             _emailSignUpLabel.frame.size.height);
    }
    return _emailSignUpLabel;
}

- (UILabel *)emailSignInLabel {
    if (!_emailSignInLabel) {
        _emailSignInLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emailSignInLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:16];
        _emailSignInLabel.textColor = [UIColor whiteColor];
        _emailSignInLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _emailSignInLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _emailSignInLabel.backgroundColor = [UIColor clearColor];
        _emailSignInLabel.text = [self emailButtonTextForSignUp:NO];
        [_emailSignInLabel sizeToFit];
        _emailSignInLabel.frame = CGRectMake(floorf((self.emailButton.bounds.size.width - _emailSignInLabel.frame.size.width) / 2.0),
                                             floorf((self.emailButton.bounds.size.height - _emailSignInLabel.frame.size.height) / 2.0) - 2.0,
                                             _emailSignInLabel.frame.size.width,
                                             _emailSignInLabel.frame.size.height);
    }
    return _emailSignInLabel;
}

- (UILabel *)facebookSignUpLabel {
    if (!_facebookSignUpLabel) {
        _facebookSignUpLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _facebookSignUpLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:16];
        _facebookSignUpLabel.textColor = [UIColor whiteColor];
        _facebookSignUpLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _facebookSignUpLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _facebookSignUpLabel.backgroundColor = [UIColor clearColor];
        _facebookSignUpLabel.text = [self facebookButtonTextForSignUp:YES];
        [_facebookSignUpLabel sizeToFit];
        _facebookSignUpLabel.frame = CGRectMake(floorf((self.facebookButton.bounds.size.width - _facebookSignUpLabel.frame.size.width) / 2.0),
                                                floorf((self.facebookButton.bounds.size.height - _facebookSignUpLabel.frame.size.height) / 2.0) - 2.0,
                                                _facebookSignUpLabel.frame.size.width,
                                                _facebookSignUpLabel.frame.size.height);
    }
    return _facebookSignUpLabel;
}

- (UILabel *)facebookSignInLabel {
    if (!_facebookSignInLabel) {
        _facebookSignInLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _facebookSignInLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:16];
        _facebookSignInLabel.textColor = [UIColor whiteColor];
        _facebookSignInLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _facebookSignInLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _facebookSignInLabel.backgroundColor = [UIColor clearColor];
        _facebookSignInLabel.text = [self facebookButtonTextForSignUp:NO];
        [_facebookSignInLabel sizeToFit];
        _facebookSignInLabel.frame = CGRectMake(floorf((self.facebookButton.bounds.size.width - _facebookSignInLabel.frame.size.width) / 2.0),
                                                floorf((self.facebookButton.bounds.size.height - _facebookSignInLabel.frame.size.height) / 2.0) - 2.0,
                                                _facebookSignInLabel.frame.size.width,
                                                _facebookSignInLabel.frame.size.height);
    }
    return _facebookSignInLabel;
}

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(20.0, 20.0, 18.0, 20.0);
        CGSize availableSize = CGSizeMake(self.emailContainerView.bounds.size.width - insets.left - insets.right,
                                          self.emailContainerView.bounds.size.height - insets.top - insets.bottom);
        
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_facebook.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _facebookButton = [ViewHelper buttonWithImage:buttonImage target:self selector:@selector(facebookButtonTapped:)];
        _facebookButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _facebookButton.frame = CGRectMake(floorf((self.view.bounds.size.width - availableSize.width) / 2.0),
                                           self.emailContainerView.frame.origin.y + self.emailContainerView.bounds.size.height + 20.0,
                                           availableSize.width,
                                           buttonImage.size.height);
    }
    return _facebookButton;
}

- (UIButton *)signUpToggleButton {
    if (!_signUpToggleButton) {
        _signUpToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _signUpToggleButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:14];
        _signUpToggleButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _signUpToggleButton.userInteractionEnabled = YES;
        [_signUpToggleButton setTitleShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] forState:UIControlStateNormal];
        [_signUpToggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_signUpToggleButton setTitleColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5] forState:UIControlStateHighlighted];
        [_signUpToggleButton addTarget:self action:@selector(footerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signUpToggleButton;
}

- (UIView *)emailNameDivider {
    if (!_emailNameDivider) {
        _emailNameDivider = [[UIView alloc] initWithFrame:CGRectMake(self.emailContainerView.bounds.origin.x + kDividerInsets.left,
                                                                     kDividerInsets.top + self.emailNameView.frame.origin.y + self.emailNameView.frame.size.height,
                                                                     self.emailContainerView.bounds.size.width - kDividerInsets.left - kDividerInsets.right,
                                                                     1.0)];
        _emailNameDivider.backgroundColor = [Theme dividerRuleColour];
        _emailNameDivider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _emailNameDivider;
}

- (UIView *)emailAddressDivider {
    if (!_emailAddressDivider) {
        _emailAddressDivider = [[UIView alloc] initWithFrame:CGRectMake(self.emailContainerView.bounds.origin.x + kDividerInsets.left,
                                                                        kDividerInsets.top + self.emailAddressView.frame.origin.y + self.emailAddressView.frame.size.height,
                                                                        self.emailContainerView.bounds.size.width - kDividerInsets.left - kDividerInsets.right,
                                                                        1.0)];
        _emailAddressDivider.backgroundColor = [Theme dividerRuleColour];
        _emailAddressDivider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _emailAddressDivider;
}

#pragma mark - Keyboard events

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self handleKeyboardShow:YES keyboardFrame:keyboardFrame];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self handleKeyboardShow:NO keyboardFrame:keyboardFrame];
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
    [emailContainerView addSubview:self.emailNameDivider];
    
    // Email field anchor to the bottom.
    CKTextFieldView *emailAddressView = [[CKTextFieldView alloc] initWithFrame:CGRectMake(emailInsets.left,
                                                                                          emailNameView.frame.origin.y + emailNameView.frame.size.height,
                                                                                          availableSize.width,
                                                                                          kTextFieldSize.height)
                                                                   delegate:self placeholder:@"EMAIL ADDRESS"];
    emailAddressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailAddressView];
    self.emailAddressView = emailAddressView;
    [emailContainerView addSubview:self.emailAddressDivider];

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
    
    // Signup Title
    if (!self.signupTitleLabel.superview) {
        [self.view addSubview:self.signupTitleLabel];
    }
    self.signupTitleLabel.text = [self headerTitleForSignUp:self.signUpMode];
    [self.signupTitleLabel sizeToFit];
    self.signupTitleLabel.frame = [self signUpTitleFrameForSignUp:self.signUpMode];
    
    // Signup Subtitle
    if (!self.signupSubtitleLabel.superview) {
        [self.view addSubview:self.signupSubtitleLabel];
    }
    self.signupSubtitleLabel.text = [self headerSubtitleForSignUp:self.signUpMode];
    [self.signupSubtitleLabel sizeToFit];
    self.signupSubtitleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - self.signupSubtitleLabel.frame.size.width) / 2.0),
                                                self.signupTitleLabel.frame.origin.y + self.signupTitleLabel.frame.size.height - 20.0,
                                                self.signupSubtitleLabel.frame.size.width,
                                                self.signupSubtitleLabel.frame.size.height);
    
    // Signin Title
    if (!self.signinTitleLabel.superview) {
        [self.view addSubview:self.signinTitleLabel];
    }
    self.signinTitleLabel.text = [self headerTitleForSignUp:!self.signUpMode];
    [self.signinTitleLabel sizeToFit];
    self.signinTitleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - self.signinTitleLabel.frame.size.width) / 2.0),
                                             self.emailContainerView.frame.origin.y - self.signinTitleLabel.frame.size.height - 30.0,
                                             self.signinTitleLabel.frame.size.width,
                                             self.signinTitleLabel.frame.size.height);
    self.signinTitleLabel.hidden = YES;
}

- (void)initButtons {
    
    // Email button.
    [self.emailContainerView addSubview:self.emailButton];
    self.emailSignInLabel.hidden = YES;
    [self.emailButton addSubview:self.emailSignInLabel];
    [self.emailButton addSubview:self.emailSignUpLabel];
    
    // Facebook button.
    [self.view addSubview:self.facebookButton];
    self.facebookSignInLabel.hidden = YES;
    [self.facebookButton addSubview:self.facebookSignInLabel];
    [self.facebookButton addSubview:self.facebookSignUpLabel];
}

- (void)initFooterView {
    [self updateFooterButtonForSignUp:YES];
}

- (void)updateButtonsForSignUp:(BOOL)signUp {
    
}

- (void)updateFooterButtonForSignUp:(BOOL)signUp {
    if (!self.signUpToggleButton.superview) {
        [self.view addSubview:self.signUpToggleButton];
    }
    [self.signUpToggleButton setTitle:[self footerTextForSignUp:signUp] forState:UIControlStateNormal];
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

- (NSString *)emailButtonTextForSignUp:(BOOL)signUp {
    return signUp ? @"SIGN UP WITH EMAIL" : @"SIGN IN";
}

- (NSString *)facebookButtonTextForSignUp:(BOOL)signUp {
    return signUp ? @"SIGNUP WITH FACEBOOK" : @"SIGNIN WITH FACEBOOK";
}

- (CGRect)emailContainerFrameForSignUp:(BOOL)signUp {
    CGSize size = signUp ? kEmailSignupSize : kEmailSignInSize;
    return CGRectMake(floorf((self.view.bounds.size.width - size.width) / 2.0),
                      floorf((self.view.bounds.size.height - size.height) / 2.0),
                      size.width,
                      size.height);
}

- (CGRect)signUpTitleFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.view.bounds.size.width - self.signupTitleLabel.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y - self.signupTitleLabel.frame.size.height - 20.0,
                      self.signupTitleLabel.frame.size.width,
                      self.signupTitleLabel.frame.size.height);
}

- (CGRect)signInTitleFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.view.bounds.size.width - self.signinTitleLabel.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y - self.signinTitleLabel.frame.size.height + 5.0,
                      self.signinTitleLabel.frame.size.width,
                      self.signinTitleLabel.frame.size.height);
}

- (CGRect)facebookFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.view.bounds.size.width - self.facebookButton.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y + self.emailContainerView.bounds.size.height + 20.0,
                      self.facebookButton.frame.size.width,
                      self.facebookButton.frame.size.height);
}

- (CGRect)signupSubtitleFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.view.bounds.size.width - self.signupSubtitleLabel.frame.size.width) / 2.0),
                      self.signupTitleLabel.frame.origin.y + self.signupTitleLabel.frame.size.height - 20.0,
                      self.signupSubtitleLabel.frame.size.width,
                      self.signupSubtitleLabel.frame.size.height);
}

- (void)handleKeyboardShow:(BOOL)show keyboardFrame:(CGRect)keyboardFrame {
    
    // Inform delegate that focus is obtained/lost.
    [self.delegate signupViewControllerFocused:show];
    
    // Convert keyboard frame to currentView to handle rotated interface.
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    CGFloat yOffset = self.signUpMode ? 70.0 : 55.0;
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0.0, -floorf(keyboardFrame.origin.y / 2.0) + yOffset);
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.facebookButton.alpha = show ? 0.0 : 1.0;
                         self.view.transform = show ? translateTransform : CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
