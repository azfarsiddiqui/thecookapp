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
#define kTitleStoryGap          20.0    // To make room for quote divider.
#define kTitleMethodGap         20.0
#define kStoryStatsGap          20.0
#define kMethodStatsGap         20.0
#define kTimeAfterGap           10.0
#define kIngredientsMethodGap   20.0
#define kIngredientsStoryGap    20.0

// Title always come first.
- (void)updateTitle {
    [super updateTitle];
    
    UIEdgeInsets contentInsets = [self contentInsets];
    CGRect frame = self.titleLabel.frame;
    CGSize availableSize = [self availableSize];
    CGSize size = [self.titleLabel sizeThatFits:availableSize];
    
    frame.origin.x = contentInsets.left + floorf((availableSize.width - size.width) / 2.0);
    
    if (self.imageView.hidden) {
        frame.origin.y = contentInsets.top + 20.0;
    } else {
        frame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + contentInsets.top;
    }
    
    frame.size.width = size.width;
    frame.size.height = size.height;
    self.titleLabel.frame = CGRectIntegral(frame);
}

- (void)updateIngredients {
    
    // Ingredients appear only in the following situations:
    //
    // 1. +Photo +Title -Story -Method +Ingredients
    // 2. -Photo +Title +Ingredients (+/-)Story (+/-)Method
    // 2. -Photo -Title +Ingredients (+/-)Story (+/-)Method
    //
    // DONE
    if (([self hasPhotos] && [self hasTitle] && ![self hasStory] && ![self hasMethod] && [self hasIngredients])
        || (![self hasPhotos] && [self hasTitle] && [self hasIngredients])
        || (![self hasPhotos] && ![self hasTitle] && [self hasStory])
        || (![self hasPhotos] && ![self hasTitle] && ![self hasStory])
        ) {
        
        self.ingredientsView.hidden = NO;
        CGSize blockSize = [self availableBlockSize];
        if (![self multilineTitle]) {
            blockSize.height += 30.0;
        }
        self.ingredientsView.maxSize = blockSize;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        [self.ingredientsView updateIngredients:self.recipe.ingredients book:self.book];
      
        // And it only appears after time.
        self.ingredientsView.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - self.ingredientsView.frame.size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kTimeAfterGap,
            self.ingredientsView.frame.size.width,
            self.ingredientsView.frame.size.height
        };
        
    } else {
        self.ingredientsView.hidden = YES;
    }
}

- (void)updateStory {
    
    // Reset the number of lines.
    self.storyLabel.numberOfLines = [self maxStoryLines];
    
    // DONE
    if ([self hasPhotos] && [self hasTitle] && [self hasStory]) {
        
        // +Photo +Title +Story (+/-)Method (+/-)Ingredients
        self.storyLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *story = self.recipe.story;
        self.storyLabel.text = story;
        CGSize availableSize = [self availableSize];
        CGSize blockSize = [self availableBlockSize];
        self.storyLabel.numberOfLines -= [self multilineTitle] ? 1 : 0;
        CGSize size = [self.storyLabel sizeThatFits:blockSize];
        
        // And it comes after Title.
        self.storyLabel.frame = (CGRect){
            contentInsets.left + floorf((availableSize.width - size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kTimeAfterGap,
            size.width,
            size.height
        };
        
    // DONE
    } else if ((![self hasPhotos] && [self hasTitle] && [self hasStory] && [self hasIngredients])
               || (![self hasPhotos] && ![self hasTitle] && [self hasStory] && [self hasIngredients])
               ) {
    
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
            self.ingredientsView.frame.origin.y + self.ingredientsView.frame.size.height + kIngredientsStoryGap,
            size.width,
            size.height
        };
        
    } else {
        self.storyLabel.hidden = YES;
    }
}

- (void)updateMethod {
    
    // Reset the number of lines.
    self.methodLabel.numberOfLines = [self maxMethodLines];
    
    // DONE
    if ([self hasPhotos] && [self hasTitle] && ![self hasStory] && [self hasMethod]) {
        
        // +Photo +Title -Story +Method (+/-)Ingredients
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize blockSize = [self availableBlockSize];
        self.methodLabel.numberOfLines -= [self multilineTitle] ? 1 : 0;
        CGSize size = [self.methodLabel sizeThatFits:blockSize];
        
        // Comes after Title.
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.timeIntervalLabel.frame.origin.y + self.timeIntervalLabel.frame.size.height + kTimeAfterGap,
            size.width,
            size.height
        };
        
    } else if (![self hasPhotos] && ![self hasStory] && [self hasMethod] && [self hasIngredients]) {
        
        // -Photo -Title -Story +Method +Ingredients
        self.methodLabel.hidden = NO;
        
        UIEdgeInsets contentInsets = [self contentInsets];
        NSString *method = self.recipe.method;
        self.methodLabel.text = method;
        CGSize blockSize = [self availableBlockSize];
        CGSize size = [self.methodLabel sizeThatFits:blockSize];
        
        // Comes after ingredients.
        self.methodLabel.frame = (CGRect){
            contentInsets.left + floorf(([self availableSize].width - size.width) / 2.0),
            self.ingredientsView.frame.origin.y + self.ingredientsView.frame.size.height + kIngredientsMethodGap,
            size.width,
            size.height
        };
    
    } else {
        self.methodLabel.hidden = YES;
    }
}


@end
