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

@implementation BookRecipeGridLargeCell

#define kTitleIngredientsGap    10.0
#define kTitleStoryGap          45.0    // To make room for quote divider.
#define kTitleMethodGap         45.0
#define kIngredientsStoryGap    45.0
#define kIngredientsMethodGap   45.0

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

// Ingredients always comes next if it exists.
- (void)updateIngredients {
    if ([self hasIngredients]) {
        self.ingredientsView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        [self.ingredientsView updateIngredients:self.recipe.ingredients];
        self.ingredientsView.frame = (CGRect){
            contentInsets.left,
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleIngredientsGap,
            self.ingredientsView.frame.size.width,
            self.ingredientsView.frame.size.height
        };
        
    } else {
        self.ingredientsView.hidden = YES;
    }
}

- (void)updateStory {
    
    if (!self.imageView.hidden && [self hasTitle] && [self hasStory] && ![self hasMethod] && ![self hasIngredients]) {
        
        // Image + Title + Story
        self.storyLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize size = [self.storyLabel sizeThatFits:[self availableBlockSize]];
        self.storyLabel.frame = (CGRect){
            contentInsets.left,
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleStoryGap,
            size.width,
            size.height};
        
    } else if (self.imageView.hidden && [self hasIngredients] && [self hasStory] & ![self hasMethod]) {
    
        // Title + Ingredients + Story
        self.storyLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize size = [self.storyLabel sizeThatFits:[self availableBlockSize]];
        self.storyLabel.frame = (CGRect){
            contentInsets.left,
            self.ingredientsView.frame.origin.y + self.ingredientsView.frame.size.height + kIngredientsStoryGap,
            size.width,
            size.height};
        
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateMethod {
    
    if (!self.imageView.hidden && [self hasTitle] && ![self hasStory] && [self hasMethod] && ![self hasIngredients]) {
        
        // Image + Title + Method
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize size = [self.methodLabel sizeThatFits:[self availableBlockSize]];
        self.methodLabel.frame = (CGRect){
            contentInsets.left,
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleMethodGap,
            size.width,
            size.height};
        
    } else if (self.imageView.hidden && [self hasTitle] && ![self hasStory] && [self hasMethod] && [self hasIngredients]) {
        
        // Title + Ingredients + Method
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize size = [self.methodLabel sizeThatFits:[self availableBlockSize]];
        self.methodLabel.frame = (CGRect){
            contentInsets.left,
            self.ingredientsView.frame.origin.y + self.ingredientsView.frame.size.height + kIngredientsMethodGap,
            size.width,
            size.height};
        

    } else {
        self.methodLabel.hidden = YES;
    }
}

@end
