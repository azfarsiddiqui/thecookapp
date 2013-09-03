//
//  CKTextFieldView.h
//  CKTextFieldDemo
//
//  Created by Jeff Tan-Ang on 27/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKTextFieldView;

@protocol CKTextFieldViewDelegate <NSObject>

- (NSString *)progressTextForTextFieldView:(CKTextFieldView *)textFieldView currentText:(NSString *)text;
- (void)didEndForTextFieldView:(CKTextFieldView *)textFieldView;
- (void)didReturnForTextFieldView:(CKTextFieldView *)textFieldView;

@end

@interface CKTextFieldView : UIView

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) BOOL password;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColour;
@property (nonatomic, strong) UIFont *placeholderFont;
@property (nonatomic, strong) UIColor *placeholderColour;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, assign) BOOL allowSpaces;
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, assign) BOOL dataValidated;

- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder;
- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password;
- (id)initWithWidth:(CGFloat)width delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password contentInsets:(UIEdgeInsets)contentInsets;

- (NSString *)inputText;
- (void)setValidated:(BOOL)validated;
- (void)setValidated:(BOOL)validated message:(NSString *)message;
- (void)focusTextFieldView:(BOOL)focus;
- (void)setText:(NSString *)text;

@end
