//
//  EditingViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 3/21/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKEditableView.h"
@protocol EditingViewControllerDelegate

- (void)editingViewWillAppear:(BOOL)appear;
- (void)editingViewDidAppear:(BOOL)appear;
- (void)editingView:(CKEditableView *)editingView saveRequestedWithResult:(id)result;
@end

@interface EditingViewController : UIViewController
@property (nonatomic, assign) id<EditingViewControllerDelegate> delegate;
@property (nonatomic, strong) CKEditableView *sourceEditingView;
@property (nonatomic, strong) UIView *targetEditingView;
@property (nonatomic,assign)  UIEdgeInsets contentViewInsets;
@property (nonatomic, strong) UIButton *doneButton;

//initialization
- (id)initWithDelegate:(id<EditingViewControllerDelegate>)delegate;
- (id)initWithDelegate:(id<EditingViewControllerDelegate>)delegate sourceEditingView:(CKEditableView*)sourceEditingView;

//view lifecyles/creation
- (UIView *) createTargetEditingView;
- (void) editingViewWillAppear:(BOOL)appear;
- (void) editingViewDidAppear:(BOOL)appear;

//actions
- (void) enableEditing:(BOOL)enable completion:(void (^)())completion;
- (void) performSave;
- (void) doneTapped;

@end
