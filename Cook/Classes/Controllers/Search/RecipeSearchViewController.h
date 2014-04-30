//
//  RecipeSearchViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/03/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "OverlayViewController.h"
#import "AppModalViewController.h"

@class CKRecipe;

@protocol RecipeSearchViewControllerDelegate <NSObject>

- (void)recipeSearchViewControllerDismissRequested;
- (UIImage *)recipeSearchBlurredImageForDash;

@end

@interface RecipeSearchViewController : OverlayViewController <AppModalViewController>

- (id)initWithDelegate:(id<RecipeSearchViewControllerDelegate>)delegate;
- (void)focusSearchField:(BOOL)focus;

@end
