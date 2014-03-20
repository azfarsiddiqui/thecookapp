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
#import "CKFacebookSignInButtonView.h"
#import "CKUser.h"
#import "EventHelper.h"
#import "ImageHelper.h"
#import "NSString+Utilities.h"
#import "ModalOverlayHelper.h"

@interface SignupViewController () <CKTextFieldViewDelegate, CKSignInButtonViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id<SignupViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *dividerView;
@property (nonatomic, strong) UIView *emailContainerView;
@property (nonatomic, strong) CKTextFieldView *emailNameView;
@property (nonatomic, strong) CKTextFieldView *emailAddressView;
@property (nonatomic, strong) CKTextFieldView *emailPasswordView;
@property (nonatomic, strong) CKSignInButtonView *emailButton;
@property (nonatomic, strong) CKFacebookSignInButtonView *facebookButton;
@property (nonatomic, strong) UIButton *footerToggleButton;
@property (nonatomic, strong) UIButton *footerForgotButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) BOOL signUpMode;
@property (nonatomic, assign) BOOL animating;

// Forgot password.
@property (nonatomic, strong) UILabel *forgotLabel;
@property (nonatomic, strong) CKTextFieldView *forgotEmailView;
@property (nonatomic, strong) CKSignInButtonView *forgotButton;
@property (nonatomic, strong) UIButton *leftArrowButton;

// Facebook new user alert.
@property (nonatomic, strong) UIAlertView *facebookNewUserAlert;

@end

@implementation SignupViewController

#define kCloseButtonInsets  (UIEdgeInsets){ 30.0, 20.0, 0.0, 0.0 }
#define kEmailSignupSize    CGSizeMake(480.0, 337.0)
#define kEmailSignInSize    CGSizeMake(480.0, 263.0)
#define kTextFieldSize      CGSizeMake(300.0, 50.0)
#define kDividerInsets      UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
#define kPasswordMinLength  6
#define kPasswordMaxLength  32
#define kFooterTextInsets   UIEdgeInsetsMake(5.0, 20.0, 25.0, 20.0)
#define kFooterButtonHeight 50.0
#define kUntappableSize     (CGSize){ 500.0, 600.0 }

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

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
    
    //    [self loadSnapshot:[self.delegate signupViewControllerSnapshotRequested]];
    [self loadSnapshotImage:[self.delegate signupViewControllerSnapshotImageRequested]];
    [self initScrollView];
    [self initEmailContainerView];
    [self initHeaderView];
    [self initButtons];
    [self initFooterView];
    [self initForgotView];
    
    // Register for keyboard events.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Register for background/terminate events.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationDidEnterBackgroundNotification object:nil];
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
    }
    
    if (animated) {
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.emailContainerView.frame = [self emailContainerFrameForSignUp:signUp];
                             self.titleLabel.frame = [self titleFrameForSignUp:signUp];
                             self.facebookButton.frame = [self facebookFrameForSignUp:signUp];
                             self.dividerView.frame = [self dividerFrameForSignUp:signUp];
                             
                             self.emailNameView.alpha = signUp ? 1.0 : 0.0;
                             self.footerForgotButton.alpha = signUp ? 0.0 : 1.0;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             // Update header text.
                             [self updateHeaderTextForSignUp:signUp];
                             
                             // Update signup/signin buttons.
                             [self.emailButton setText:[self emailButtonTextForSignUp:signUp] activity:NO animated:NO];
                             [self.facebookButton setText:[self facebookButtonTextForSignUp:signUp] activity:NO animated:NO];
                             
                             // Update footer text.
                             [self updateFooterButtonForSignUp:signUp];
                             
                             if (!signUp) {
                                 self.emailNameView.hidden = YES;
                             }
                             
                             self.animating = NO;
                             
                         }];
    } else {
        self.emailContainerView.frame = [self emailContainerFrameForSignUp:signUp];
        self.titleLabel.frame = [self titleFrameForSignUp:signUp];
        self.facebookButton.frame = [self facebookFrameForSignUp:signUp];
        self.dividerView.frame = [self dividerFrameForSignUp:signUp];
        
        self.footerForgotButton.alpha = signUp ? 0.0 : 1.0;
        self.emailNameView.alpha = signUp ? 1.0 : 0.0;
        
        // Update header text.
        [self updateHeaderTextForSignUp:signUp];
        
        // Update signup/signin buttons.
        [self.emailButton setText:[self emailButtonTextForSignUp:signUp] activity:NO animated:NO];
        [self.facebookButton setText:[self facebookButtonTextForSignUp:signUp] activity:NO animated:NO];
        
        // Update footer text.
        [self updateFooterButtonForSignUp:signUp];
        
         if (!signUp) {
             self.emailNameView.hidden = YES;
         }
        
         self.animating = NO;
    }
}

