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
#import "GridRecipeStatsView.h"

@implementation BookRecipeGridMediumCell

#define kTimeGap                29.0
#define kAfterTimeGap           15.0

- (void)updateTimeInterval {
    [super updateTimeInterval];
    
    UIEdgeInsets contentInsets = [self contentInsets];
    
    if (![self hasTitle]) {
        self.timeIntervalLabel.frame = (CGRect){
            floorf((self.contentView.bounds.size.width - self.timeIntervalLabel.frame.size.width) / 2.0),
            self.imageView.frame.origin.y + self.imageView.frame.size.height + contentInsets.top,
            self.timeIntervalLabel.frame.size.width,
            self.timeIntervalLabel.frame.size.height
        };
    }
}

- (void)updateIngredients {
    
    if ([self hasIngredients]) {
        
        // Image + Ingredients.
        self.ingredientsView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        CGSize blockSize = [self availableBlockSize];
        blockSize.height -= 30.0;   // Have more vertical space.
        self.ingredientsView.maxSize = blockSize;
        
        [self.ingredientsView updateIngredients:self.recipe.ingredients book:self.book];
        self.ingredientsView.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - self.ingredientsView.frame.size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kAfterTimeGap,
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
        self.storyLabel.numberOfLines = 0;
        self.storyLabel.text = story;
        CGSize blockSize = [self availableBlockSize];
        blockSize.height = self.statsView.frame.origin.y - self.timeIntervalLabel.frame.origin.y - self.timeIntervalLabel.frame.size.height - kAfterTimeGap;
        CGSize size = [self.storyLabel sizeThatFits:blockSize];
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kAfterTimeGap,
            size.width,
            (size.height > blockSize.height ? blockSize.height : size.height)
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
        self.methodLabel.numberOfLines = 4;
        self.methodLabel.text = method;
        CGSize blockSize = [self availableBlockSize];
        blockSize.height = self.statsView.frame.origin.y - self.timeIntervalLabel.frame.origin.y - self.timeIntervalLabel.frame.size.height - kAfterTimeGap;
        CGSize size = [self.methodLabel sizeThatFits:blockSize];
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kAfterTimeGap,
            size.width,
            (size.height > blockSize.height ? blockSize.height : size.height)
        };
        
    } else {
        self.methodLabel.hidden = YES;
    }
}

@end
