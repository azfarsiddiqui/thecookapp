//
//  Ingredient.m
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "Ingredient.h"

@implementation Ingredient

+ (Ingredient *)ingredientwithName:(NSString *)name measurement:(NSString*)measurement {
    Ingredient *ingredient = [[Ingredient alloc] init];
    ingredient.name = name;
    ingredient.measurement = measurement;
    return ingredient;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithString:[super description]];
    [description appendFormat:@" unit[%@] name[%@]", self.measurement, self.name];
    return description;
}

@end
