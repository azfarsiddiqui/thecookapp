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

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap white:(BOOL)white animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                  white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                  white:(BOOL)white animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap delegate:(id<CKEditingTextBoxViewDelegate>)delegate
                  white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap delegate:(id<CKEditingTextBoxViewDelegate>)delegate
                white:(BOOL)white animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
               delegate:(id<CKEditingTextBoxViewDelegate>)delegate white:(BOOL)white animated:(BOOL)animated;

- (void)updateEditingView:(UIView *)editingView;
- (void)updateEditingView:(UIView *)editingView animated:(BOOL)animated;
- (CKEditingTextBoxView *)textBoxViewForEditingView:(UIView *)editingView;

@end