- (void)loadSnapshot:(UIView *)snapshotView {
    
    // Only works with snapshotted views.
    UIGraphicsBeginImageContextWithOptions(snapshotView.frame.size, NO, 0);
    BOOL snapshotDone = [snapshotView drawViewHierarchyInRect:snapshotView.bounds afterScreenUpdates:YES];
    DLog(@"Snapshot Done: %@", [NSString CK_stringForBoolean:snapshotDone]);
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [ImageHelper blurredOverlayImage:screenshotImage completion:^(UIImage *blurredImage) {
        self.blurredImageView.image = blurredImage;
    }];
}

- (void)loadSnapshotImage:(UIImage *)snapshotImage {
    
    // Blurred imageView to be hidden to start off with.
    self.blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blurredImageView];
    self.blurredImageView.alpha = 0.0;  // To be faded in after blurred image has finished loaded.
    self.blurredImageView.image = snapshotImage;

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.blurredImageView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                     }];
    
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

- (void)didEndForTextFieldView:(CKTextFieldView *)textFieldView {
    [self validateFields:@[textFieldView]];
}

- (void)didReturnForTextFieldView:(CKTextFieldView *)textFieldView {
    if ([self validateFields:@[textFieldView]]) {
        if (textFieldView == self.emailNameView) {
            [self.emailAddressView becomeFirstResponder];
        } else if (textFieldView == self.emailAddressView) {
            [self.emailPasswordView becomeFirstResponder];
        } else if (textFieldView == self.emailPasswordView) {
            [self emailButtonTapped];
        } else if (textFieldView == self.forgotEmailView) {
            [self forgotButtonTapped];
        }
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.leftArrowButton.alpha == 1.0) {
        [self showForgotArrow:NO];
    }
    
    // Fade in the arrow if we're on the forgot page.
    if (self.scrollView.contentOffset.x == self.scrollView.bounds.size.width) {
        [self showForgotArrow:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // Re-enable the forgot button.
    if (!decelerate && self.scrollView.contentOffset.x == 0) {
        [self.forgotButton setText:[self forgotButtonText] activity:NO animated:NO enabled:YES];
    }
    
    // Fade in the arrow if we're on the forgot page.
    if (!decelerate && self.scrollView.contentOffset.x == self.scrollView.bounds.size.width) {
        [self showForgotArrow:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // Re-enable the forgot button.
    if (self.scrollView.contentOffset.x == 0) {
        [self.forgotButton setText:[self forgotButtonText] activity:NO animated:NO enabled:YES];
    }
    
    // Fade in the arrow if we're on the forgot page.
    if (self.scrollView.contentOffset.x == self.scrollView.bounds.size.width) {
        [self showForgotArrow:YES];
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.facebookNewUserAlert) {
        
        // Clear alerts.
        self.facebookNewUserAlert = nil;
        
        if (buttonIndex == 0) {
            
            [self deleteCurrentUser];
            
        } else if (buttonIndex == 1) {
            
            // Proceed.
            [self.facebookButton setText:[self welcomeText] done:YES activity:NO animated:NO enabled:NO];
            
            // Wait before informing login successful.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self informLoginSuccessful:YES];
            });
            
        }
    }
    
}

#pragma mark - Properties

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _titleLabel;
}

- (UILabel *)forgotLabel {
    if (!_forgotLabel) {
        _forgotLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _forgotLabel.attributedText = [self attributedTextForTitleLabelWithText:@"RESET PASSWORD"];
        [_forgotLabel sizeToFit];
    }
    return _forgotLabel;
}

- (UIImageView *)dividerView {
    if (!_dividerView) {
        UIImage *dividerImage = [[UIImage imageNamed:@"cook_login_divider.png"] resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 4.0, 0.0, 4.0 }];
        _dividerView = [[UIImageView alloc] initWithImage:dividerImage];
        CGRect frame = _dividerView.frame;
        frame.size.width = 288.0;
        _dividerView.frame = frame;
    }
    return _dividerView;
}

