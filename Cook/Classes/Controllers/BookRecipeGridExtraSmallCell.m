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

#define kTimeGap        29.0
#define kStandardGap    30.0

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
            floorf((self.statsView.frame.origin.y - size.height) / 2.0),
            size.width,
            size.height
        };
        
    } else {
        self.titleLabel.hidden = YES;
    }
}

- (void)updateTimeInterval {
    [super updateTimeInterval];
    if (![self hasTitle]) {
        self.timeIntervalLabel.frame = (CGRect){
            floorf((self.contentView.bounds.size.width - self.timeIntervalLabel.frame.size.width) / 2.0),
            kTimeGap,
            self.timeIntervalLabel.frame.size.width,
            self.timeIntervalLabel.frame.size.height
        };
    }
}

- (void)updateIngredients {
    if ([self hasIngredients]) {
        
        // Ingredients only.
        self.ingredientsView.hidden = NO;
        
        CGSize blockSize = [self availableBlockSize];
        blockSize.height += 30.0;   // Have more vertical space.
        self.ingredientsView.maxSize = blockSize;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        [self.ingredientsView updateIngredients:self.recipe.ingredients book:self.book];
        self.ingredientsView.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - self.ingredientsView.frame.size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kStandardGap,
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
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize size = [self.storyLabel sizeThatFits:[self availableBlockSize]];
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kStandardGap,
            size.width,
            size.height
        };
        
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateMethod {
    
    if ([self hasMethod]) {
        
        // Method only.
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize size = [self.methodLabel sizeThatFits:[self availableBlockSize]];
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kStandardGap,
            size.width,
            size.height
        };
        
    } else {
        self.methodLabel.hidden = YES;
    }
}

@end
