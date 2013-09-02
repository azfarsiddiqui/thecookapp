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

@interface SignupViewController () <CKTextFieldViewDelegate, CKSignInButtonViewDelegate>

@property (nonatomic, assign) id<SignupViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *blackOverlayView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *dividerView;
@property (nonatomic, strong) UIView *emailContainerView;
@property (nonatomic, strong) CKTextFieldView *emailNameView;
@property (nonatomic, strong) CKTextFieldView *emailAddressView;
@property (nonatomic, strong) CKTextFieldView *emailPasswordView;
@property (nonatomic, strong) CKSignInButtonView *emailButton;
@property (nonatomic, strong) CKFacebookSignInButtonView *facebookButton;
@property (nonatomic, strong) UIButton *footerToggleButton;
@property (nonatomic, assign) BOOL signUpMode;
@property (nonatomic, assign) BOOL animating;

@end

@implementation SignupViewController

#define kEmailSignupSize    CGSizeMake(460.0, 337.0)
#define kEmailSignInSize    CGSizeMake(460.0, 263.0)
#define kTextFieldSize      CGSizeMake(300.0, 50.0)
#define kDividerInsets      UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
#define kPasswordMinLength  6
#define kPasswordMaxLength  32
#define kFooterTextInsets   UIEdgeInsetsMake(5.0, 20.0, 25.0, 20.0)

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    
    [self initBackgroundView];
    [self initEmailContainerView];
    [self initHeaderView];
    [self initButtons];
    [self initFooterView];
    
//    [self loadSnapshot:[self.delegate signupViewControllerSnapshotRequested]];
    [self loadSnapshotImage:[self.delegate signupViewControllerSnapshotImageRequested]];
    
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
        self.subtitleLabel.alpha = 0.0;
        self.subtitleLabel.hidden = NO;
    }
    
    if (animated) {
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.emailContainerView.frame = [self emailContainerFrameForSignUp:signUp];
                             self.titleLabel.frame = [self titleFrameForSignUp:signUp];
                             self.subtitleLabel.frame = [self signupSubtitleFrameForSignUp:signUp];
                             self.facebookButton.frame = [self facebookFrameForSignUp:signUp];
                             self.dividerView.frame = [self dividerFrameForSignUp:signUp];
                             
                             self.subtitleLabel.alpha = signUp ? 1.0 : 0.0;
                             self.emailNameView.alpha = signUp ? 1.0 : 0.0;
                             
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
                                 self.subtitleLabel.hidden = NO;
                             }
                             
                             self.animating = NO;
                             
                         }];
    } else {
        self.emailContainerView.frame = [self emailContainerFrameForSignUp:signUp];
        self.titleLabel.frame = [self titleFrameForSignUp:signUp];
        self.subtitleLabel.frame = [self signupSubtitleFrameForSignUp:signUp];
        self.facebookButton.frame = [self facebookFrameForSignUp:signUp];
        self.dividerView.frame = [self dividerFrameForSignUp:signUp];
        
        self.subtitleLabel.alpha = signUp ? 1.0 : 0.0;
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
             self.subtitleLabel.hidden = NO;
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

    [ImageHelper blurredSignUpImage:screenshotImage completion:^(UIImage *blurredImage) {
        self.blurredImageView.image = blurredImage;
    }];
}

- (void)loadSnapshotImage:(UIImage *)snapshotImage {
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         self.blackOverlayView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         
                         // Now start blurring.
                         [ImageHelper blurredSignUpImage:snapshotImage completion:^(UIImage *blurredImage) {
                             self.blurredImageView.alpha = 0.0;
                             self.blurredImageView.image = blurredImage;
                             
                             // Fade blurred image in, while fade the dark overlay out.
                             [UIView animateWithDuration:0.5
                                                   delay:0.0
                                                 options:UIViewAnimationCurveLinear
                                              animations:^{
                                                  self.blackOverlayView.alpha = 0.0;
                                                  self.blurredImageView.alpha = 1.0;
                                              } completion:^(BOOL finished) {
                                              }];

                         }];
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
    NSLog(@"textFieldViewDidEnd:");
    [self validateFields:@[textFieldView]];
}