- (CKFacebookSignInButtonView *)facebookButton {
    if (!_facebookButton) {
        _facebookButton = [[CKFacebookSignInButtonView alloc] initWithSize:self.emailButton.frame.size
                                                                      text:[self facebookButtonTextForSignUp:YES] activity:NO delegate:self];
        _facebookButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _facebookButton;
}

- (UIButton *)footerToggleButton {
    if (!_footerToggleButton) {
        _footerToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _footerToggleButton.userInteractionEnabled = YES;
        [_footerToggleButton addTarget:self action:@selector(toggleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footerToggleButton;
}

- (UIButton *)footerForgotButton {
    if (!_footerForgotButton) {
        _footerForgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _footerForgotButton.userInteractionEnabled = YES;
        [_footerForgotButton setAttributedTitle:[self attributedTextForFooterLabelWithText:@"FORGOT PASSWORD"] forState:UIControlStateNormal];
        [_footerForgotButton addTarget:self action:@selector(forgotButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_footerForgotButton sizeToFit];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_login_rightarrow_sm.png"]];
        arrowImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        arrowImageView.frame = (CGRect) {
            _footerForgotButton.frame.size.width + 5.0,
            floorf((_footerForgotButton.bounds.size.height - arrowImageView.frame.size.height) / 2.0),
            arrowImageView.frame.size.width,
            arrowImageView.frame.size.height
        };
        [_footerForgotButton addSubview:arrowImageView];
        
    }
    return _footerForgotButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
    }
    return _closeButton;
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

#pragma mark - Lifecycle events.

- (void)appDidEnterBackground:(NSNotification *)notification {
    
    // If Facebook new alert is visible, then dismiss it to do cleanup.
    if (self.facebookNewUserAlert.visible) {
        [self.facebookNewUserAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
}

- (void)appWillTerminate:(NSNotification *)notification {
    
    // If Facebook new alert is visible, then dismiss it to do cleanup.
    if (self.facebookNewUserAlert.visible) {
        [self deleteCurrentUserUpdateViews:NO];
    }
}

#pragma mark - CKSignInButtonViewDelegate methods

- (void)signInTappedForButtonView:(CKSignInButtonView *)buttonView {
    DLog();
    
    if (buttonView == self.facebookButton) {
        [self facebookButtonTapped];
    } else if (buttonView == self.emailButton) {
        [self emailButtonTapped];
    } else if (buttonView == self.forgotButton) {
        [self forgotButtonTapped];
    }
}

#pragma mark - Private methods

- (void)initScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.scrollView.contentSize = (CGSize) { self.view.bounds.size.width * 2.0, self.view.bounds.size.height };
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    // Register tap to dismiss.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)initEmailContainerView {
    UIEdgeInsets emailInsets = UIEdgeInsetsMake(50.0, 50.0, 27.0, 50.0);
    CGFloat fieldsGap = 30.0;
    
    UIView *emailContainerView = [[UIView alloc] initWithFrame:(CGRect){
        floorf((self.scrollView.bounds.size.width - kEmailSignupSize.width) / 2.0),
        floorf((self.scrollView.bounds.size.height - kEmailSignupSize.height) / 2.0),
        kEmailSignupSize.width,
        kEmailSignupSize.height}];
    emailContainerView.backgroundColor = [UIColor clearColor];
//    emailContainerView.backgroundColor = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.5];
    emailContainerView.userInteractionEnabled = YES;
    [self.scrollView addSubview:emailContainerView];
    self.emailContainerView = emailContainerView;
    
    CGSize availableSize = (CGSize){
        kEmailSignupSize.width - emailInsets.left - emailInsets.right,
        kEmailSignupSize.height - emailInsets.top - emailInsets.bottom
    };
    
    // Email button anchored to the bottom.
    self.emailButton = [[CKSignInButtonView alloc] initWithSize:(CGSize){ availableSize.width, 83.0 }
                                                           text:[self emailButtonTextForSignUp:YES] activity:NO delegate:self];
    self.emailButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.emailButton.frame = (CGRect){
        emailInsets.left + floorf((availableSize.width - self.emailButton.frame.size.width) / 2.0),
        self.emailContainerView.bounds.size.height - self.emailButton.frame.size.height - emailInsets.bottom,
        self.emailButton.frame.size.width,
        self.emailButton.frame.size.height};
    [emailContainerView addSubview:self.emailButton];

    // Password field anchor to the bottom.
    CKTextFieldView *emailPasswordView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self
                                                                    placeholder:@"Password" password:YES submit:YES];
    emailPasswordView.allowSpaces = NO;
    emailPasswordView.maxLength = kPasswordMaxLength;
    emailPasswordView.frame = (CGRect){
        emailInsets.left + floorf((availableSize.width - emailPasswordView.frame.size.width) / 2.0),
        self.emailButton.frame.origin.y - fieldsGap - emailPasswordView.frame.size.height + 20.0,
        emailPasswordView.frame.size.width,
        emailPasswordView.frame.size.height
    };
    emailPasswordView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailPasswordView];
    self.emailPasswordView = emailPasswordView;

    // Email field anchor to the bottom.
    CKTextFieldView *emailAddressView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self placeholder:@"Email Address"];
    emailAddressView.allowSpaces = NO;
    emailAddressView.maxLength = 256;
    emailAddressView.frame = (CGRect){
        emailInsets.left + floorf((availableSize.width - emailAddressView.frame.size.width) / 2.0),
        self.emailPasswordView.frame.origin.y - fieldsGap - emailAddressView.frame.size.height,
        emailAddressView.frame.size.width,
        emailAddressView.frame.size.height
    };
    emailAddressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailAddressView];
    self.emailAddressView = emailAddressView;
    
    // Name field anchor to the top.
    CKTextFieldView *emailNameView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self placeholder:@"Full Name" autoCapitalise:YES];
    emailNameView.frame = (CGRect){
        emailInsets.left + floorf((availableSize.width - emailNameView.frame.size.width) / 2.0),
        self.emailAddressView.frame.origin.y - fieldsGap - emailNameView.frame.size.height,
        emailNameView.frame.size.width,
        emailNameView.frame.size.height
    };
    emailNameView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [emailContainerView addSubview:emailNameView];
    self.emailNameView = emailNameView;
    
    self.dividerView.frame = [self dividerFrameForSignUp:self.signUpMode];
    [self.scrollView addSubview:self.dividerView];
}

- (void)initForgotView {
    
    CGFloat labelFieldGap = 26.0;
    CGFloat fieldButtonGap = 14.0;
    
    // Forgot label.
    CGRect forgotLabelFrame = self.forgotLabel.frame;
    
    // Forgot email.
    self.forgotEmailView = [[CKTextFieldView alloc] initWithWidth:self.emailAddressView.frame.size.width delegate:self
                                                      placeholder:@"Email Address" password:NO submit:YES];
    CGRect forgotEmailFrame = self.forgotEmailView.frame;
    forgotEmailFrame.origin.y = forgotLabelFrame.origin.y + forgotLabelFrame.size.height + labelFieldGap;
    [self.scrollView addSubview:self.forgotEmailView];
    
    // Send button.
    self.forgotButton = [[CKSignInButtonView alloc] initWithSize:(CGSize){ self.emailButton.frame.size.width, 83.0 }
                                                            text:[self forgotButtonText] activity:NO delegate:self];
    CGRect forgotButtonFrame = self.forgotButton.frame;
    forgotButtonFrame.origin.y = forgotEmailFrame.origin.y + fieldButtonGap;
    
    // Update positioning.
    CGRect combinedFrame = CGRectUnion(forgotLabelFrame, CGRectUnion(forgotEmailFrame, forgotButtonFrame));
    forgotLabelFrame.origin.x = self.scrollView.bounds.size.width + floorf((self.scrollView.bounds.size.width - forgotLabelFrame.size.width) / 2.0);
    forgotLabelFrame.origin.y = floorf((self.scrollView.bounds.size.height - combinedFrame.size.height) / 2.0) - 25.0;
    self.forgotLabel.frame = forgotLabelFrame;
    forgotEmailFrame.origin.x = self.scrollView.bounds.size.width + floorf((self.scrollView.bounds.size.width - forgotEmailFrame.size.width) / 2.0);
    forgotEmailFrame.origin.y = forgotLabelFrame.origin.y + forgotLabelFrame.size.height + labelFieldGap;
    self.forgotEmailView.frame = forgotEmailFrame;
    forgotButtonFrame.origin.x = self.scrollView.bounds.size.width + floorf((self.scrollView.bounds.size.width - forgotButtonFrame.size.width) / 2.0);
    forgotButtonFrame.origin.y = forgotEmailFrame.origin.y + forgotEmailFrame.size.height + fieldButtonGap;
    self.forgotButton.frame = forgotButtonFrame;
    [self.scrollView addSubview:self.forgotLabel];
    [self.scrollView addSubview:self.forgotEmailView];
    [self.scrollView addSubview:self.forgotButton];
    
    // Left arrow.
    UIButton *leftArrowButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_login_leftarrow.png"]
                                                     target:self selector:@selector(arrowTapped:)];
    leftArrowButton.frame = (CGRect) {
        self.scrollView.bounds.size.width + 30.0,
        floorf((self.scrollView.bounds.size.height - leftArrowButton.frame.size.height) / 2.0) + 10.0,
        leftArrowButton.frame.size.width,
        leftArrowButton.frame.size.height
    };
    leftArrowButton.alpha = 0.0;  // Hidden to start off with.
    [self.scrollView addSubview:leftArrowButton];
    self.leftArrowButton = leftArrowButton;
}

