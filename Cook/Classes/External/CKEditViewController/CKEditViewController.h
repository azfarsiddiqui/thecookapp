//
//  CKEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKEditingViewHelper;

@protocol CKEditViewControllerDelegate <NSObject>

- (void)editViewControllerWillAppear:(BOOL)appear;
- (void)editViewControllerDidAppear:(BOOL)appear;
- (void)editViewControllerDismissRequested;
- (void)editViewControllerUpdateEditView:(UIView *)editingView value:(id)value;

@end

@interface CKEditViewController : UIViewController

@property (nonatomic, strong) UIView *originalEditView;
@property (nonatomic, strong) UIView *targetEditView;
@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, assign) BOOL dismissableOverlay;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper white:(BOOL)white;
- (void)performEditing:(BOOL)editing;
- (UIView *)createTargetEditView;
- (NSString *)currentTextValue;
- (NSString *)updatedTextValue;
- (UIColor *)editingTextColour;
- (UIColor *)editingBackgroundColour;
- (UIColor *)editingOverlayColour;
- (UIColor *)titleColour;

// Lifecycle events.
- (void)targetTextEditingViewWillAppear:(BOOL)appear;
- (void)targetTextEditingViewDidAppear:(BOOL)appear;

@end
