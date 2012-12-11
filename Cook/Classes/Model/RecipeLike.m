//
//  RecipeLike.m
//  Cook
//
//  Created by Jonny Sagorin on 12/7/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeLike.h"

NSString *const kRecipeLikeKeyLikesCount = @"likesCount";
NSString *const kRecipeLikeKeyUserLike = @"userLike";

@implementation RecipeLike

+(RecipeLike *)recipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe
{
    PFObject *parseRecipeLike = [PFObject objectWithClassName:kRecipeLikeModelName];
    [parseRecipeLike setObject:user.parseObject forKey:kUserModelForeignKeyName];
    [parseRecipeLike setObject:recipe.parseObject forKey:kRecipeModelForeignKeyName];
    RecipeLike *recipeLike = [[RecipeLike alloc] initWithParseObject:parseRecipeLike];
    return recipeLike;
}

+(RecipeLike*)recipeLikeForParseObject:(PFObject*)parseObject
{
    RecipeLike *parseRecipeLike = [[RecipeLike alloc]initWithParseObject:parseObject];
    parseRecipeLike.user = [parseObject objectForKey:kUserModelForeignKeyName];
    parseRecipeLike.recipe = [parseObject objectForKey:kRecipeModelForeignKeyName];
    return parseRecipeLike;
}


+(void) updateRecipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe liked:(BOOL)like withSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    //see if it exists first
    [RecipeLike fetchRecipeLikeForUser:user forRecipe:recipe withSuccess:^(RecipeLike *recipeLike) {
        if (recipeLike && !like) {
            //delete it - if it exists
            [recipeLike.parseObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    DLog(@"successfully deleted RecipeLike");
                    success();
                }
            }];
        }
        else if (!recipeLike && like) {
            RecipeLike *recipeLike = [RecipeLike recipeLikeForUser:user recipe:recipe];
            [recipeLike saveInBackground:^{
                success();
            } failure:^(NSError *error) {
                failure(error);
            }];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+(void) fetchRecipeLikeForUser:(CKUser*)user forRecipe:(CKRecipe*)recipe withSuccess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    PFQuery *query = [PFQuery queryWithClassName:kRecipeLikeModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
    [query whereKey:kRecipeModelForeignKeyName equalTo:recipe.parseObject];
    
    [query findObjectsInBackgroundWithBlock:
     ^(NSArray *recipeLikes, NSError *error) {
        if (!error) {
            if (recipeLikes && [recipeLikes count]> 0) {
                DLog(@"recipe like for this user. returned %d count", [recipeLikes count]);
                success([RecipeLike recipeLikeForParseObject:[recipeLikes objectAtIndex:0]]);
            } else {
                DLog(@"recipe has not been liked by this user");
                success(nil);
            }
        } else {
            failure(error);
        }
    }];

}
//NSDictionary with recipe like info. likeCount, userLikes - rindicates if user likes this recipe
+(void) fetchRecipeLikeInfoForUser:(CKUser*)user recipe:(CKRecipe *)recipe withSuccess:(DictionaryObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    __block NSMutableDictionary *recipeInfo = [NSMutableDictionary dictionary];
    [RecipeLike fetchRecipeLikeForUser:user forRecipe:recipe withSuccess:^(RecipeLike *recipeLike) {
        recipeLike ?
        [recipeInfo setObject:[NSNumber numberWithBool:YES] forKey:kRecipeLikeKeyUserLike]:
        [recipeInfo setObject:[NSNumber numberWithBool:NO] forKey:kRecipeLikeKeyUserLike];
        //now fetch count of likes
        PFQuery *query = [PFQuery queryWithClassName:kRecipeLikeModelName];
        [query whereKey:kRecipeModelForeignKeyName equalTo:recipe.parseObject];
        [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
            if (!error) {
                [recipeInfo setObject:[NSNumber numberWithInt:count] forKey:kRecipeLikeKeyLikesCount];
                success([NSDictionary dictionaryWithDictionary:recipeInfo]);
            } else {
                failure(error);
            }
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

#pragma mark - Private Methods
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

-(void)deleteWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    [self.parseObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            success();
        } else {
            failure(error);
        }
    }];
}

@end

