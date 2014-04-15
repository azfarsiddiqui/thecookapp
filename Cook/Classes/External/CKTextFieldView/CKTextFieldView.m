//
//  CKTextFieldView.m
//  CKTextFieldDemo
//
//  Created by Jeff Tan-Ang on 27/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextFieldView.h"
#import "UIColor+Expanded.h"
#import <QuartzCore/QuartzCore.h>

@interface CKTextFieldView () <UITextFieldDelegate>

@property (nonatomic, assign) id<CKTextFieldViewDelegate> delegate;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIImageView *validationImageView;
@property (nonatomic, assign) BOOL autoCapitalise;
@property (nonatomic, assign) BOOL submit;

@end

@implementation CKTextFieldView

#define kDefaultContentInsets   UIEdgeInsetsMake(8.0, 20.0, 8.0, 20.0)
#define kTextFieldFont          [UIFont fontWithName:@"AvenirNext-Regular" size:20]
#define kTextFieldColour        [UIColor colorWithHexString:@"FFFFFF"]
#define kPlaceholderFont        [UIFont fontWithName:@"AvenirNext-Regular" size:20]
#define kPlaceholderColour      [UIColor colorWithHexString:@"FFFFFF"]
#define kDefaultMaxLength       50

- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder {
    
    return [self initWithWidth:width delegate:delegate placeholder:placeholder password:NO];
}

- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password {
    
    return [self initWithWidth:width delegate:delegate placeholder:placeholder password:password
                 contentInsets:kDefaultContentInsets];
}

- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password submit:(BOOL)submit {
    
    return [self initWithWidth:width delegate:delegate placeholder:placeholder password:password autoCapitalise:NO
                        submit:submit contentInsets:kDefaultContentInsets];
}

- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
     autoCapitalise:(BOOL)autoCapitalise {
    
    return [self initWithWidth:width delegate:delegate placeholder:placeholder password:NO autoCapitalise:autoCapitalise
                 contentInsets:kDefaultContentInsets];
}

- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password contentInsets:(UIEdgeInsets)contentInsets {
    
    return [self initWithWidth:width delegate:delegate placeholder:placeholder password:password autoCapitalise:NO
                 contentInsets:contentInsets];
}

- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password autoCapitalise:(BOOL)autoCapitalise contentInsets:(UIEdgeInsets)contentInsets {
    
    return [self initWithWidth:width delegate:delegate placeholder:placeholder password:password
                autoCapitalise:autoCapitalise submit:NO contentInsets:contentInsets];
}

- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password autoCapitalise:(BOOL)autoCapitalise submit:(BOOL)submit
      contentInsets:(UIEdgeInsets)contentInsets {
    
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        
        self.password = password;
        self.placeholder = placeholder;
        self.autoCapitalise = autoCapitalise;
        self.submit = submit;
        self.contentInsets = contentInsets;
        self.backgroundColor = [UIColor clearColor];
        self.width = width;
        self.maxLength = kDefaultMaxLength;
        self.allowSpaces = YES;
        
        self.frame = CGRectMake(0.0,
                                0.0,
                                width,
                                contentInsets.top + self.textField.frame.size.height + contentInsets.bottom);
        
        // Background textfield.
        UIImage *textBackground = [[UIImage imageNamed:@"cook_login_textfield.png"]
                                   resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
        UIImageView *textBackgroundImageView = [[UIImageView alloc] initWithImage:textBackground];
        textBackgroundImageView.frame = (CGRect){
            self.bounds.origin.x,
            floorf((self.bounds.size.height - textBackgroundImageView.frame.size.height) / 2.0),
            self.bounds.size.width,
            textBackgroundImageView.frame.size.height
        };
        [self addSubview:textBackgroundImageView];
        
        // Update frame of textField to start center.
        self.textField.frame = [self textFieldFrameForMessagePresent:NO];
        [self addSubview:self.textField];
        
        // Show placeholder to start off with.
        [self showPlaceholder:YES animated:NO];
    }
    return self;
}

- (NSString *)inputText {
    return self.textField.text;
}

- (void)setValidated:(BOOL)validated {
    [self setValidated:validated showIcon:YES];
}

- (void)setValidated:(BOOL)validated showIcon:(BOOL)showIcon {
    
    // Change the validation icon image.
    self.validationImageView.hidden = !showIcon;
    self.validationImageView.image = [self validationImageForValidated:validated];
    
    // Position it at the end.
    self.validationImageView.frame = (CGRect) {
        self.bounds.size.width,
        floorf((self.bounds.size.height - self.validationImageView.frame.size.height) / 2.0) + 1.0,
        self.validationImageView.frame.size.width,
        self.validationImageView.frame.size.height
    };
    
    // Add it to textfield if not there already.
    if (!self.validationImageView.superview) {
        [self addSubview:self.validationImageView];
    }
    
    // Mark as validated.
    self.dataValidated = validated;
}

