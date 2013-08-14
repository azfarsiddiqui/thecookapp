//
//  BookRecipeGridExtraSmallCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookRecipeGridExtraSmallCell.h"
#import "RecipeIngredientsView.h"
#import "CKRecipe.h"
#import "GridRecipeStatsView.h"

@implementation BookRecipeGridExtraSmallCell

#define kStoryGap       45.0
#define kMethodGap      45.0

// Title centered vertically.
- (void)updateTitle {
    [super updateTitle];
    
    if ([self hasTitle]) {
        self.titleLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        CGSize availableSize = [self availableSize];
        CGSize size = [self.titleLabel sizeThatFits:[self availableSize]];
        self.titleLabel.frame = (CGRect){
            contentInsets.left + floorf((availableSize.width - size.width) / 2.0),
            contentInsets.top + floorf((self.statsView.frame.origin.y - size.height) / 2.0),
            size.width,
            size.height
        };
        
    } else {
        self.titleLabel.hidden = YES;
    }
}

- (void)updateIngredients {
    if ([self hasIngredients]) {
        
        // Ingredients only.
        self.ingredientsView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        [self.ingredientsView updateIngredients:self.recipe.ingredients];
        self.ingredientsView.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - self.ingredientsView.frame.size.width) / 2.0),
            contentInsets.top + floorf(([self availableBlockSize].height - self.ingredientsView.frame.size.height) / 2.0),
            self.ingredientsView.frame.size.width,
            self.ingredientsView.frame.size.height
        };
        
    } else {
        self.ingredientsView.hidden = YES;
    }
}

- (void)updateStory {
    
    if ([self hasStory]) {
        
        // Story only.
        self.storyLabel.hidden = NO;
        self.dividerQuoteImageView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize size = [self.storyLabel sizeThatFits:[self availableBlockSize]];
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            kStoryGap + floorf(([self availableBlockSize].height - size.height) / 2.0),
            size.width,
            size.height
        };
        
    } else {
        self.storyLabel.hidden = YES;
        self.dividerQuoteImageView.hidden = YES;
    }
}

- (void)updateMethod {
    
    if ([self hasMethod]) {
        
        // Method only.
        self.methodLabel.hidden = NO;
        self.dividerQuoteImageView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize size = [self.methodLabel sizeThatFits:[self availableBlockSize]];
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            kMethodGap + floorf(([self availableBlockSize].height - size.height) / 2.0),
            size.width,
            size.height
        };
        
//        self.dividerQuoteImageView.frame = (CGRect){
//            floorf((self.contentView.bounds.size.width - self.dividerQuoteImageView.frame.size.width) / 2.0),
//            
//        };
        
    } else {
        self.methodLabel.hidden = YES;
        self.dividerQuoteImageView.hidden = YES;
    }
}

@end
