//
//  CKEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKEditingTextBoxView.h"

@class CKEditingViewHelper;

@protocol CKEditViewControllerDelegate <NSObject>

- (void)editViewControllerWillAppear:(BOOL)appear;
- (void)editViewControllerDidAppear:(BOOL)appear;
- (void)editViewControllerDismissRequested;
- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value;

@optional
- (void)editViewControllerDidCreated;

@end

@interface CKEditViewController : UIViewController

@property (nonatomic, assign) id<CKEditViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *editTitle;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *sourceEditView;
@property (nonatomic, strong) UIView *targetEditView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, assign) BOOL dismissableOverlay;
@property (nonatomic, assign) BOOL white;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white;
- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title;

- (void)performEditing:(BOOL)editing;
- (UIView *)createTargetEditView;
- (NSString *)currentTextValue;
- (id)updatedValue;
- (UIColor *)editingTextColour;
- (UIColor *)editingBackgroundColour;
- (UIColor *)editingOverlayColour;
- (UIColor *)titleColour;
- (UIEdgeInsets)contentInsets;
- (CKEditingTextBoxView *)sourceEditTextBoxView;
- (CKEditingTextBoxView *)targetEditTextBoxView;
- (CKEditingTextBoxView *)mockedEditTextBoxView;
- (CGRect)currentKeyboardFrame;
- (CGRect)defaultKeyboardFrame;
- (void)updateInfoLabels;
- (void)wrapTargetEditView:(UIView *)targetEditView delegate:(id<CKEditingTextBoxViewDelegate>)delegate;
- (BOOL)showTitleLabel;
- (BOOL)showSaveIcon;
- (void)dismissEditView;
- (void)keyboardWillAppear:(BOOL)appear;

// Lifecycle events.
- (void)targetTextEditingViewDidCreated;
- (void)targetTextEditingViewWillAppear:(BOOL)appear;
- (void)targetTextEditingViewDidAppear:(BOOL)appear;

@end