- (void)initHeaderView {
    
    // Signup Title
    if (!self.titleLabel.superview) {
        [self.scrollView addSubview:self.titleLabel];
    }
    self.titleLabel.attributedText = [self attributedTextForTitleLabelWithText:[self titleForSignUp:self.signUpMode]];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = [self titleFrameForSignUp:self.signUpMode];
    
}

- (void)initButtons {
    
    // Top-left close button.
    self.closeButton.frame = (CGRect){
        kCloseButtonInsets.left,
        kCloseButtonInsets.top,
        self.closeButton.frame.size.width,
        self.closeButton.frame.size.height
    };
    [self.view addSubview:self.closeButton];
    
    // Facebook button
    self.facebookButton.frame = [self facebookFrameForSignUp:self.signUpMode];
    [self.scrollView addSubview:self.facebookButton];
}

- (void)initFooterView {
    [self updateFooterButtonForSignUp:YES];
}

- (void)updateHeaderTextForSignUp:(BOOL)signUp {
    self.titleLabel.attributedText = [self attributedTextForTitleLabelWithText:[self titleForSignUp:self.signUpMode]];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = [self titleFrameForSignUp:signUp];
}

- (void)updateFooterButtonForSignUp:(BOOL)signUp {
    if (!self.footerToggleButton.superview) {
        [self.scrollView addSubview:self.footerToggleButton];
    }
    [self.footerToggleButton setAttributedTitle:[self attributedTextForFooterLabelWithText:[self footerTextForSignUp:signUp]] forState:UIControlStateNormal];
    [self.footerToggleButton sizeToFit];
    self.footerToggleButton.backgroundColor = [UIColor clearColor];
    self.footerToggleButton.frame = (CGRect){
        floorf((self.scrollView.bounds.size.width - self.footerToggleButton.frame.size.width) / 2.0),
        self.scrollView.bounds.size.height - kFooterButtonHeight,
        self.footerToggleButton.frame.size.width,
        kFooterButtonHeight
    };
    
    // Forgot button on the previous page.
    if (!self.footerForgotButton.superview) {
        [self.scrollView addSubview:self.footerForgotButton];
    }
    self.footerForgotButton.frame = (CGRect) {
        self.scrollView.bounds.size.width - self.footerForgotButton.frame.size.width - 40.0,
        self.footerToggleButton.frame.origin.y,
        self.footerForgotButton.frame.size.width,
        kFooterButtonHeight
    };
}

