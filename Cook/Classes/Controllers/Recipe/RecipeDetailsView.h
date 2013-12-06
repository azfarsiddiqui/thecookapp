//
//  RecipeDetailsView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecipeDetails;
@class ProfileViewController;

@protocol RecipeDetailsViewDelegate <NSObject>

- (void)recipeDetailsViewEditing:(BOOL)editing;
- (void)recipeDetailsViewUpdated;
- (BOOL)recipeDetailsViewAddMode;
- (void)recipeDetailsViewProfileRequested;
@optional
- (void)recipeDetailsProfileTapped:(ProfileViewController *)bookViewController;

@end

@interface RecipeDetailsView : UIView

@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) UILabel *tagsLabel;

- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails delegate:(id<RecipeDetailsViewDelegate>)delegate;
- (id)initWithRecipeDetails:(RecipeDetails *)recipeDetails editMode:(BOOL)editMode
                   delegate:(id<RecipeDetailsViewDelegate>)delegate;
- (void)updateWithRecipeDetails:(RecipeDetails *)recipeDetails;
- (void)updateWithRecipeDetails:(RecipeDetails *)recipeDetails editMode:(BOOL)editMode;
- (void)enableEditMode:(BOOL)editMode;

@end
