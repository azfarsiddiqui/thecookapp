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

- (void)editViewControllerDidAppear:(BOOL)appear;
- (void)editViewControllerDismissRequested;

@end

@interface CKEditViewController : UIViewController

@property (nonatomic, strong) UIColor *editingBackgroundColour;

- (id)initWithEditView:(UIView *)editView delegate:(id<CKEditViewControllerDelegate>)delegate
         editingHelper:(CKEditingViewHelper *)editingHelper;
- (void)performEditing:(BOOL)editing;
- (UIView *)createTargetEditView;

@end
