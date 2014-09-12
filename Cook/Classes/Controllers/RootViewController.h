//
//  CKViewController.h
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModalViewController.h"
#import "AppModalViewControllerDelegate.h"

@class CKRecipe;
@class CKBook;

@interface RootViewController : UIViewController <AppModalViewControllerDelegate, AppModalViewController>

- (void)showModalWithRecipeID:(NSString *)recipeID;
- (void)showModalWithRecipe:(CKRecipe *)recipe;
- (void)showModalWithRecipe:(CKRecipe *)recipe book:(CKBook *)book statusBarUpdate:(BOOL)statusBarUpdate;
- (void)showModalWithRecipe:(CKRecipe *)recipe
       callerViewController:(UIViewController<AppModalViewController> *)callerViewController;
- (void)showModalWithRecipe:(CKRecipe *)recipe book:(CKBook *)book statusBarUpdate:(BOOL)statusBarUpdate
       callerViewController:(UIViewController<AppModalViewController> *)callerViewController;

- (void)showModalWithRecipeID:(NSString *)recipeID;

@end
