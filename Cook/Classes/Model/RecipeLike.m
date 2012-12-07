//
//  RecipeLike.m
//  Cook
//
//  Created by Jonny Sagorin on 12/7/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeLike.h"

NSString *const kRecipeLikeKeyNumLikes = @"numLikes";
NSString *const kRecipeLikeKeyUserLike = @"userLike";

@implementation RecipeLike

+(RecipeLike *)recipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe
{
    PFObject *parseRecipeLike = [PFObject objectWithClassName:kRecipeLikeModelName];
    RecipeLike *recipeLike = [[RecipeLike alloc] initWithParseObject:parseRecipeLike];
    recipeLike.user = user;
    recipeLike.recipe = recipe;
    return recipeLike;
}

+(RecipeLike*)recipeLikeForParseObject:(PFObject*)parseObject
{
    RecipeLike *parseRecipeLike = [[RecipeLike alloc]initWithParseObject:parseObject];
    parseRecipeLike.user = [parseObject objectForKey:kUserModelForeignKeyName];
    parseRecipeLike.recipe = [parseObject objectForKey:kRecipeModelForeignKeyName];
    return parseRecipeLike;
}


+(void) updateRecipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe liked:(BOOL)like withSuccess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    
}

//NSDictionary with recipe like info. likeCount, userLikes - indicates if user likes this recipe
+(void) fetchRecipeLikeInfoForUser:(CKUser*)user recipe:(CKRecipe *)recipe withSuccess:(DictionaryObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    PFQuery *query = [PFQuery queryWithClassName:kRecipeLikeModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
    [query whereKey:kBookModelForeignKeyName equalTo:recipe.parseObject];
    [query includeKey:kCategoryModelForeignKeyName];
    __block NSMutableDictionary *recipeInfo = [NSMutableDictionary dictionary];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseRecipeLikes, NSError *error) {
        if (!error) {
            DLog(@"fetch returned %i recipeLikes", [parseRecipeLikes count]);
            [parseRecipeLikes count] > 0 ?
            [recipeInfo setObject:[NSNumber numberWithBool:YES] forKey:kRecipeLikeKeyUserLike]:
            [recipeInfo setObject:[NSNumber numberWithBool:NO] forKey:kRecipeLikeKeyUserLike];
//            //now fetch recipe update count
//            PFQuery *query = [PFQuery queryWithClassName:@"GameScore"];
//            [query whereKey:@"playername" equalTo:@"Sean Plott"];
//            [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
//                if (!error) {
//                    // The count request succeeded. Log the count
//                    NSLog(@"Sean has played %d games", count);
//                } else {
//                    // The request failed
//                }
//            }];
            
        } else {
            failure(error);
        }
        success([NSDictionary dictionaryWithDictionary:recipeInfo]);
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

