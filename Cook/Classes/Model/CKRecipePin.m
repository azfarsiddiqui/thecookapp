//
//  CKRecipePin.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipePin.h"
#import "CKRecipe.h"

@implementation CKRecipePin

#pragma mark - Properties

- (CKRecipe *)recipe {
    if (!_recipe) {
        _recipe = [CKRecipe recipeForParseRecipe:[self.parseObject objectForKey:kRecipeModelForeignKeyName] user:nil];
    }
    return _recipe;
}

- (NSString *)page {
    return [self.parseObject objectForKey:kRecipePinPage];
}

- (void)setPage:(NSString *)page {
    [self.parseObject setObject:page forKey:kRecipePinPage];
}

@end
