//
//  BookRecipeGridLargeCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookRecipeGridLargeCell.h"
#import "RecipeIngredientsView.h"
#import "CKRecipe.h"
#import "GridRecipeStatsView.h"

@implementation BookRecipeGridLargeCell

#define kTitleIngredientsGap    10.0
#define kTitleStoryGap          45.0    // To make room for quote divider.
#define kTitleMethodGap         45.0
#define kStoryStatsGap          20.0
#define kMethodStatsGap         20.0

// Title always come first.
- (void)updateTitle {
    [super updateTitle];
    
    UIEdgeInsets contentInsets = [self contentInsets];
    CGRect frame = self.titleLabel.frame;
    CGSize availableSize = [self availableSize];
    CGSize size = [self.titleLabel sizeThatFits:availableSize];
    frame.origin.x = contentInsets.left + floorf((availableSize.width - size.width) / 2.0);
    
    if (self.imageView.hidden) {
        frame.origin.y = contentInsets.top;
    } else {
        frame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + contentInsets.top;
    }
    
    frame.size.width = size.width;
    frame.size.height = size.height;
    self.titleLabel.frame = frame;
}

- (void)updateIngredients {
    
    // Ingredients appear only in the following situations:
    //
    // 1. +Photo +Title -Story -Method +Ingredients
    // 2. -Photo +Title (+/-)Story (+/-)Method +Ingredients
    //
    if (([self hasPhotos] && [self hasTitle] && ![self hasStory] && ![self hasMethod] && [self hasIngredients] )
        || (![self hasPhotos] && [self hasTitle] && [self hasIngredients])) {
        
        self.ingredientsView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        [self.ingredientsView updateIngredients:self.recipe.ingredients];
      
        // And it only appears after title.
        self.ingredientsView.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - self.ingredientsView.frame.size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleIngredientsGap,
            self.ingredientsView.frame.size.width,
            self.ingredientsView.frame.size.height
        };
        
    } else {
        self.ingredientsView.hidden = YES;
    }
}

- (void)updateStory {
    
    if ([self hasPhotos] && [self hasTitle] && [self hasStory]) {
        
        // +Photo +Title +Story (+/-)Method (+/-)Ingredients
        self.storyLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize size = [self.storyLabel sizeThatFits:[self availableBlockSize]];
        CGSize availableSize = [self availableSize];
        
        // And it comes after Title.
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf((availableSize.width - size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleStoryGap,
            size.width,
            size.height};
        
    } else if (![self hasPhotos] && [self hasTitle] && [self hasStory] && [self hasIngredients]) {
    
        // -Photo +Title +Story (+/-)Method +Ingredients
        self.storyLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize availableSize = [self availableSize];
        CGSize blockSize = [self availableBlockSize];
        CGSize size = [self.storyLabel sizeThatFits:blockSize];
        
        // And it comes before stats view (ingredientsView not rendered yet).
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf((availableSize.width - size.width) / 2.0),
            self.statsView.frame.origin.y - kStoryStatsGap - blockSize.height + floorf((blockSize.height - size.height) / 2.0),
            size.width,
            size.height};
        
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateMethod {
    
    if ([self hasPhotos] && [self hasTitle] && ![self hasStory] && [self hasMethod]) {
        
        // +Photo +Title -Story +Method (+/-)Ingredients
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize size = [self.methodLabel sizeThatFits:[self availableBlockSize]];
        
        // Comes after Title.
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleMethodGap,
            size.width,
            size.height
        };
        
    } else if (![self hasPhotos] && [self hasTitle] && ![self hasStory] && [self hasMethod] && [self hasIngredients]) {
        
        // -Photo +Title -Story +Method +Ingredients
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize blockSize = [self availableBlockSize];
        CGSize size = [self.methodLabel sizeThatFits:blockSize];
        
        // And it comes before stats view (ingredientsView not rendered yet).
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.statsView.frame.origin.y - kMethodStatsGap - blockSize.height + floorf((blockSize.height - size.height) / 2.0),
            size.width,
            size.height
        };
        

    } else {
        self.methodLabel.hidden = YES;
    }
}

@end
