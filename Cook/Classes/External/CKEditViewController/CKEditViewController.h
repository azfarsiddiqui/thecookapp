//
//  CKEditViewController.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKEditViewController : UIViewController

@property (nonatomic, strong) UIColor *editingBackgroundColour;

- (id)initWithEditView:(UIView *)editView;
- (id)initWithEditView:(UIView *)editView contentInsets:(UIEdgeInsets)contentInsets;
- (void)performEditing:(BOOL)editing;

@end
