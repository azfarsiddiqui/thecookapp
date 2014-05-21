//
//  RecipeFooterView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecipeDetails;

@interface RecipeFooterView : UIView

- (void)updateFooterWithRecipeDetails:(RecipeDetails *)recipeDetails;

@end
