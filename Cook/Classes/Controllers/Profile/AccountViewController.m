//
//  UserViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "AccountViewController.h"
#import "CKUserInfoView.h"
#import "ViewHelper.h"
#import "ForgotPasswordViewController.h"
#import "AppHelper.h"
#import "CKTextFieldView.h"
#import "CKSignInButtonView.h"
#import "CKTextFieldViewHelper.h"
#import "CKUserProfilePhotoView.h"
#import "CKUser.h"
#import "EventHelper.h"

@interface AccountViewController () <UIScrollViewDelegate, CKSignInButtonViewDelegate, CKTextFieldViewDelegate>

@property (nonatomic, weak) id<AccountViewControllerDelegate> delegate;
@property (nonatomic, strong) CKUser *user;

@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *dividerView;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) UIView *emailContainerView;
@property (nonatomic, strong) CKTextFieldView *emailNameView;
@property (nonatomic, strong) CKTextFieldView *emailAddressView;
@property (nonatomic, strong) CKTextFieldView *emailPasswordView;
@property (nonatomic, strong) CKSignInButtonView *emailButton;
@property (nonatomic, strong) CKSignInButtonView *logoutButton;
@property (nonatomic, strong) ForgotPasswordViewController *forgotPasswordViewController;
@property (nonatomic, strong) UIButton *footerTermsButton;
@property (nonatomic, strong) UIButton *footerPrivacyButton;
@property (nonatomic, strong) UIButton *footerForgotButton;
@property (nonatomic, strong) UIButton *leftArrowButton;

@end

@implementation AccountViewController

#define kContentInsets              (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kHeaderHeight               110.0
#define kFooterButtonHeight         50.0
#define kEmailSignupSize            CGSizeMake(480.0, 337.0)
#define kPasswordMinLength          6
#define kPasswordMaxLength          32

- (id)initWithUser:(CKUser *)user delegate:(id<AccountViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.user = user;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    [self.view addSubview:self.blurredImageView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.closeButton];
    
    [self initFormContainerView];
    [self initForgotView];
    [self initFooterView];
}

#pragma mark - CKSignInButtonViewDelegate methods

