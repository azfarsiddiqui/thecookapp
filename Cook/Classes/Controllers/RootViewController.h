//
//  CKViewController.h
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookModalViewControllerDelegate.h"

@class CKRecipe;
@class CKBook;

@interface RootViewController : UIViewController <BookModalViewControllerDelegate>

- (void)showModalWithRecipe:(CKRecipe *)recipe;
- (void)showModalWithRecipe:(CKRecipe *)recipe callerView:(UIView *)callerView;
- (void)showModalWithRecipe:(CKRecipe *)recipe callerViews:(NSArray *)callerViews;
- (void)showModalWithRecipe:(CKRecipe *)recipe book:(CKBook *)book statusBarUpdate:(BOOL)statusBarUpdate
                callerViews:(NSArray *)callerViews;

@end
