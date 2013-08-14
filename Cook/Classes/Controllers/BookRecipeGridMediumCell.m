//
//  BookRecipeGridMediumCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookRecipeGridMediumCell.h"
#import "RecipeIngredientsView.h"
#import "CKRecipe.h"

@implementation BookRecipeGridMediumCell

#define kImageStoryGap          45.0
#define kImageMethodGap         45.0
#define kImageIngredientsGap    20.0

- (void)updateIngredients {
    if ([self hasIngredients]) {
        
        // Image + Ingredients.
        self.ingredientsView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        [self.ingredientsView updateIngredients:self.recipe.ingredients];
        self.ingredientsView.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - self.ingredientsView.frame.size.width) / 2.0),
            self.imageView.frame.origin.y + self.imageView.frame.size.height + kImageIngredientsGap,
            self.ingredientsView.frame.size.width,
            self.ingredientsView.frame.size.height
        };
        
    } else {
        self.ingredientsView.hidden = YES;
    }
}

- (void)updateStory {
    
    if ([self hasStory]) {
        
        // Image + Story.
        self.storyLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize size = [self.storyLabel sizeThatFits:[self availableBlockSize]];
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.imageView.frame.origin.y + self.imageView.frame.size.height + kImageStoryGap,
            size.width,
            size.height
        };
        
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateMethod {
    
    if ([self hasMethod]) {
        
        // Image + Method
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize size = [self.methodLabel sizeThatFits:[self availableBlockSize]];
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kImageMethodGap,
            size.width,
            size.height
        };
        
    } else {
        self.methodLabel.hidden = YES;
    }
}

@end
