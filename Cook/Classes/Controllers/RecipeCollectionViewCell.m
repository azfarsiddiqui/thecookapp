//
//  RecipeCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeCollectionViewCell.h"
#import "CKRecipe.h"

@interface RecipeCollectionViewCell ()

@end

@implementation RecipeCollectionViewCell

- (void)configureRecipe:(CKRecipe *)recipe {
    self.recipe = recipe;
}

- (void)updateImage {
    DLog();
    if ([self.recipe imageFile]) {
        // TODO
    }
}

@end
