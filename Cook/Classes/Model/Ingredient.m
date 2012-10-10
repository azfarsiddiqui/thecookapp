//
//  Ingredient.m
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient

+(Ingredient *)ingredientwithName:(NSString *)name
{
    Ingredient *ingredient = [[Ingredient alloc] init];
    ingredient.name = name;
    return ingredient;
}

@end
