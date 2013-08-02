//
//  BookNavigationViewControllerDelegate.h
//  Cook
//
//  Created by Jeff Tan-Ang on 2/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKRecipe;
@class CKCategory;

@protocol BookNavigationViewControllerDelegate

- (void)bookNavigationControllerCloseRequested;
- (void)bookNavigationControllerRecipeRequested:(CKRecipe *)recipe;
- (void)bookNavigationControllerAddRecipeRequestedForCategory:(CKCategory *)category;
- (UIView *)bookNavigationSnapshot;

@end