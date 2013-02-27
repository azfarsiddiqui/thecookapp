//
//  ActivityRecipeStatsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ActivityRecipeStatsView.h"
#import "CKRecipe.h"

@implementation ActivityRecipeStatsView

- (void)configureRecipe:(CKRecipe *)recipe {
    [self reset];
    [self configureIcon:@"cook_recipe_iconbar_serves.png" value:[NSString stringWithFormat:@"%d", recipe.numServes]];
    [self configureIcon:@"cook_recipe_iconbar_time.png" value:[NSString stringWithFormat:@"%d", recipe.cookingTimeInMinutes]];
    [self configureIcon:@"cook_recipe_iconbar_likes.png" value:[NSString stringWithFormat:@"%d", recipe.likes]];
}

- (UIColor *)textColour {
    return [UIColor whiteColor];
}

- (UIColor *)shadowColour {
    return [UIColor lightGrayColor];
}

- (CGSize)shadowOffset {
    return CGSizeMake(0.0, 0.0);
}

@end
