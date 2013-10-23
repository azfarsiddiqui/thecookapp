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
@class CKEditViewController;

@protocol CKEditViewControllerDelegate <NSObject>

- (void)editViewControllerWillAppear:(BOOL)appear;
- (void)editViewControllerDidAppear:(BOOL)appear;
- (void)editViewControllerDismissRequested;
- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value;

@optional
- (void)editViewControllerDidCreated;
- (BOOL)editViewControllerCanSaveFor:(CKEditViewController *)editViewController;
- (void)editViewControllerHeadlessUpdatedWithValue:(id)value;
- (id)editViewControllerInitialValueForEditView:(UIView *)editingView;

@end

@interface CKEditViewController : UIViewController

@property (nonatomic, weak) id<CKEditViewControllerDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSString *editTitle;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *sourceEditView;
@property (nonatomic, strong) UIView *targetEditView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, assign) BOOL dismissableOverlay;
@property (nonatomic, assign) BOOL showTitle;
@property (nonatomic, assign) BOOL white;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) CGRect keyboardFrame;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white;
- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title;

- (void)performEditing:(BOOL)editing;
- (void)performEditing:(BOOL)editing headless:(BOOL)headless transformOffset:(UIOffset)transformOffset;
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
- (CGRect)currentVisibleFrame;
- (CGRect)currentKeyboardFrame;
- (CGRect)defaultKeyboardFrame;
- (void)updateInfoLabels;
- (void)wrapTargetEditView:(UIView *)targetEditView delegate:(id<CKEditingTextBoxViewDelegate>)delegate;
- (void)wrapTargetEditView:(UIView *)targetEditView editMode:(BOOL)editMode delegate:(id<CKEditingTextBoxViewDelegate>)delegate;
- (BOOL)showTitleLabel;
- (BOOL)showSaveIcon;
- (BOOL)headless;
- (void)dismissEditView;
- (UIFont *)textFontWithSize:(CGFloat)size;
- (void)updateTitle:(NSString *)title;
- (void)updateTitle:(NSString *)title toast:(BOOL)toast;
- (void)doSave;

// Lifecycle events.
- (void)targetTextEditingViewDidCreated;
- (void)targetTextEditingViewWillAppear:(BOOL)appear;
- (void)targetTextEditingViewDidAppear:(BOOL)appear;
- (void)keyboardWillAppear:(BOOL)appear;

@end
