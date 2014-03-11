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
#import "CKUserProfilePhotoView.h"

@implementation BookRecipeGridExtraSmallCell

#define kTimeGap        29.0
#define kAfterTimeGap   15.0

// Title centered vertically.
- (void)updateTitle {
    [super updateTitle];
    
    if (![self hasPhotos] && [self hasTitle]) {
        self.titleLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        CGSize availableSize = [self availableSize];
        CGSize size = [self.titleLabel sizeThatFits:[self availableSize]];
        self.titleLabel.frame = CGRectIntegral((CGRect){
            contentInsets.left + floorf((availableSize.width - size.width) / 2.0),
            floorf((self.statsView.frame.origin.y - size.height) / 2.0) + self.profilePhotoView.frame.size.height,
            size.width,
            size.height
        });
        
    } else {
        self.titleLabel.hidden = YES;
    }
}

- (void)updateTimeInterval {
    [super updateTimeInterval];
    
    UIEdgeInsets contentInsets = [self contentInsets];
    CGRect frame = self.timeIntervalLabel.frame;
    
    if (![self hasPhotos] && ![self hasTitle]) {
        frame.origin.y = contentInsets.top + 20.0;
    }
    
    self.timeIntervalLabel.frame = frame;
}

- (void)updateProfilePhoto {
    [super updateProfilePhoto];
    
    UIEdgeInsets contentInsets = [self contentInsets];
    CGRect frame = self.profilePhotoView.frame;
    CGSize availableSize = [self availableSize];
    frame.origin.x = contentInsets.left + floorf((availableSize.width - frame.size.width) / 2.0);
    
    if (self.titleLabel.hidden && !self.storyLabel.hidden) {
        frame.origin.y = self.timeIntervalLabel.frame.origin.y - frame.size.height - 12.0;
    }

    self.profilePhotoView.frame = frame;
}

- (void)updateIngredients {
    if ([self hasIngredients]) {
        
        // Ingredients only.
        self.ingredientsView.hidden = NO;
        
        CGSize blockSize = [self availableBlockSize];
        blockSize.height += 20.0;   // Have more vertical space.
        self.ingredientsView.maxSize = blockSize;
        
        UIEdgeInsets contentInsets = [self contentInsets];
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
        
        // Story only.
        self.storyLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        self.storyLabel.numberOfLines = 6;
        
        CGSize size = [self.storyLabel sizeThatFits:[self availableBlockSize]];
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kAfterTimeGap,
            size.width,
            size.height
        };
        
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateMethod {
    
    if (![self hasStory] && [self hasMethod]) {
        
        // Method only.
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        self.methodLabel.numberOfLines = 6;
        
        CGSize size = [self.methodLabel sizeThatFits:[self availableBlockSize]];
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kAfterTimeGap,
            size.width,
            size.height
        };
        
    } else {
        self.methodLabel.hidden = YES;
    }
}

@end
