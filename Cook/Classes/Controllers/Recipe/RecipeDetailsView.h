//
//  RecipeDetailsView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecipeDetails;

@protocol RecipeDetailsViewDelegate <NSObject>

- (void)recipeDetailsViewEditing:(BOOL)editing;
- (void)recipeDetailsViewUpdated;

@end

@interface RecipeDetailsView : UIView

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails delegate:(id<RecipeDetailsViewDelegate>)delegate;
- (void)enableEditMode:(BOOL)editMode;

@end
