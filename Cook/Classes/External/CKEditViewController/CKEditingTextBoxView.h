//
//  CKEditingTextBoxView.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKEditingTextBoxViewDelegate <NSObject>

@optional
- (void)editingTextBoxViewTappedForEditingView:(UIView *)editingView;
- (void)editingTextBoxViewSaveTappedForEditingView:(UIView *)editingView;

@end

@interface CKEditingTextBoxView : UIView

@property (nonatomic, assign) CGRect editViewFrame;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

- (id)initWithEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
                  delegate:(id<CKEditingTextBoxViewDelegate>)delegate;
- (void)updateEditingView:(UIView *)editingView;
- (CGRect)updatedFrameForProposedEditingViewFrame:(CGRect)editViewFrame;
- (void)showEditingIcon:(BOOL)show animated:(BOOL)animated;
- (void)showSaveIcon:(BOOL)show animated:(BOOL)animated;
- (void)showSaveIcon:(BOOL)show enabled:(BOOL)enabled animated:(BOOL)animated;
- (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;

@end