- (void)focusTextFieldView:(BOOL)focus {
    
    // Perform responder stuff on the main queue in next runloop to ensure it gets it.
    if (focus) {
        if (![self.textField isFirstResponder]) {
            [self.textField becomeFirstResponder];
        }
    } else {
        if ([self.textField isFirstResponder]) {
            [self.textField resignFirstResponder];
        }
    }
}

- (void)setText:(NSString *)text {
    self.textField.text = text;
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [self.textField resignFirstResponder];
}

- (NSAttributedString *)attributedTextForPlaceholderWithText:(NSString *)text {
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:[self textAttributesForFont:kPlaceholderFont textAlignment:NSTextAlignmentCenter]];
}

- (NSDictionary *)textAttributesForFont:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.paragraphSpacingBefore = 0.0;
    paragraphStyle.alignment = textAlignment;
    
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

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self focus:YES];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSString *text = [self trimmedTextFor:textField.text];
    textField.text = text;
    
    if ([text length] > 0) {
        [self.delegate didEndForTextFieldView:self];
    } else {
        [self focus:NO];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate didReturnForTextFieldView:self];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Reset any validation.
    [self clearValidation];
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Allow spaces?
    if (!self.allowSpaces && [newString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound) {
        return NO;
    }
    
    // Max reached?
    if ([newString length] > self.maxLength) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Properties

- (UITextField *)textField {
    if (!_textField) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.font = kTextFieldFont;
        textField.textColor = kTextFieldColour;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textField.backgroundColor = [UIColor clearColor];
        textField.delegate = self;
        textField.returnKeyType = self.submit ? UIReturnKeyGo : UIReturnKeyNext;
        textField.text = @"";
        textField.keyboardType = self.password ? UIKeyboardTypeDefault : UIKeyboardTypeEmailAddress;
        textField.autocapitalizationType = self.autoCapitalise ? UITextAutocapitalizationTypeWords : UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        [textField setSecureTextEntry:self.password];
        [textField sizeToFit];
        _textField = textField;
    }
    return _textField;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:self.textField.bounds];
        placeholderLabel.attributedText = [self attributedTextForPlaceholderWithText:self.placeholder];
        placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _placeholderLabel = placeholderLabel;
    }
    return _placeholderLabel;
}

- (UIImageView *)validationImageView {
    if (!_validationImageView) {
        _validationImageView = [[UIImageView alloc] initWithImage:[self validationImageForValidated:YES]];
    }
    return _validationImageView;
}

#pragma mark - Private methods

- (void)showPlaceholder:(BOOL)show animated:(BOOL)animated {
    
    if ((show && self.placeholderLabel.superview) || (!show && !self.placeholderLabel.superview)) {
        return;
    }
    
    if (animated) {
        CGAffineTransform shiftTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.95, 0.95);
        CGAffineTransform transform = CGAffineTransformConcat(shiftTransform, scaleTransform);
        
        if (show) {
            [self.textField addSubview:self.placeholderLabel];
            self.placeholderLabel.alpha = 0.0;
            self.placeholderLabel.hidden = NO;
            self.placeholderLabel.transform = transform;
        }
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.placeholderLabel.alpha = show ? 1.0 : 0.0;
                             self.placeholderLabel.transform = show ? CGAffineTransformIdentity : transform;
                         }
                         completion:^(BOOL finished) {
                             if (!show) {
                                 [self.placeholderLabel removeFromSuperview];
                             }
                         }];
        
    } else {
        if (show) {
            [self.textField addSubview:self.placeholderLabel];
        } else {
            [self.placeholderLabel removeFromSuperview];
        }
    }
    
}

- (NSString *)trimmedTextFor:(NSString *)text {
    if (text == nil) {
        return @"";
    } else {
        return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

- (void)focus:(BOOL)focus {
    [self showPlaceholder:!focus animated:NO];
}

- (CGRect)textFieldFrameForMessagePresent:(BOOL)messagePresent {
    if (messagePresent) {
        return CGRectMake(self.contentInsets.left,
                          self.contentInsets.top,
                          self.width - self.contentInsets.left - self.contentInsets.right,
                          self.textField.frame.size.height);
    } else {
        return CGRectMake(self.contentInsets.left,
                          floorf((self.bounds.size.height - self.textField.frame.size.height) / 2.0),
                          self.width - self.contentInsets.left - self.contentInsets.right,
                          self.textField.frame.size.height);
    }
}

- (UIImage *)validationImageForValidated:(BOOL)validated {
    if (validated) {
        return [UIImage imageNamed:@"cook_login_check_okay.png"];
    } else {
        return [UIImage imageNamed:@"cook_login_check_error.png"];
    }
}

- (void)clearValidation {
    self.dataValidated = NO;
    [self.validationImageView removeFromSuperview];
}

@end