- (void)didReturnForTextFieldView:(CKTextFieldView *)textFieldView {
    NSLog(@"textFieldViewDidReturn:");
    if ([self validateFields:@[textFieldView]]) {
        [self emailButtonTapped];
    }
}

#pragma mark - Properties

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:64];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        _titleLabel.shadowOffset = CGSizeMake(0.0, 2.0);
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:26];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        _subtitleLabel.shadowOffset = CGSizeMake(0.0, 2.0);
    }
    return _subtitleLabel;
}

- (UIImageView *)dividerView {
    if (!_dividerView) {
        UIImage *dividerImage = [[UIImage imageNamed:@"cook_login_divider.png"] resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 1.0, 0.0, 1.0 }];
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
        _footerToggleButton.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:14];
        _footerToggleButton.titleLabel.shadowOffset = CGSizeMake(0.0, 2.0);
        _footerToggleButton.userInteractionEnabled = YES;
        [_footerToggleButton setTitleShadowColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2] forState:UIControlStateNormal];
        [_footerToggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_footerToggleButton setTitleColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.2] forState:UIControlStateHighlighted];
        [_footerToggleButton addTarget:self action:@selector(toggleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footerToggleButton;
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

- (void)initBackgroundView {
    // Blurred imageView to be hidden to start off with.
    self.blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blurredImageView];
    self.blurredImageView.alpha = 0.0;  // To be faded in after blurred image has finished loaded.
    
    // Temporary dark overlay to be in place before blur comes in.
    self.blackOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.blackOverlayView.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColourWithAlpha:0.5];
    [self.view addSubview:self.blackOverlayView];
    self.blackOverlayView.alpha = 0.0;  // To be faded in.
    
    // Register tap to dismiss.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    self.blurredImageView.userInteractionEnabled = YES;
    [self.blurredImageView addGestureRecognizer:tapGesture];
}

- (void)initEmailContainerView {
    UIEdgeInsets emailInsets = UIEdgeInsetsMake(50.0, 50.0, 27.0, 50.0);
    CGFloat fieldsGap = 30.0;
    
    UIView *emailContainerView = [[UIView alloc] initWithFrame:(CGRect){
        floorf((self.view.bounds.size.width - kEmailSignupSize.width) / 2.0),
        floorf((self.view.bounds.size.height - kEmailSignupSize.height) / 2.0),
        kEmailSignupSize.width,
        kEmailSignupSize.height}];
    emailContainerView.backgroundColor = [UIColor clearColor];
//    emailContainerView.backgroundColor = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.5];
    emailContainerView.userInteractionEnabled = YES;
    [self.view addSubview:emailContainerView];
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
    CKTextFieldView *emailPasswordView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self placeholder:@"Password" password:YES];
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
    CKTextFieldView *emailNameView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self placeholder:@"Your Name"];
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
    [self.view addSubview:self.dividerView];
}

- (void)initHeaderView {
    
    // Signup Title
    if (!self.titleLabel.superview) {
        [self.view addSubview:self.titleLabel];
    }
    self.titleLabel.text = [self titleForSignUp:self.signUpMode];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = [self titleFrameForSignUp:self.signUpMode];
    
    // Signup Subtitle
//    if (!self.subtitleLabel.superview) {
//        [self.view addSubview:self.subtitleLabel];
//    }
    self.subtitleLabel.text = [self subtitleForSignUp:self.signUpMode];
    [self.subtitleLabel sizeToFit];
    self.subtitleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - self.subtitleLabel.frame.size.width) / 2.0),
                                                self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height - 20.0,
                                                self.subtitleLabel.frame.size.width,
                                                self.subtitleLabel.frame.size.height);
    
}

- (void)initButtons {
    self.facebookButton.frame = [self facebookFrameForSignUp:self.signUpMode];
    [self.view addSubview:self.facebookButton];
}

- (void)initFooterView {
    [self updateFooterButtonForSignUp:YES];
}

- (void)updateHeaderTextForSignUp:(BOOL)signUp {
    self.titleLabel.text = [self titleForSignUp:signUp];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = [self titleFrameForSignUp:signUp];
}

