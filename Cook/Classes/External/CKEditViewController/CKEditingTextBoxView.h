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

@property (nonatomic, weak) id<CKEditingTextBoxViewDelegate> delegate;
@property (nonatomic, assign) CGRect editViewFrame;
@property (nonatomic, assign) UIEdgeInsets contentInsets;

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;
+ (UIImage *)textEditingBoxWhite:(BOOL)white;
+ (UIImage *)textEditingBoxWhite:(BOOL)white editMode:(BOOL)editMode;
+ (UIImage *)textEditingBoxWhite:(BOOL)white editMode:(BOOL)editMode selected:(BOOL)selected;
+ (UIImage *)textEditingSelectionBoxWhite:(BOOL)white;
+ (UIImage *)textEditingSelectionBoxWhite:(BOOL)white selected:(BOOL)selected;

- (id)initWithEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
                  delegate:(id<CKEditingTextBoxViewDelegate>)delegate;
- (id)initWithEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
                 editMode:(BOOL)editMode delegate:(id<CKEditingTextBoxViewDelegate>)delegate;
- (id)initWithEditingView:(UIView *)editingView contentInsets:(UIEdgeInsets)contentInsets white:(BOOL)white
                 editMode:(BOOL)editMode onpress:(BOOL)onpress delegate:(id<CKEditingTextBoxViewDelegate>)delegate;
- (void)updateEditingView:(UIView *)editingView;
- (void)updateEditingView:(UIView *)editingView updated:(BOOL)updated;
- (CGRect)updatedFrameForProposedEditingViewFrame:(CGRect)editViewFrame;
- (void)showSaveIcon:(BOOL)show animated:(BOOL)animated;
- (void)showSaveIcon:(BOOL)show enabled:(BOOL)enabled animated:(BOOL)animated;
- (CGRect)textBoxFrame;
- (void)setTextBoxViewWithEdit:(BOOL)editMode;

@end
