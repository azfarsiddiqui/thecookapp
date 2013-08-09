//
//  RecipeDetails.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeDetails.h"
#import "Ingredient.h"
#import "MRCEnumerable.h"

@implementation RecipeDetails

- (void)setIngredients:(NSArray *)ingredients {
    _ingredients = [NSArray arrayWithArray:[ingredients collect:^id(Ingredient *ingredient) {
        return [Ingredient ingredientwithName:ingredient.name measurement:ingredient.measurement];
    }]];
}

@end
