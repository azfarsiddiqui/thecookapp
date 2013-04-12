//
//  CKEditingViewHelper.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKEditingTextBoxView;

@interface CKEditingViewHelper : NSObject

- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
               animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap target:(id)target selector:(SEL)selector;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap target:(id)target selector:(SEL)selector
               animated:(BOOL)animated;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                 target:(id)target selector:(SEL)selector;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets
                 target:(id)target selector:(SEL)selector animated:(BOOL)animated;
- (CKEditingTextBoxView *)textBoxViewForEditingView:(UIView *)editingView;

@end