- (void)toggleButtonTapped:(id)sender {
    [self enableSignUpMode:!self.signUpMode];
}

- (void)forgotButtonTapped:(id)sender {
    [self.scrollView setContentOffset:(CGPoint){ self.scrollView.bounds.size.width, 0.0 } animated:YES];
}

- (NSString *)titleForSignUp:(BOOL)signUp {
    return signUp ? @"REGISTER" : @"SIGN IN";
}

- (NSString *)footerTextForSignUp:(BOOL)signUp {
    return signUp ? @"ALREADY HAVE AN ACCOUNT? SIGN IN" : @"DON'T HAVE AN ACCOUNT? SIGN UP";
}

- (NSString *)emailButtonTextForSignUp:(BOOL)signUp {
    return signUp ? @"REGISTER WITH EMAIL" : @"SIGN IN";
}

- (NSString *)facebookButtonTextForSignUp:(BOOL)signUp {
    return signUp ? @"REGISTER WITH FACEBOOK" : @"SIGN IN WITH FACEBOOK";
}

- (NSString *)forgotButtonText {
    return @"SEND";
}

- (CGRect)emailContainerFrameForSignUp:(BOOL)signUp {
    CGSize size = signUp ? kEmailSignupSize : kEmailSignInSize;
    return CGRectMake(floorf((self.scrollView.bounds.size.width - size.width) / 2.0),
                      floorf((self.scrollView.bounds.size.height - size.height) / 2.0),
                      size.width,
                      size.height);
}

- (CGRect)titleFrameForSignUp:(BOOL)signUp {
    CGRect frame = self.titleLabel.frame;
    frame.origin.x = floorf((self.scrollView.bounds.size.width - frame.size.width) / 2.0);
    frame.origin.y = self.emailContainerView.frame.origin.y - self.titleLabel.frame.size.height - 0.0;
//    if (signUp) {
//        frame.origin.y = self.emailContainerView.frame.origin.y - self.titleLabel.frame.size.height - 20.0;
//    } else {
//        frame.origin.y = self.emailContainerView.frame.origin.y - self.titleLabel.frame.size.height + 5.0;
//    }
    return frame;
}

