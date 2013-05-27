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

- (void)textFieldViewDidSubmit:(CKTextFieldView *)textFieldView;
- (BOOL)textFieldViewShouldSubmit:(CKTextFieldView *)textFieldView;

@end

@interface CKTextFieldView : UIView

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) BOOL password;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColour;
@property (nonatomic, strong) UIFont *placeholderFont;
@property (nonatomic, strong) UIColor *placeholderColour;
@property (nonatomic, strong) NSString *placeholder;

- (id)initWithFrame:(CGRect)frame delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder;
- (id)initWithFrame:(CGRect)frame delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password;
- (id)initWithFrame:(CGRect)frame delegate:(id<CKTextFieldViewDelegate>)delegate placeholder:(NSString *)placeholder
           password:(BOOL)password contentInsets:(UIEdgeInsets)contentInsets;
- (NSString *)inputText;

@end
