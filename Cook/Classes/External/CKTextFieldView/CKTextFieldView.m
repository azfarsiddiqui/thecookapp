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
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *validationImageView;

@end

@implementation CKTextFieldView

#define kDefaultContentInsets   UIEdgeInsetsMake(5.0, 20.0, 5.0, 20.0)
#define kTextFieldFont          [UIFont fontWithName:@"BrandonGrotesque-Regular" size:16]
#define kTextFieldColour        [UIColor colorWithHexString:@"333333"]
#define kPlaceholderFont        [UIFont fontWithName:@"BrandonGrotesque-Regular" size:16]
#define kPlaceholderColour      [UIColor colorWithHexString:@"333333"]
#define kMessageFont            [UIFont fontWithName:@"BrandonGrotesque-Regular" size:14]
#define kMessageColour          [UIColor colorWithHexString:@"55A33A"]
#define kMessageErrorColour     [UIColor colorWithHexString:@"F2583F"]
#define kFieldMessageGap        0.0
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
           password:(BOOL)password contentInsets:(UIEdgeInsets)contentInsets {
    
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        
        // TODO COMMENTED TO FIGURE OUT POSITIONING OF ICON
        // self.password = password;
        
        self.placeholder = placeholder;
        self.contentInsets = contentInsets;
        self.backgroundColor = [UIColor clearColor];
        self.width = width;
        self.maxLength = kDefaultMaxLength;
        self.allowSpaces = YES;
        
        self.frame = CGRectMake(0.0,
                                0.0,
                                width,
                                contentInsets.top + self.textField.frame.size.height + kFieldMessageGap + self.messageLabel.frame.size.height + contentInsets.bottom);
        
        // Update frame of textField to start center.
        self.textField.frame = [self textFieldFrameForMessagePresent:NO];
        [self addSubview:self.textField];
        
        // Message label.
        CGRect focusedTextFieldFrame = [self textFieldFrameForMessagePresent:YES];
        self.messageLabel.frame = CGRectMake(focusedTextFieldFrame.origin.x,
                                             focusedTextFieldFrame.origin.y + focusedTextFieldFrame.size.height + kFieldMessageGap,
                                             focusedTextFieldFrame.size.width,
                                             self.messageLabel.frame.size.height);
        [self insertSubview:self.messageLabel belowSubview:self.textField];
        
        // Show placeholder to start off with.
        [self showPlaceholder:YES animated:NO];
    }
    return self;
}

- (NSString *)inputText {
    return self.textField.text;
}

- (void)setValidated:(BOOL)validated {
    
    // Change the validation icon image.
    self.validationImageView.image = [self validationImageForValidated:validated];
    
    // Figure out the end of the text.
    NSString *text = self.textField.text;
    CGFloat offset = self.password ? 10.0 : 5.0;
    CGSize size = [text sizeWithFont:self.textField.font constrainedToSize:self.textField.frame.size
                       lineBreakMode:NSLineBreakByClipping];
    CGPoint validationPoint = (CGPoint){
        floorf((self.textField.bounds.size.width - size.width) / 2.0) + size.width + offset,
        floor((self.textField.bounds.size.height - self.validationImageView.frame.size.height) / 2.0)
    };
    
    // Position it at the end of the text/caret.
    self.validationImageView.frame = (CGRect) {
        validationPoint.x,
        validationPoint.y,
        self.validationImageView.frame.size.width,
        self.validationImageView.frame.size.height
    };
    
    // Add it to textfield if not there already.
    if (!self.validationImageView.superview) {
        [self.textField addSubview:self.validationImageView];
    }
    
    // Mark as validated.
    self.dataValidated = validated;
}

- (void)setValidated:(BOOL)validated message:(NSString *)message {
    [self setValidated:validated];
    if ([message length] > 0) {
        self.messageLabel.textColor = validated ? kMessageColour : kMessageErrorColour;
        self.messageLabel.text = message;
    }
}

- (void)focusTextFieldView:(BOOL)focus {
    
    // Perform responder stuff on the main queue in next runloop to ensure it gets it.
    if (focus) {
        if (![self.textField isFirstResponder]) {
            [self.textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
        }
    } else {
        if ([self.textField isFirstResponder]) {
            [self.textField performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.0];
        }
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self clearValidation];
    [self focus:YES];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSString *text = [self trimmedTextFor:textField.text];
    textField.text = text;
    
    if ([text length] > 0) {
        [self.delegate didReturnForTextFieldView:self];
    } else {
        [self focus:NO];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Allow spaces?
    if (!self.allowSpaces && [newString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location != NSNotFound) {
        return NO;
    }
    
    // Max reached?
    if ([newString length] > self.maxLength) {
        return NO;
    }
    
    NSString *progressText = [self.delegate progressTextForTextFieldView:self currentText:newString];
    self.messageLabel.textColor = kMessageColour;
    self.messageLabel.text = progressText;
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
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [textField setSecureTextEntry:self.password];
        [textField sizeToFit];
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

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        CGSize size = [@"A" sizeWithFont:kMessageFont constrainedToSize:self.textField.bounds.size
                           lineBreakMode:NSLineBreakByTruncatingTail];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, size.height)];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = kMessageFont;
        messageLabel.textColor = kMessageColour;
        messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.shadowColor = [UIColor whiteColor];
        messageLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _messageLabel = messageLabel;
    }
    return _messageLabel;
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
    NSString *messageText = [self trimmedTextFor:self.messageLabel.text];
    BOOL messagePresent = ([messageText length] > 0);
    NSLog(@"focus[%@] messageText[%@] messagePresent[%@]", focus ? @"YES" : @"NO", messageText, messagePresent ? @"YES" : @"NO");
    
    // Always shifted up provided it's unfocused and no messages.
    CGRect frame = [self textFieldFrameForMessagePresent:YES];
    if (!focus && !messagePresent) {
        frame = [self textFieldFrameForMessagePresent:NO];
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.textField.frame = frame;
                         [self showPlaceholder:!focus animated:NO];
                     }
                     completion:^(BOOL finished) {
                     }];
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
        return [UIImage imageNamed:@"cook_signin_icon_okay.png"];
    } else {
        return [UIImage imageNamed:@"cook_signin_icon_error.png"];
    }
}

- (void)clearValidation {
    self.dataValidated = NO;
    [self.validationImageView removeFromSuperview];
}

@end
