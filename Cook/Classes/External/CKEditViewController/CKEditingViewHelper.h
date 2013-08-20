//
//  CKEditingViewHelper.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKEditingTextBoxView.h"

@class CKEditingTextBoxView;

@interface CKEditingViewHelper : NSObject

+ (CGFloat)singleLineHeightForFont:(UIFont *)font size:(CGSize)size;

// Unwraps editing box around the given editingView.
- (void)unwrapEditingView:(UIView *)editingView;
- (void)unwrapEditingView:(UIView *)editingView animated:(BOOL)animated;

// Wraps the given with configured editingView.
- (void)wrapEditingView:(UIView *)editingView white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView white:(BOOL)white animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
                  white:(BOOL)white animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white
               editMode:(BOOL)editMode;
- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white
               animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white
               editMode:(BOOL)editMode animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white editMode:(BOOL)editMode;
- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white editMode:(BOOL)editMode
               animated:(BOOL)animated;

// Checks wrappign.
- (BOOL)alreadyWrappedForEditingView:(UIView *)editingView;

// Updates the editing box around an updated editingView.
- (void)updateEditingView:(UIView *)editingView;
- (void)updateEditingView:(UIView *)editingView animated:(BOOL)animated;
- (void)updateEditingView:(UIView *)editingView updated:(BOOL)updated animated:(BOOL)animated;

// Returns the textbox view for the given editingView.
- (CKEditingTextBoxView *)textBoxViewForEditingView:(UIView *)editingView;

// Default box insets for edit/non-edit mode.
+ (UIEdgeInsets)contentInsetsForEditMode:(BOOL)editMode;
+ (UIEdgeInsets)textBoxInsets;

// Buttons.
+ (UIButton *)okayButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)cancelButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)deleteButtonWithTarget:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target
                     selector:(SEL)selector;

@end
