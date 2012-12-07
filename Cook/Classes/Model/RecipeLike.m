//
//  RecipeLike.m
//  Cook
//
//  Created by Jonny Sagorin on 12/7/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeLike.h"

@implementation RecipeLike

+(RecipeLike *)recipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe
{
    PFObject *parseRecipeLike = [PFObject objectWithClassName:kRecipeLikeModelName];
    RecipeLike *recipeLike = [[RecipeLike alloc] initWithParseObject:parseRecipeLike];
    recipeLike.user = user;
    recipeLike.recipe = recipe;
    return recipeLike;
}

-(void) saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    PFObject *parseRecipeObject = self.parseObject;
    if (self.user) {
        [parseRecipeObject setObject:self.user.parseObject forKey:kUserModelForeignKeyName];
    }
    
    if (self.recipe) {
        [parseRecipeObject setObject:self.recipe.parseObject forKey:kRecipeModelForeignKeyName];
    }

    [self saveInBackground:^{
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];

}

@end

