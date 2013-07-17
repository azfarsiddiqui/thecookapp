//
//  CKRecipeComment.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKRecipeComment.h"
#import "CKUser.h"
#import "CKRecipe.h"

@implementation CKRecipeComment

+ (CKRecipeComment *)recipeCommentForUser:(CKUser *)user recipe:(CKRecipe *)recipe {
    PFObject *parseRecipeComment = [self objectWithDefaultSecurityForUser:user.parseUser className:kRecipeCommentModelName];
    [parseRecipeComment setObject:user.parseObject forKey:kUserModelForeignKeyName];
    [parseRecipeComment setObject:[PFObject objectWithoutDataWithClassName:kRecipeModelName objectId:recipe.parseObject.objectId]
                           forKey:kRecipeModelForeignKeyName];
    return [[CKRecipeComment alloc] initWithParseObject:parseRecipeComment];;
    
}

@end
