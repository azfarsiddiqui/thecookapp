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
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation CKTextFieldView

#define kDefaultContentInsets   UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0)
#define kTextFieldFont          [UIFont fontWithName:@"BrandonGrotesque-Regular" size:16]
#define kTextFieldColour        [UIColor colorWithHexString:@"333333"]
#define kPlaceholderFont        [UIFont fontWithName:@"BrandonGrotesque-Regular" size:16]
#define kPlaceholderColour      [UIColor colorWithHexString:@"333333"]

- (id)initWithFrame:(CGRect)frame delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder {
    
    return [self initWithFrame:frame delegate:delegate placeholder:placeholder password:NO];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password {
    
    return [self initWithFrame:frame delegate:delegate placeholder:placeholder password:password
                 contentInsets:kDefaultContentInsets];
}

- (id)initWithFrame:(CGRect)frame delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password contentInsets:(UIEdgeInsets)contentInsets {
    
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        self.password = password;
        self.placeholder = placeholder;
        self.contentInsets = contentInsets;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.textField];
        [self showPlaceholder:YES animated:NO];
    }
    return self;
}

- (NSString *)inputText {
    return self.textField.text;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self showPlaceholder:NO animated:YES];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSString *text = [self trimmedTextFor:textField.text];
    textField.text = text;
    
    if ([text length] > 0) {
        [self.delegate textFieldViewDidSubmit:self];
    } else {
        [self showPlaceholder:YES animated:YES];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyGo;
        textField.text = @"";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        [textField setSecureTextEntry:self.password];
        [textField sizeToFit];
        textField.frame = CGRectMake(self.contentInsets.left,
                                     floorf((self.bounds.size.height - textField.frame.size.height) / 2.0),
                                     self.bounds.size.width - self.contentInsets.left - self.contentInsets.right,
                                     textField.frame.size.height);
        _textField = textField;
    }
    return _textField;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:self.textField.bounds];
        placeholderLabel.textAlignment = NSTextAlignmentCenter;
        placeholderLabel.font = kPlaceholderFont;
        placeholderLabel.textColor = kPlaceholderColour;
        placeholderLabel.text = self.placeholder;
        placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        placeholderLabel.backgroundColor = [UIColor clearColor];
        placeholderLabel.shadowColor = [UIColor whiteColor];
        placeholderLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _placeholderLabel = placeholderLabel;
    }
    return _placeholderLabel;
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
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