- (void)updateFooterButtonForSignUp:(BOOL)signUp {
    if (!self.footerToggleButton.superview) {
        [self.view addSubview:self.footerToggleButton];
    }
    [self.footerToggleButton setTitle:[self footerTextForSignUp:signUp] forState:UIControlStateNormal];
    [self.footerToggleButton sizeToFit];
    self.footerToggleButton.backgroundColor = [UIColor clearColor];
    self.footerToggleButton.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.footerToggleButton.frame.size.width - kFooterTextInsets.left - kFooterTextInsets.right) / 2.0),
        self.view.bounds.size.height - self.footerToggleButton.frame.size.height - kFooterTextInsets.top - kFooterTextInsets.bottom,
        kFooterTextInsets.left + self.footerToggleButton.frame.size.width+ kFooterTextInsets.right,
        kFooterTextInsets.top + self.footerToggleButton.frame.size.height + kFooterTextInsets.bottom
    };
}

- (void)toggleButtonTapped:(id)sender {
    [self enableSignUpMode:!self.signUpMode];
}

- (NSString *)titleForSignUp:(BOOL)signUp {
    return signUp ? @"SIGNUP" : @"SIGN IN";
}

- (NSString *)subtitleForSignUp:(BOOL)signUp {
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

- (CGRect)titleFrameForSignUp:(BOOL)signUp {
    CGRect frame = self.titleLabel.frame;
    frame.origin.x = floorf((self.view.bounds.size.width - frame.size.width) / 2.0);
    frame.origin.y = self.emailContainerView.frame.origin.y - self.titleLabel.frame.size.height - 0.0;
//    if (signUp) {
//        frame.origin.y = self.emailContainerView.frame.origin.y - self.titleLabel.frame.size.height - 20.0;
//    } else {
//        frame.origin.y = self.emailContainerView.frame.origin.y - self.titleLabel.frame.size.height + 5.0;
//    }
    return frame;
}

- (CGRect)signupSubtitleFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.view.bounds.size.width - self.subtitleLabel.frame.size.width) / 2.0),
                      self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height - 20.0,
                      self.subtitleLabel.frame.size.width,
                      self.subtitleLabel.frame.size.height);
}

- (CGRect)facebookFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.view.bounds.size.width - self.facebookButton.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y + self.emailContainerView.bounds.size.height + 30.0,
                      self.facebookButton.frame.size.width,
                      self.facebookButton.frame.size.height);
}

- (CGRect)dividerFrameForSignUp:(BOOL)signUp {
    return CGRectMake(floorf((self.view.bounds.size.width - self.dividerView.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y + self.emailContainerView.frame.size.height + 0,
                      self.dividerView.frame.size.width,
                      self.dividerView.frame.size.height);
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
                         self.dividerView.alpha = show ? 0.0: 1.0;
                         self.facebookButton.alpha = show ? 0.0 : 1.0;
                         self.view.transform = show ? translateTransform : CGAffineTransformIdentity;
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
        
        [self.emailButton setText:@"REGISTERING" activity:YES animated:NO enabled:NO];
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

- (void)registerViaEmail {
    
    NSString *name = [self.emailNameView inputText];
    NSString *email = [self.emailAddressView inputText];
    NSString *password = [self.emailPasswordView inputText];
    
    [CKUser registerWithEmail:email
                         name:name
                     password:password
                   completion:^{
                       
                       // Wait before informing login successful.
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                           [self informLoginSuccessful:YES];
                       });
                       
                   } failure:^(NSError *error) {
                       
                       if ([CKUser usernameExistsForSignUpError:error]) {
                           [self.emailButton setText:@"USERNAME EXISTS" activity:NO animated:NO enabled:NO];
                       } else {
                           [self.emailButton setText:@"UNABLE TO REGISTER" activity:NO animated:NO enabled:NO];
                       }

                       // Re-enable the email button.
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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
                    
                    // Wait before informing login successful.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self informLoginSuccessful:YES];
                    });
                    
                } failure:^(NSError *error) {
                    
                    [self enableFacebookLogin:NO completion:^{
                        [self.emailButton setText:@"UNABLE TO LOGIN" activity:NO animated:NO enabled:NO];
                        [self informLoginSuccessful:NO];
                        
                        // Re-enable the email button.
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self.emailButton setText:[self emailButtonTextForSignUp:self.signUpMode] activity:NO
                                             animated:NO enabled:YES];
                        });
                    }];
                    
                }];
}

