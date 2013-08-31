//
//  RecipeShareViewController.h
//  Cook
//
//  Created by Gerald Kim on 31/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@protocol RecipeShareViewControllerDelegate <NSObject>

- (void)recipeShareViewControllerCloseRequested;

@end

@interface RecipeShareViewController : UIViewController

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeShareViewControllerDelegate>)delegate;

@end
