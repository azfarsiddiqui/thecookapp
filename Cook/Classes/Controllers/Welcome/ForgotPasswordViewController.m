//
//  ForgotPasswordViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/07/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "AppHelper.h"
#import "CKTextFieldView.h"
#import "CKSignInButtonView.h"
#import "CKUser.h"
#import "CKTextFieldViewHelper.h"

@interface ForgotPasswordViewController () <CKTextFieldViewDelegate, CKSignInButtonViewDelegate>

@property (nonatomic, strong) UILabel *forgotLabel;
@property (nonatomic, strong) CKTextFieldView *forgotEmailView;
@property (nonatomic, strong) CKSignInButtonView *forgotButton;
@property (nonatomic, strong) UIButton *leftArrowButton;

@end

@implementation ForgotPasswordViewController

#define kEmailSignupSize    CGSizeMake(480.0, 337.0)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    [self initForgotView];
}

- (void)reset {
    [self.forgotEmailView setText:@""];
    [self.forgotEmailView resignFirstResponder];
    [self.forgotButton setText:[self forgotButtonText] activity:NO animated:NO enabled:YES];
}

#pragma mark - CKSignInButtonViewDelegate methods

- (void)signInTappedForButtonView:(CKSignInButtonView *)buttonView {
    
    if (buttonView == self.forgotButton) {
        [self forgotButtonTapped];
    }
}

#pragma mark - CKTextFieldViewDelegate methods

- (NSString *)progressTextForTextFieldView:(CKTextFieldView *)textFieldView currentText:(NSString *)text {
    return nil;
}

- (void)didEndForTextFieldView:(CKTextFieldView *)textFieldView {
    [self validateFields:@[textFieldView]];
}

- (void)didReturnForTextFieldView:(CKTextFieldView *)textFieldView {
    if ([self validateFields:@[textFieldView]]) {
        if (textFieldView == self.forgotEmailView) {
            [self forgotButtonTapped];
        }
    }
}

#pragma mark - Properties

- (UILabel *)forgotLabel {
    if (!_forgotLabel) {
        _forgotLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _forgotLabel.attributedText = [self attributedTextForTitleLabelWithText:NSLocalizedString(@"RESET PASSWORD", nil)];
        [_forgotLabel sizeToFit];
    }
    return _forgotLabel;
}

#pragma mark - Private methods

- (void)initForgotView {
    
    CGFloat labelFieldGap = 26.0;
    CGFloat fieldButtonGap = 14.0;
    UIEdgeInsets emailInsets = UIEdgeInsetsMake(50.0, 50.0, 27.0, 50.0);
    CGSize availableSize = (CGSize){
        kEmailSignupSize.width - emailInsets.left - emailInsets.right,
        kEmailSignupSize.height - emailInsets.top - emailInsets.bottom
    };
    
    // Forgot label.
    CGRect forgotLabelFrame = self.forgotLabel.frame;
    
    // Forgot email.
    self.forgotEmailView = [[CKTextFieldView alloc] initWithWidth:availableSize.width delegate:self
                                                      placeholder:NSLocalizedString(@"Email Address", nil) password:NO submit:YES];
    CGRect forgotEmailFrame = self.forgotEmailView.frame;
    forgotEmailFrame.origin.y = forgotLabelFrame.origin.y + forgotLabelFrame.size.height + labelFieldGap;
    [self.view addSubview:self.forgotEmailView];
    
    // Send button.
    self.forgotButton = [[CKSignInButtonView alloc] initWithSize:(CGSize){ availableSize.width, 83.0 }
                                                            text:[self forgotButtonText] activity:NO delegate:self];
    CGRect forgotButtonFrame = self.forgotButton.frame;
    forgotButtonFrame.origin.y = forgotEmailFrame.origin.y + fieldButtonGap;
    
    // Update positioning.
    CGRect combinedFrame = CGRectUnion(forgotLabelFrame, CGRectUnion(forgotEmailFrame, forgotButtonFrame));
    forgotLabelFrame.origin.x = floorf((self.view.bounds.size.width - forgotLabelFrame.size.width) / 2.0);
    forgotLabelFrame.origin.y = floorf((self.view.bounds.size.height - combinedFrame.size.height) / 2.0) - 25.0;
    self.forgotLabel.frame = forgotLabelFrame;
    forgotEmailFrame.origin.x = floorf((self.view.bounds.size.width - forgotEmailFrame.size.width) / 2.0);
    forgotEmailFrame.origin.y = forgotLabelFrame.origin.y + forgotLabelFrame.size.height + labelFieldGap;
    self.forgotEmailView.frame = forgotEmailFrame;
    forgotButtonFrame.origin.x = floorf((self.view.bounds.size.width - forgotButtonFrame.size.width) / 2.0);
    forgotButtonFrame.origin.y = forgotEmailFrame.origin.y + forgotEmailFrame.size.height + fieldButtonGap;
    self.forgotButton.frame = forgotButtonFrame;
    [self.view addSubview:self.forgotLabel];
    [self.view addSubview:self.forgotEmailView];
    [self.view addSubview:self.forgotButton];

}

- (NSAttributedString *)attributedTextForTitleLabelWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:[self textAttributesForFont:[UIFont fontWithName:@"BrandonGrotesque-Regular" size:64]
                                                                  paragraphBefore:0.0]];
}

- (BOOL)validateFields:(NSArray *)fields {
    BOOL validated = YES;
    for (CKTextFieldView *textFieldView in fields) {
        
        NSString *text = [textFieldView inputText];
        
        if (textFieldView == self.forgotEmailView) {
            
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

- (NSString *)forgotButtonText {
    return NSLocalizedString(@"SEND", nil);
}

- (void)forgotButtonTapped {
    
    // Make sure all fields are validated before proceeding.
    BOOL validated = [self validateFields:@[self.forgotEmailView]];
    if (!validated) {
        return;
    }
    
    [self.forgotButton setText:NSLocalizedString(@"SENDING", nil) activity:YES animated:NO enabled:NO];
    [self sendForgotPassword];
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

- (void)sendForgotPassword {
    DLog();
    NSString *email = [self.forgotEmailView inputText];
    [CKUser requestPasswordResetForEmail:email completion:^{
        
        [self.forgotButton setText:NSLocalizedString(@"PLEASE CHECK YOUR EMAIL", nil) done:YES activity:NO animated:NO enabled:NO];
        [self.forgotEmailView focusTextFieldView:NO];
        
    } failure:^(NSError *error) {
        
        [self.forgotButton setText:NSLocalizedString(@"EMAIL ADDRESS IS NOT REGISTERED", nil) activity:NO animated:NO enabled:NO];
        
        // Re-enable the forgot button.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.forgotButton setText:[self forgotButtonText] activity:NO
                              animated:NO enabled:YES];
        });
        
    }];
}

@end