- (void)facebookButtonTapped {
    
    // Inform for modal.
    [self.delegate signUpViewControllerModalRequested:YES];
    [self.facebookButton setText:@"CHATTING TO FACEBOOK" activity:YES animated:NO enabled:NO];
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
    [CKUser loginWithFacebookCompletion:^{
        
        [self.facebookButton setText:@"CONNECTED TO FACEBOOK" activity:NO animated:NO enabled:NO];
        
        // Wait before informing login successful.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self informLoginSuccessful:YES];
        });
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        [self enableFacebookLogin:NO completion:^{
            [self.facebookButton setText:@"UNABLE TO LOGIN" activity:NO animated:NO enabled:NO];
            [self informLoginSuccessful:NO];
            
            // Re-enable the facebook button.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.facebookButton setText:[self facebookButtonTextForSignUp:self.signUpMode] activity:NO animated:NO
                                     enabled:YES];
            });
        }];
        
    }];
}

- (void)informLoginSuccessful:(BOOL)success {
    
    // Inform to release modal.
    [self.delegate signUpViewControllerModalRequested:NO];
    
    // Inform login result.
    [EventHelper postLoginSuccessful:success];
}

- (void)enableFacebookLogin:(BOOL)enable completion:(void (^)())completion {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         // Shift Facebook Button.
                         CGRect facebookButtonFrame = [self facebookFrameForSignUp:self.signUpMode];
                         if (enable) {
                             facebookButtonFrame.origin.y = floorf((self.view.bounds.size.height - self.facebookButton.frame.size.height) / 2.0);
                         }
                         self.facebookButton.frame = facebookButtonFrame;
                         
                         // Shift Title.
                         CGRect signUpTitleFrame = [self titleFrameForSignUp:self.signUpMode];
                         if (enable) {
                             signUpTitleFrame.origin.y = facebookButtonFrame.origin.y - 120.0;
                         }
                         self.titleLabel.frame = signUpTitleFrame;
                         
                         // Shift SignUp Subtitle.
                         CGRect signUpSubtitleFrame = [self signupSubtitleFrameForSignUp:self.signUpMode];
                         if (enable) {
                             signUpSubtitleFrame.origin.y = signUpTitleFrame.origin.y + signUpTitleFrame.size.height - 20.0;
                         }
                         self.subtitleLabel.frame = signUpSubtitleFrame;
                         
                         // Shift SignIn Title
                         
                         // Shift or label up.
                         self.dividerView.frame = [self dividerFrameForSignUp:self.signUpMode];
                         
                         // Fade out the emil container.
                         self.emailContainerView.alpha = enable ? 0.0 : 1.0;
                         self.footerToggleButton.alpha = enable ? 0.0 : 1.0;
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
                [self.emailNameView setValidated:YES message:@"THANKS"];
            } else {
                validated = NO;
            }
            
        } else if (textFieldView == self.emailAddressView) {
            
            if ([CKTextFieldViewHelper isValidEmailForString:text]) {
                [self.emailAddressView setValidated:YES message:@"THANKS"];
            } else {
                [self.emailAddressView setValidated:NO message:@"INVALID EMAIL"];
                validated = NO;
            }
            
        } else if (textFieldView == self.emailPasswordView) {
            
            if ([CKTextFieldViewHelper isValidLengthForString:text min:kPasswordMinLength max:kPasswordMaxLength]) {
                [self.emailPasswordView setValidated:YES message:@"THANKS"];
            } else {
                [self.emailPasswordView setValidated:NO message:@"INVALID PASSWORD"];
                validated = NO;
            }
            
        }
    }
    return validated;
}

- (void)backgroundTapped:(UITapGestureRecognizer *)tapGesture {
    [self.delegate signupViewControllerDismissRequested];
}

@end
