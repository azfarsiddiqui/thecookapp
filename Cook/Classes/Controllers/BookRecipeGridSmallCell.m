//
//  BookRecipeGridSmallCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookRecipeGridSmallCell.h"
#import "RecipeIngredientsView.h"
#import "CKRecipe.h"

@implementation BookRecipeGridSmallCell

#define kImageTitleGap          50.0
#define kTitleIngredientsGap    30.0
#define kTitleStoryGap          45.0
#define kTitleMethodGap         45.0

- (UIEdgeInsets)contentInsets {
    UIEdgeInsets insets = [super contentInsets];
    insets.top += 10.0;
    return insets;
}

// Title always at the top.
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
        frame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + kImageTitleGap;
    }
    
    frame.size.width = size.width;
    frame.size.height = size.height;
    self.titleLabel.frame = frame;
}

- (void)updateIngredients {
    if ([self hasIngredients]) {
        
        // Image + Ingredients.
        self.ingredientsView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        [self.ingredientsView updateIngredients:self.recipe.ingredients];
        self.ingredientsView.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - self.ingredientsView.frame.size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleIngredientsGap + floorf(([self availableBlockSize].height - self.ingredientsView.frame.size.height) / 2.0),
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
        self.dividerImageView.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize size = [self.storyLabel sizeThatFits:[self availableBlockSize]];
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleStoryGap + floorf(([self availableBlockSize].height - size.height) / 2.0),
            size.width,
            size.height
        };
        
    } else {
        self.storyLabel.hidden = YES;
        self.dividerImageView.hidden = YES;
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
            self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleMethodGap + floorf(([self availableBlockSize].height - size.height) / 2.0),
            size.width,
            size.height
        };
        
    } else {
        self.methodLabel.hidden = YES;
    }
}

- (void)updateDividers {
    
    self.dividerImageView.hidden = NO;
    
    if ([self hasStory]) {
        
        self.dividerImageView.frame = [self centeredFrameBetweenView:self.titleLabel andView:self.storyLabel forView:self.dividerImageView];
        
    } else if ([self hasMethod]) {
        
        self.dividerImageView.frame = [self centeredFrameBetweenView:self.titleLabel andView:self.methodLabel forView:self.dividerImageView];
        
    } else if ([self hasIngredients]) {
        
        self.dividerImageView.frame = [self centeredFrameBetweenView:self.titleLabel andView:self.ingredientsView forView:self.dividerImageView];
        
    } else {
        self.dividerImageView.hidden = YES;
    }
    
}

@end
