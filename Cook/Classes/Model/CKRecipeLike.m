//
//  RecipeLike.m
//  Cook
//
//  Created by Jonny Sagorin on 12/7/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipeLike.h"
#import "CKUser.h"
#import "CKRecipe.h"

@implementation CKRecipeLike

+ (CKRecipeLike *)recipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe {
    PFObject *parseRecipeLike = [self objectWithDefaultSecurityForUser:user.parseUser className:kRecipeLikeModelName];
    [parseRecipeLike setObject:user.parseObject forKey:kUserModelForeignKeyName];
    [parseRecipeLike setObject:[PFObject objectWithoutDataWithClassName:kRecipeModelName objectId:recipe.parseObject.objectId]
                        forKey:kRecipeModelForeignKeyName];
    return [[CKRecipeLike alloc] initWithParseObject:parseRecipeLike];;
}

@end

