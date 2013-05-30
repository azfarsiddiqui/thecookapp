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
#import "CKTextFieldViewHelper.h"
#import "ViewHelper.h"
#import "Theme.h"
#import "CKSignInButtonView.h"
#import "CKUser.h"
#import "EventHelper.h"

@interface SignupViewController () <CKTextFieldViewDelegate, CKSignInButtonViewDelegate>

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
@property (nonatomic, strong) CKSignInButtonView *emailButton;
@property (nonatomic, strong) CKSignInButtonView *facebookButton;
@property (nonatomic, strong) UIButton *signUpToggleButton;
@property (nonatomic, assign) BOOL signUpMode;
@property (nonatomic, assign) BOOL animating;

@end

@implementation SignupViewController

#define kEmailSignupSize    CGSizeMake(345.0, 270.0)
#define kEmailSignInSize    CGSizeMake(345.0, 220.0)
#define kTextFieldSize      CGSizeMake(300.0, 50.0)
#define kDividerInsets      UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
#define kPasswordMinLength  6
#define kPasswordMaxLength  32

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
    
    // Mark as sign up mode.
    self.signUpMode = signUp;
    
    if (signUp) {
        self.emailNameView.alpha = 0.0;
        self.emailNameView.hidden = NO;
        self.signupSubtitleLabel.alpha = 0.0;
        self.signupSubtitleLabel.hidden = NO;
        self.emailNameDivider.alpha = 0.0;
        self.emailNameDivider.hidden = NO;
    } else {
        self.signinTitleLabel.alpha = 0.0;
        self.signinTitleLabel.hidden = NO;
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
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Update signup/signin buttons.
                             [self.emailButton setText:[self emailButtonTextForSignUp:signUp] activity:NO animated:NO];
                             [self.facebookButton setText:[self facebookButtonTextForSignUp:signUp] activity:NO animated:NO];
                             
                             // Update footer text.
                             [self updateFooterButtonForSignUp:signUp];
                             
                             if (signUp) {
                                 self.signinTitleLabel.hidden = YES;
                             } else {
                                 self.emailNameView.hidden = YES;
                                 self.emailNameDivider.hidden = YES;
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
        
         [self updateFooterButtonForSignUp:signUp];
        
         if (signUp) {
             self.signinTitleLabel.hidden = YES;
         } else {
             self.emailNameView.hidden = YES;
             self.signupSubtitleLabel.hidden = NO;
         }
         
         self.animating = NO;
    }
}

#pragma mark - CKTextFieldViewDelegate methods

- (NSString *)progressTextForTextFieldView:(CKTextFieldView *)textFieldView currentText:(NSString *)text {
    NSString *progressText = nil;
    if (textFieldView == self.emailNameView) {
        progressText = [CKTextFieldViewHelper progressTextForNameWithString:text];
    } else if (textFieldView == self.emailAddressView) {
        progressText = [CKTextFieldViewHelper progressTextForEmailWithString:text];
    } else if (textFieldView == self.emailPasswordView) {
        progressText = [CKTextFieldViewHelper progressPasswordForNameWithString:text min:kPasswordMinLength max:kPasswordMaxLength];
    }
    return progressText;
}

