//
//  RecipeSearchViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/03/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "OverlayViewController.h"

@protocol RecipeSearchViewControllerDelegate <NSObject>

- (void)recipeSearchViewControllerDismissRequested;
- (UIImage *)recipeSearchBlurredImageForDash;

@end

@interface RecipeSearchViewController : OverlayViewController

- (id)initWithDelegate:(id<RecipeSearchViewControllerDelegate>)delegate;
- (void)focusSearchField:(BOOL)focus;

@end