- (void)signInTappedForButtonView:(CKSignInButtonView *)buttonView {
    DLog();
    
    if (buttonView == self.emailButton) {
        [self saveButtonTapped];
    } else if (buttonView == self.logoutButton) {
        [self logoutButtonTapped];
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
            [self saveButtonTapped];
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
        [self.forgotPasswordViewController reset];
    }
    
    // Fade in the arrow if we're on the forgot page.
    if (!decelerate && self.scrollView.contentOffset.x == self.scrollView.bounds.size.width) {
        [self showForgotArrow:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // Re-enable the forgot button.
    if (self.scrollView.contentOffset.x == 0) {
        [self.forgotPasswordViewController reset];
    }
    
    // Fade in the arrow if we're on the forgot page.
    if (self.scrollView.contentOffset.x == self.scrollView.bounds.size.width) {
        [self showForgotArrow:YES];
    }
}

#pragma mark - Properties

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        _blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _blurredImageView.image = [self.delegate accountViewControllerBlurredImageForDash];
    }
    return _blurredImageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            floorf((kHeaderHeight - _closeButton.frame.size.height) / 2.0) + 7.0,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _scrollView.contentSize = (CGSize) { self.view.bounds.size.width * 2.0, self.view.bounds.size.height };
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

- (ForgotPasswordViewController *)forgotPasswordViewController {
    if (!_forgotPasswordViewController) {
        _forgotPasswordViewController = [[ForgotPasswordViewController alloc] init];
    }
    return _forgotPasswordViewController;
}

- (UIButton *)footerTermsButton {
    if (!_footerTermsButton) {
        _footerTermsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _footerTermsButton.userInteractionEnabled = YES;
        [_footerTermsButton setAttributedTitle:[self attributedTextForFooterLabelWithText:@"TERMS & CONDITION"] forState:UIControlStateNormal];
        [_footerTermsButton addTarget:self action:@selector(termsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_footerTermsButton sizeToFit];
    }
    return _footerTermsButton;
}

- (UIButton *)footerPrivacyButton {
    if (!_footerPrivacyButton) {
        _footerPrivacyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _footerPrivacyButton.userInteractionEnabled = YES;
        [_footerPrivacyButton setAttributedTitle:[self attributedTextForFooterLabelWithText:@"PRIVACY"] forState:UIControlStateNormal];
        [_footerPrivacyButton addTarget:self action:@selector(privacyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_footerPrivacyButton sizeToFit];
    }
    return _footerPrivacyButton;
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

- (CKUserProfilePhotoView *)profilePhotoView {
    if (!_profilePhotoView) {
        _profilePhotoView = [[CKUserProfilePhotoView alloc] initWithUser:self.user profileSize:ProfileViewSizeLarge];
        _profilePhotoView.highlightOnTap = NO;
    }
    return _profilePhotoView;
}

#pragma mark - Private methods

- (void)initFormContainerView {
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
    self.emailButton = [[CKSignInButtonView alloc] initWithSize:(CGSize){ availableSize.width, 83.0 } text:@"SAVE" activity:NO delegate:self];
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
    [emailAddressView setText:self.user.email];
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
    [emailNameView setText:self.user.name];
    self.emailNameView = emailNameView;
    
    self.dividerView.frame = CGRectMake(floorf((self.scrollView.bounds.size.width - self.dividerView.frame.size.width) / 2.0),
                      self.emailContainerView.frame.origin.y + self.emailContainerView.frame.size.height + 0,
                      self.dividerView.frame.size.width,
                      self.dividerView.frame.size.height);
    [self.scrollView addSubview:self.dividerView];
    
    // Profile photo.
    CGRect profileFrame = self.profilePhotoView.frame;
    profileFrame.origin = (CGPoint) {
        floorf((self.scrollView.bounds.size.width - profileFrame.size.width) / 2.0),
        emailContainerView.frame.origin.y - profileFrame.size.height - 20.0
    };
    self.profilePhotoView.frame = profileFrame;
    [self.scrollView addSubview:self.profilePhotoView];
    
    // Logout button
    self.logoutButton = [[CKSignInButtonView alloc] initWithSize:(CGSize){ availableSize.width, 83.0 } text:@"LOGOUT" activity:NO delegate:self];
    self.logoutButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.logoutButton.frame = CGRectMake(floorf((self.scrollView.bounds.size.width - self.logoutButton.frame.size.width) / 2.0),
                                         self.emailContainerView.frame.origin.y + self.emailContainerView.bounds.size.height + 30.0,
                                         self.logoutButton.frame.size.width,
                                         self.logoutButton.frame.size.height);
    [self.scrollView addSubview:self.logoutButton];
}

- (void)closeTapped:(id)sender {
    [self.delegate accountViewControllerDismissRequested];
}

- (void)initForgotView {
    CGRect forgotFrame = self.forgotPasswordViewController.view.frame;
    forgotFrame.origin.x = self.scrollView.bounds.size.width;
    self.forgotPasswordViewController.view.frame = forgotFrame;
    [self.scrollView addSubview:self.forgotPasswordViewController.view];
    
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

- (void)initFooterView {
    
    // Terms
    self.footerTermsButton.frame = (CGRect) {
        25.0,
        self.scrollView.bounds.size.height - kFooterButtonHeight,
        self.footerTermsButton.frame.size.width,
        kFooterButtonHeight
    };
    [self.scrollView addSubview:self.footerTermsButton];
    
    // Privacy
    self.footerPrivacyButton.frame = (CGRect) {
        self.footerTermsButton.frame.origin.x + self.footerTermsButton.frame.size.width + 20.0,
        self.scrollView.bounds.size.height - kFooterButtonHeight,
        self.footerPrivacyButton.frame.size.width,
        kFooterButtonHeight
    };
    [self.scrollView addSubview:self.footerPrivacyButton];
    
    // Footer button.
    self.footerForgotButton.frame = (CGRect) {
        self.scrollView.bounds.size.width - self.footerForgotButton.frame.size.width - 40.0,
        self.scrollView.bounds.size.height - kFooterButtonHeight,
        self.footerForgotButton.frame.size.width,
        kFooterButtonHeight
    };
    [self.scrollView addSubview:self.footerForgotButton];
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

- (void)termsButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.thecookapp.com/terms"]];
}

- (void)privacyButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.thecookapp.com/privacy"]];
}

- (void)forgotButtonTapped:(id)sender {
    [self.scrollView setContentOffset:(CGPoint){ self.scrollView.bounds.size.width, 0.0 } animated:YES];
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

- (BOOL)validateFields:(NSArray *)fields {
    BOOL validated = YES;
    for (CKTextFieldView *textFieldView in fields) {
        
        NSString *text = [textFieldView inputText];
        
        if (textFieldView == self.emailNameView) {
            
            if ([text length] > 0) {
                [self.emailNameView setValidated:YES showIcon:YES];
            } else {
                [self.emailNameView setValidated:NO showIcon:YES];
                validated = NO;
            }
            
        } else if (textFieldView == self.emailAddressView) {
            
            if ([CKTextFieldViewHelper isValidEmailForString:text]) {
                [self.emailAddressView setValidated:YES showIcon:YES];
            } else {
                [self.emailAddressView setValidated:NO showIcon:YES];
                validated = NO;
            }
            
        } else if (textFieldView == self.emailPasswordView) {
            
            if ([CKTextFieldViewHelper isValidLengthForString:text min:kPasswordMinLength max:kPasswordMaxLength]) {
                [self.emailPasswordView setValidated:YES showIcon:YES];
            } else {
                [self.emailPasswordView setValidated:NO showIcon:YES];
                validated = NO;
            }
        }
    }
    return validated;
}

- (void)saveButtonTapped {
    
    // Assemble the fields to validate.
    NSMutableArray *fields = [NSMutableArray arrayWithArray:@[self.emailNameView, self.emailAddressView, self.emailPasswordView]];

    // Make sure all fields are validated before proceeding.
    BOOL validated = [self validateFields:fields];
    if (!validated) {
        return;
    }
    
//    [self.emailButton setText:@"SAVING" activity:YES animated:NO enabled:NO];
}

- (void)logoutButtonTapped {
    [CKUser logoutWithCompletion:^{
        [self.logoutButton setText:@"LOGGING OUT" activity:YES animated:NO enabled:NO];
        
        // Wait before informing logout successful.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [EventHelper postLogout];
        });
        
    } failure:^(NSError *error) {
    }];
}

- (void)arrowTapped:(id)sender {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

@end
