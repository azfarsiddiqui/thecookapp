//
//  CKEditingViewController.h
//  CKEditingViewControllerDemo
//
//  Created by Jeff Tan-Ang on 10/12/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKEditableView.h"
@protocol CKEditingViewControllerDelegate

- (void)editingViewWillAppear:(BOOL)appear;
- (void)editingViewDidAppear:(BOOL)appear;
- (void)editingView:(CKEditableView *)editingView saveRequestedWithResult:(id)result;

@end

@interface CKEditingViewController : UIViewController

@property (nonatomic, assign) id<CKEditingViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *editingTitle;
@property (nonatomic, strong) CKEditableView *sourceEditingView;
@property (nonatomic, strong) UIView *targetEditingView;
@property (nonatomic, assign) BOOL keyboardVisible;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, assign) CGRect transparentOverlayRect;

- (id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate;
- (id)initWithDelegate:(id<CKEditingViewControllerDelegate>)delegate sourceEditingView:(CKEditableView*)sourceEditingView;
- (void)enableEditing:(BOOL)enable completion:(void (^)())completion;
- (UIView *)createTargetEditingView;
- (UIImage *)imageForView:(UIView *)view;
- (UIImage *)imageForView:(UIView *)view opaque:(BOOL)opaque;
- (UIEdgeInsets)contentEdgeInsets;
- (void)editingViewWillAppear:(BOOL)appear;
- (void)editingViewDidAppear:(BOOL)appear;
- (void)editingViewKeyboardWillAppear:(BOOL)appear keyboardFrame:(CGRect)keyboardFrame;
- (void)doneTapped;
- (void)performSave;
- (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;

@end
