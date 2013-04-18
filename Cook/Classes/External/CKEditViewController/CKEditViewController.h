//
//  CKEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKEditingViewHelper;
@class CKEditingTextBoxView;

@protocol CKEditViewControllerDelegate <NSObject>

- (void)editViewControllerWillAppear:(BOOL)appear;
- (void)editViewControllerDidAppear:(BOOL)appear;
- (void)editViewControllerDismissRequested;
- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value;

@end

@interface CKEditViewController : UIViewController

@property (nonatomic, strong) NSString *editTitle;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *sourceEditView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, assign) BOOL dismissableOverlay;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white;
- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white title:(NSString *)title;

- (void)performEditing:(BOOL)editing;
- (UIView *)createTargetEditView;
- (NSString *)currentTextValue;
- (NSString *)updatedTextValue;
- (UIColor *)editingTextColour;
- (UIColor *)editingBackgroundColour;
- (UIColor *)editingOverlayColour;
- (UIColor *)titleColour;
- (UIEdgeInsets)contentInsets;
- (CKEditingTextBoxView *)sourceEditTextBoxView;
- (CKEditingTextBoxView *)targetEditTextBoxView;
- (CKEditingTextBoxView *)mockedEditTextBoxView;
- (CGRect)currentKeyboardFrame;
- (void)updateTitleLabel;

// Lifecycle events.
- (void)targetTextEditingViewWillAppear:(BOOL)appear;
- (void)targetTextEditingViewDidAppear:(BOOL)appear;

@end
