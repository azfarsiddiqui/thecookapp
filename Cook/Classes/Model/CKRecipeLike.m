//
//  RecipeLike.m
//  Cook
//
//  Created by Jonny Sagorin on 12/7/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipeLike.h"
#import "NSArray+Enumerable.h"
NSString *const kRecipeLikeKeyLikesCount = @"likesCount";
NSString *const kRecipeLikeKeyUserLike = @"userLike";

@implementation CKRecipeLike

+ (CKRecipeLike *)recipeLikeForUser:(CKUser *)user {
    PFObject *parseRecipeLike = [self objectWithDefaultSecurityForUser:user.parseUser className:kRecipeLikeModelName];
    [parseRecipeLike setObject:user.parseObject forKey:kUserModelForeignKeyName];
    return [[CKRecipeLike alloc] initWithParseObject:parseRecipeLike];;
}

+ (CKRecipeLike *)recipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe {
    CKRecipeLike *recipeLike = [self recipeLikeForUser:user];
    [recipeLike.parseObject setObject:[PFObject objectWithoutDataWithClassName:kRecipeModelName objectId:recipe.parseObject.objectId]
                               forKey:kRecipeModelForeignKeyName];
    return recipeLike;
}


@end

