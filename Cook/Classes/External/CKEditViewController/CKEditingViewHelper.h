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
               animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white animated:(BOOL)animated;

// Updates the editing box around an updated editingView.
- (void)updateEditingView:(UIView *)editingView;
- (void)updateEditingView:(UIView *)editingView animated:(BOOL)animated;

// Returns the textbox view for the given editingView.
- (CKEditingTextBoxView *)textBoxViewForEditingView:(UIView *)editingView;

@end
