//
//  BookNavigationViewControllerDelegate.h
//  Cook
//
//  Created by Jeff Tan-Ang on 2/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKRecipe;
@class CKBook;

@protocol BookNavigationViewControllerDelegate <NSObject>

- (void)bookNavigationControllerCloseRequested;
- (void)bookNavigationControllerCloseRequestedWithBinder;
- (void)bookNavigationControllerRecipeRequested:(CKRecipe *)recipe;
- (void)bookNavigationControllerAddRecipeRequestedForPage:(NSString *)page;
- (void)bookNavigationControllerRefreshedBook:(CKBook *)book;
- (UIView *)bookNavigationSnapshot;

@end