- (CGRect)facebookFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.scrollView.bounds.size.width - self.facebookButton.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y + self.emailContainerView.bounds.size.height + 30.0,
                      self.facebookButton.frame.size.width,
                      self.facebookButton.frame.size.height);
}

- (CGRect)dividerFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.scrollView.bounds.size.width - self.dividerView.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y + self.emailContainerView.frame.size.height + 0,
                      self.dividerView.frame.size.width,
                      self.dividerView.frame.size.height);
}

- (void)handleKeyboardShow:(BOOL)show keyboardFrame:(CGRect)keyboardFrame {
    
    // Inform delegate that focus is obtained/lost.
    [self.delegate signupViewControllerFocused:show];
    
    // Convert keyboard frame to currentView to handle rotated interface.
    keyboardFrame = [self.scrollView convertRect:keyboardFrame fromView:nil];
    
    CGFloat yOffset = self.signUpMode ? 70.0 : 55.0;
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0.0, -floorf(keyboardFrame.origin.y / 2.0) + yOffset);
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.dividerView.alpha = show ? 0.0: 1.0;
                         self.facebookButton.alpha = show ? 0.0 : 1.0;
                         self.scrollView.transform = show ? translateTransform : CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)emailButtonTapped {
    
    // Assemble the fields to validate.
    NSMutableArray *fields = [NSMutableArray arrayWithArray:@[self.emailAddressView, self.emailPasswordView]];
    if (self.signUpMode) {
        [fields insertObject:self.emailNameView atIndex:0];
    }
    
    // Make sure all fields are validated before proceeding.
    BOOL validated = [self validateFields:fields];
    if (!validated) {
        return;
    }
    
    // Inform for modal.
    [self.delegate signUpViewControllerModalRequested:YES];
    
    if (self.signUpMode) {
        
        [self.emailButton setText:@"SIGNING UP" activity:YES animated:NO enabled:NO];
        [self enableEmailLogin:YES completion:^{
            [self registerViaEmail];
        }];
        
    } else {
        
        [self.emailButton setText:@"SIGNING IN" activity:YES animated:NO enabled:NO];
        [self enableEmailLogin:YES completion:^{
            [self loginViaEmail];
        }];
    }
    
}

- (void)forgotButtonTapped {
    
    // Make sure all fields are validated before proceeding.
    BOOL validated = [self validateFields:@[self.forgotEmailView]];
    if (!validated) {
        return;
    }
    
    // Inform for modal.
    [self.delegate signUpViewControllerModalRequested:YES];
    
    [self.forgotButton setText:@"SENDING" activity:YES animated:NO enabled:NO];
    [self sendForgotPassword];
}

- (void)sendForgotPassword {
    DLog();
    NSString *email = [self.forgotEmailView inputText];
    [CKUser requestPasswordResetForEmail:email completion:^{
        
        [self.forgotButton setText:@"PLEASE CHECK YOUR EMAIL" done:YES activity:NO animated:NO enabled:NO];
        [self.forgotEmailView focusTextFieldView:NO];
        
    } failure:^(NSError *error) {
        
        [self.forgotButton setText:@"EMAIL ADDRESS IS NOT REGISTERED" activity:NO animated:NO enabled:NO];
        
        // Re-enable the forgot button.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.forgotButton setText:[self forgotButtonText] activity:NO
                              animated:NO enabled:YES];
        });
        
    }];
}

- (void)registerViaEmail {
    
    NSString *name = [self.emailNameView inputText];
    NSString *email = [self.emailAddressView inputText];
    NSString *password = [self.emailPasswordView inputText];
    
    [CKUser registerWithEmail:email
                         name:name
                     password:password
                   completion:^{
                       
                       [self.emailButton setText:[self welcomeText] done:YES activity:NO animated:NO enabled:NO];
                       
                       // Wait before informing login successful.
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                           [self informLoginSuccessful:YES newUser:YES];
                       });
                       
                   } failure:^(NSError *error) {
                       
                       if ([CKUser usernameExistsForSignUpError:error]) {
                           [self.emailButton setText:@"EMAIL IS ALREADY REGISTERED" activity:NO animated:NO enabled:NO];
                       } else {
                           [self.emailButton setText:@"COULDN'T CONNECT" activity:NO animated:NO enabled:NO];
                       }

                       // Re-enable the email button.
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                           [self.emailButton setText:[self emailButtonTextForSignUp:self.signUpMode] activity:NO
                                                animated:NO enabled:YES];
                       });
                   }];
}


