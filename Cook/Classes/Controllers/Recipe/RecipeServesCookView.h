//
//  RecipeServesCookView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecipeDetails;

@interface RecipeServesCookView : UIView

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails editMode:(BOOL)editMode;
- (void)updateWithRecipeDetails:(RecipeDetails *)recipeDetails editMode:(BOOL)editMode;

@end