- (void)didReturnForTextFieldView:(CKTextFieldView *)textFieldView {
    NSLog(@"textFieldViewDidReturn:");
    
    NSString *text = [textFieldView inputText];
    
    if (textFieldView == self.emailNameView) {
        
        BOOL validated = [text length] > 0;
        if (validated) {
            [self.emailNameView setValidated:YES message:@"THANKS"];
        }

        [self.emailAddressView focusTextFieldView:YES];

    } else if (textFieldView == self.emailAddressView) {
        
        BOOL validated = [CKTextFieldViewHelper isValidEmailForString:text];
        if (validated) {
            [self.emailAddressView setValidated:YES message:@"THANKS"];
        } else {
            [self.emailAddressView setValidated:NO message:@"INVALID EMAIL"];
        }
        
        [self.emailPasswordView focusTextFieldView:YES];
        
    } else if (textFieldView == self.emailPasswordView) {
        
        BOOL validated = [CKTextFieldViewHelper isValidLengthForString:text min:kPasswordMinLength max:kPasswordMaxLength];
        if (validated) {
            [self.emailPasswordView setValidated:YES message:@"THANKS"];
        } else {
            [self.emailPasswordView setValidated:NO message:@"INVALID PASSWORD"];
        }
        
        [self.emailPasswordView focusTextFieldView:NO];
    }
    
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

- (CKSignInButtonView *)emailButton {
    if (!_emailButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(20.0, 20.0, 18.0, 20.0);
        CGSize availableSize = CGSizeMake(self.emailContainerView.bounds.size.width - insets.left - insets.right,
                                          self.emailContainerView.bounds.size.height - insets.top - insets.bottom);
        
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_signup.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _emailButton = [[CKSignInButtonView alloc] initWithWidth:availableSize.width image:buttonImage
                                                            text:[self emailButtonTextForSignUp:YES] activity:NO delegate:self];
        _emailButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        _emailButton.frame = CGRectMake(floorf((self.emailContainerView.bounds.size.width - _emailButton.frame.size.width) / 2.0),
                                        self.emailContainerView.bounds.size.height - _emailButton.frame.size.height - insets.bottom,
                                        _emailButton.frame.size.width,
                                        _emailButton.frame.size.height);
    }
    return _emailButton;
}

- (CKSignInButtonView *)facebookButton {
    if (!_facebookButton) {
        UIEdgeInsets insets = UIEdgeInsetsMake(20.0, 20.0, 18.0, 20.0);
        CGSize availableSize = CGSizeMake(self.emailContainerView.bounds.size.width - insets.left - insets.right,
                                          self.emailContainerView.bounds.size.height - insets.top - insets.bottom);
        
        UIImage *buttonImage = [[UIImage imageNamed:@"cook_login_btn_facebook.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 25.0, 0.0, 25.0)];
        _facebookButton = [[CKSignInButtonView alloc] initWithWidth:availableSize.width image:buttonImage
                                                               text:[self facebookButtonTextForSignUp:YES] activity:NO delegate:self];
        _facebookButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
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

#pragma mark - CKSignInButtonViewDelegate methods

- (void)signInTappedForButtonView:(CKSignInButtonView *)buttonView {
    DLog();
    
    if (buttonView == self.facebookButton) {
        [self facebookButtonTapped];
    } else if (buttonView == self.emailButton) {
        [self emailButtonTapped];
    }
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
    CKTextFieldView *emailNameView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self placeholder:@"YOUR NAME"];
    emailNameView.frame = (CGRect){
        emailInsets.left,
        emailInsets.top,
        emailNameView.frame.size.width,
        emailNameView.frame.size.height
    };
    emailNameView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailNameView];
    self.emailNameView = emailNameView;
    [emailContainerView addSubview:self.emailNameDivider];
    
    // Email field anchor to the bottom.
    CKTextFieldView *emailAddressView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self placeholder:@"EMAIL ADDRESS"];
    emailAddressView.allowSpaces = NO;
    emailAddressView.maxLength = 256;
    emailAddressView.frame = (CGRect){
        emailInsets.left,
        emailNameView.frame.origin.y + emailNameView.frame.size.height,
        emailAddressView.frame.size.width,
        emailAddressView.frame.size.height
    };
    emailAddressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailAddressView];
    self.emailAddressView = emailAddressView;
    [emailContainerView addSubview:self.emailAddressDivider];

    // Password field anchor to the bottom.
    CKTextFieldView *emailPasswordView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self placeholder:@"PASSWORD" password:YES];
    emailPasswordView.allowSpaces = NO;
    emailPasswordView.maxLength = kPasswordMaxLength;
    emailPasswordView.frame = (CGRect){
        emailInsets.left,
        emailAddressView.frame.origin.y + emailAddressView.frame.size.height,
        emailPasswordView.frame.size.width,
        emailPasswordView.frame.size.height
    };
    emailPasswordView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailPasswordView];
    self.emailPasswordView = emailPasswordView;
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
    [self.emailContainerView addSubview:self.emailButton];
    [self.view addSubview:self.facebookButton];
}

- (void)initFooterView {
    [self updateFooterButtonForSignUp:YES];
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
- (void)facebookButtonTapped {
    [self loginToFacebook];
}

- (void)emailButtonTapped {
    DLog();
}

- (void)loginToFacebook {
    // Inform for modal.
    [self.delegate signUpViewControllerModalRequested:YES];
    
    [self.facebookButton setText:@"CHATTING TO FACEBOOK" activity:YES animated:NO enabled:NO];

    [self enableFacebookLogin:YES completion:^{
        
        // Wait before informing login successful.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self performFacebookLogin];
        });
    }];
}

- (void)performFacebookLogin {
    
    // Now tries and log the user in.
    [CKUser loginWithFacebookCompletion:^{
        
        [self.facebookButton setText:@"CONNECTED TO FACEBOOK" activity:NO animated:NO enabled:NO];
        
        // Wait before informing login successful.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self informFacebookLoginSuccessful:YES];
        });
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        [self enableFacebookLogin:NO completion:^{
            [self.facebookButton setText:@"UNABLE TO LOGIN" activity:NO animated:NO enabled:NO];
            [self informFacebookLoginSuccessful:NO];
        }];
        
    }];
}

- (void)informFacebookLoginSuccessful:(BOOL)success {
    
    // Inform to release modal.
    [self.delegate signUpViewControllerModalRequested:NO];
    
    // Inform login result.
    [EventHelper postLoginSuccessful:success];
}

- (void)enableFacebookLogin:(BOOL)enable completion:(void (^)())completion {
    CGRect frame = [self facebookFrameForSignUp:self.signUpMode];
    if (enable) {
        frame.origin.y = floorf((self.view.bounds.size.height - self.facebookButton.frame.size.height) / 2.0);
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.facebookButton.frame = frame;
                         self.emailContainerView.alpha = enable ? 0.0 : 1.0;
                         self.signUpToggleButton.alpha = enable ? 0.0 : 1.0;
                     }
                     completion:^(BOOL finished) {
                         completion();
                     }];
}

@end