- (void)loginViaEmail {
    
    NSString *email = [self.emailAddressView inputText];
    NSString *password = [self.emailPasswordView inputText];
    
    [CKUser loginWithEmail:email
                  password:password
                completion:^{
                    
                    [self.emailButton setText:[self welcomeText] done:YES activity:NO animated:NO enabled:NO];
                    
                    // Wait before informing login successful.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self informLoginSuccessful:YES];
                    });
                    
                } failure:^(NSError *error) {
                    
                    if ([CKUser invalidCredentialsForSignInError:error]) {
                        [self.emailButton setText:@"INCORRECT EMAIL OR PASSWORD" activity:NO animated:NO enabled:NO];
                    } else {
                        [self.emailButton setText:@"COULDN'T CONNECT" activity:NO animated:NO enabled:NO];
                    }
                    
                    [self informLoginSuccessful:NO];
                    
                    // Re-enable the email button.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self.emailButton setText:[self emailButtonTextForSignUp:self.signUpMode] activity:NO
                                         animated:NO enabled:YES];
                    });
                    
                }];
}

- (void)facebookButtonTapped {
    
    // Inform for modal.
    [self.delegate signUpViewControllerModalRequested:YES];
    [self.facebookButton setText:@"CHATTING WITH FACEBOOK" activity:YES animated:NO enabled:NO];
    [self loginViaFacebook];
}

- (void)loginViaFacebook {
    
    [self enableFacebookLogin:YES completion:^{
        
        // Wait before informing login successful.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self performFacebookLogin];
        });
    }];
}


- (void)performFacebookLogin {
    
    // Now tries and log the user in.
    [CKUser loginWithFacebookCompletion:^(BOOL isNewUser) {
        
        if (!self.signUpMode && isNewUser) {
            self.facebookNewUserAlert = [[UIAlertView alloc] initWithTitle:@"Create Account"
                                                                   message:@"Your Facebook Account isn’t registered. Would you like to create a new Cook Account?"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
            [self.facebookNewUserAlert show];
            
        } else {
            
            [self.facebookButton setText:[self welcomeText] done:YES activity:NO animated:NO enabled:NO];
            
            // Wait before informing login successful.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self informLoginSuccessful:YES newUser:isNewUser];
            });
        }        
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        [self enableFacebookLogin:NO completion:^{
            
            if ([CKUser isFacebookPermissionsError:error]) {
                [ViewHelper alertWithTitle:@"Permission Required" message:@"Go to iPad Settings > Facebook and turn on for Cook"];
            }
            [self.facebookButton setText:@"COULDN'T CONNECT TO FACEBOOK" activity:NO animated:NO enabled:NO];
            [self informLoginSuccessful:NO];
            
            // Re-enable the facebook button.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.facebookButton setText:[self facebookButtonTextForSignUp:self.signUpMode] activity:NO animated:NO
                                     enabled:YES];
            });
        }];
        
    }];
}

- (void)informLoginSuccessful:(BOOL)success {
    [self informLoginSuccessful:success newUser:NO];
}

- (void)informLoginSuccessful:(BOOL)success newUser:(BOOL)newUser {
    
    // Inform to release modal.
    [self.delegate signUpViewControllerModalRequested:NO];
    
    // Inform login result.
    [EventHelper postLoginSuccessful:success newUser:newUser];
}

- (void)enableFacebookLogin:(BOOL)enable completion:(void (^)())completion {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         // Shift Facebook Button.
                         CGRect facebookButtonFrame = [self facebookFrameForSignUp:self.signUpMode];
                         if (enable) {
                             facebookButtonFrame.origin.y = floorf((self.scrollView.bounds.size.height - self.facebookButton.frame.size.height) / 2.0);
                         }
                         self.facebookButton.frame = facebookButtonFrame;
                         
                         // Shift Title.
                         CGRect signUpTitleFrame = [self titleFrameForSignUp:self.signUpMode];
                         if (enable) {
                             signUpTitleFrame.origin.y = facebookButtonFrame.origin.y - 98.0;
                         }
                         self.titleLabel.frame = signUpTitleFrame;
                         
                         // Shift or label up.
                         self.dividerView.frame = [self dividerFrameForSignUp:self.signUpMode];
                         
                         // Fade out the email container.
                         self.emailContainerView.alpha = enable ? 0.0 : 1.0;
                         self.footerToggleButton.alpha = enable ? 0.0 : 1.0;
                         self.footerForgotButton.alpha = enable ? 0.0 : 1.0;
                         self.dividerView.alpha = enable ? 0.0 : 1.0;
                         
                     }
                     completion:^(BOOL finished) {
                         completion();
                     }];
}

