//
//  RecipeClipboard.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeClipboard.h"
#import "MRCEnumerable.h"
#import "Ingredient.h"

@implementation RecipeClipboard

- (void)setIngredients:(NSArray *)ingredients {
    _ingredients = [NSArray arrayWithArray:[ingredients collect:^id(Ingredient *ingredient) {
        return [Ingredient ingredientwithName:ingredient.name measurement:ingredient.measurement];
    }]];
}

@end
