//
//  RecipeLike.m
//  Cook
//
//  Created by Jonny Sagorin on 12/7/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeLike.h"
#import "NSArray+Enumerable.h"
NSString *const kRecipeLikeKeyLikesCount = @"likesCount";
NSString *const kRecipeLikeKeyUserLike = @"userLike";

@implementation RecipeLike

+(RecipeLike *)recipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe
{
    PFObject *parseRecipeLike = [self objectWithDefaultSecurityWithClassName:kRecipeLikeModelName];
    [parseRecipeLike setObject:user.parseObject forKey:kUserModelForeignKeyName];
    [parseRecipeLike setObject:recipe.parseObject forKey:kRecipeModelForeignKeyName];
    RecipeLike *recipeLike = [[RecipeLike alloc] initWithParseObject:parseRecipeLike];
    return recipeLike;
}

+(RecipeLike*)recipeLikeForParseObject:(PFObject*)parseObject
{
    RecipeLike *parseRecipeLike = [[RecipeLike alloc]initWithParseObject:parseObject];
    parseRecipeLike.user = [[CKUser alloc] initWithParseUser:[parseObject objectForKey:kUserModelForeignKeyName]];

    PFObject *parseRecipeObject = [parseObject objectForKey:kRecipeModelForeignKeyName];
    parseRecipeLike.recipe = [CKRecipe recipeForParseRecipe:parseRecipeObject user:parseRecipeLike.user];
    return parseRecipeLike;
}


+(void) updateRecipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe liked:(BOOL)like withSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    //see if it exists first
    [RecipeLike fetchRecipeLikeForUser:user forRecipe:recipe withSuccess:^(PFObject *parseRecipeObject) {
        if (parseRecipeObject && !like) {
            //delete it - if it exists
            [parseRecipeObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    DLog(@"successfully deleted RecipeLike");
                    success();
                }
            }];
        }
        else if (!parseRecipeObject && like) {
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
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *recipeLikes, NSError *error) {
        
        if (!error) {
            if (recipeLikes && [recipeLikes count] > 0) {
                success([recipeLikes objectAtIndex:0]);
            } else {
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
    [RecipeLike fetchRecipeLikeForUser:user forRecipe:recipe withSuccess:^(PFObject *parseObject) {
        parseObject ?
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


+(void) fetchRecipeLikeCountForUser:(CKUser*)user withSuccess:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    PFQuery *query = [PFQuery queryWithClassName:kRecipeLikeModelName];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            success(count);
        } else {
            failure(error);
        }
    }];
}

+(void)fetchLikedRecipesForUser:(CKUser *)user withSuccess:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    PFQuery *query = [PFQuery queryWithClassName:kRecipeLikeModelName];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
//    [query includeKey:kRecipeModelForeignKeyName];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", kRecipeModelForeignKeyName,kCategoryModelForeignKeyName]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseRecipeLikes, NSError *error) {
        if (!error) {
            NSArray *recipeLikes = [parseRecipeLikes collect:^id(PFObject *parseRecipeLike) {
                PFObject *parseRecipeObject = [parseRecipeLike objectForKey:kRecipeModelForeignKeyName];
                CKRecipe *recipe = [CKRecipe recipeForParseRecipe:parseRecipeObject user:user];
                return recipe;
            }];
//            DLog(@"fetch returned %i recipe likes for user", [parseRecipeLikes count]);
            success(recipeLikes);
        } else {
            failure(error);
        }
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