- (void)enableEmailLogin:(BOOL)enable completion:(void (^)())completion {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.dividerView.alpha = enable ? 0.0 : 1.0;
                         self.facebookButton.alpha = enable ? 0.0 : 1.0;
                     }
                     completion:^(BOOL finished) {
                         completion();
                     }];
}

- (BOOL)validateFields:(NSArray *)fields {
    BOOL validated = YES;
    for (CKTextFieldView *textFieldView in fields) {
        
        NSString *text = [textFieldView inputText];
        
        if (textFieldView == self.emailNameView) {
            
            if ([text length] > 0) {
                [self.emailNameView setValidated:YES showIcon:YES];
            } else {
                validated = NO;
            }
            
        } else if (textFieldView == self.emailAddressView) {
            
            if ([CKTextFieldViewHelper isValidEmailForString:text]) {
                [self.emailAddressView setValidated:YES showIcon:self.signUpMode];
            } else {
                [self.emailAddressView setValidated:NO showIcon:YES];
                validated = NO;
            }
            
        } else if (textFieldView == self.emailPasswordView) {
            
            if ([CKTextFieldViewHelper isValidLengthForString:text min:kPasswordMinLength max:kPasswordMaxLength]) {
                [self.emailPasswordView setValidated:YES showIcon:self.signUpMode];
            } else {
                [self.emailPasswordView setValidated:NO showIcon:YES];
                validated = NO;
            }
            
        } else if (textFieldView == self.forgotEmailView) {
            
            if ([CKTextFieldViewHelper isValidEmailForString:text]) {
                [self.forgotEmailView setValidated:YES showIcon:YES];
            } else {
                [self.forgotEmailView setValidated:NO showIcon:YES];
                validated = NO;
            }
            
        }
    }
    return validated;
}

- (void)backgroundTapped:(UITapGestureRecognizer *)tapGesture {
    CGPoint touchPoint = [tapGesture locationInView:self.scrollView];
    CGPoint untappableArea = [self.scrollView convertPoint:touchPoint toView:self.view];
    
    CGRect untappableFrame = (CGRect){
        floor((self.view.bounds.size.width - kUntappableSize.width) / 2.0),
        floorf((self.view.bounds.size.height - kUntappableSize.height) / 2.0),
        kUntappableSize.width,
        kUntappableSize.height
    };
    
    if (!CGRectContainsPoint(untappableFrame, untappableArea)) {
        [self.delegate signupViewControllerDismissRequested];
    }
    
}

- (void)showForgotArrow:(BOOL)show {
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.leftArrowButton.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)arrowTapped:(id)sender {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)closeTapped:(id)sender {
    [self.delegate signupViewControllerDismissRequested];
}

- (NSString *)welcomeText {
    CKUser *currentUser = [CKUser currentUser];
    return [[NSString stringWithFormat:@"WELCOME %@", currentUser.friendlyName] uppercaseString];
}

- (void)deleteCurrentUser {
    [self deleteCurrentUserUpdateViews:YES];
}

- (void)deleteCurrentUserUpdateViews:(BOOL)updateViews {
    DLog();
    CKUser *currentUser = [CKUser currentUser];
    [CKUser forceLogout];
    
    [currentUser deleteInBackground:^{
        DLog(@"Deleted user");
        
        if (updateViews) {
            [self enableFacebookLogin:NO completion:^{
                [self.facebookButton setText:[self facebookButtonTextForSignUp:self.signUpMode] activity:NO animated:NO
                                     enabled:YES];
                [self informLoginSuccessful:NO];
            }];
            
        }
    } failure:^(NSError *error) {
        DLog(@"Unable to delete user");
        
        if (updateViews) {
            [self enableFacebookLogin:NO completion:^{
                [self.facebookButton setText:[self facebookButtonTextForSignUp:self.signUpMode] activity:NO animated:NO
                                     enabled:YES];
                [self informLoginSuccessful:NO];
            }];
        }
        
    }];
}

- (NSAttributedString *)attributedTextForTitleLabelWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:[self textAttributesForFont:[UIFont fontWithName:@"BrandonGrotesque-Regular" size:64]
                                                                  paragraphBefore:0.0]];
}

- (NSAttributedString *)attributedTextForFooterLabelWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:[self textAttributesForFont:[UIFont fontWithName:@"BrandonGrotesque-Medium" size:14]
                                                                  paragraphBefore:0.0]];
}

- (NSDictionary *)textAttributesForFont:(UIFont *)font paragraphBefore:(CGFloat)paragraphBefore {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.paragraphSpacingBefore = paragraphBefore;
    
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.08];
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    shadow.shadowBlurRadius = 3.0;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            shadow, NSShadowAttributeName,
            nil];
}

@end
