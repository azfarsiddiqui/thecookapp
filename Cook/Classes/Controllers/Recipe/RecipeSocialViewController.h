//
//  RecipeSocialViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"
#import "CKNavigationController.h"

@class CKRecipe;
@class CKLikeView;

@protocol RecipeSocialViewControllerDelegate <NSObject>

- (void)recipeSocialViewControllerCloseRequested;

@optional
- (CKLikeView *)recipeSocialViewControllerLikeView;

@end

@interface RecipeSocialViewController : OverlayViewController

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeSocialViewControllerDelegate>)delegate;
- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeSocialViewControllerDelegate>)delegate commentActive:(BOOL)isActive;

- (NSInteger)currentNumComments;

@end
