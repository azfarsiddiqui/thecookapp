//
//  RecipeLike.h
//  Cook
//
//  Created by Jonny Sagorin on 12/7/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"
#import "CKUser.h"
#import "CKRecipe.h"

extern NSString *const kRecipeLikeKeyLikesCount;
extern NSString *const kRecipeLikeKeyUserLike;

@interface CKRecipeLike : CKModel
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) CKRecipe *recipe;

//create
+ (CKRecipeLike *)recipeLikeForUser:(CKUser *)user;

+(CKRecipeLike*) recipeLikeForUser:(CKUser *)user recipe:(CKRecipe*)recipe;

//action
//update recipe like. returns a numeric of the 
+(void) updateRecipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe liked:(BOOL)like withSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

//NSDictionary with recipe like info. likeCount, userLikes - indicates if user likes this recipe
+(void) fetchRecipeLikeInfoForUser:(CKUser*)user recipe:(CKRecipe *)recipe withSuccess:(DictionaryObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

//user likes counts
+(void) fetchRecipeLikeCountForUser:(CKUser*)user withSuccess:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

//an array recipes for the all recipes a user likes
+(void) fetchLikedRecipesForUser:(CKUser*)user withSuccess:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

+ (void)recipeLikeExistsForRecipe:(CKRecipe *)recipe user:(CKUser *)user success:(BoolObjectSuccessBlock)success
                          failure:(ObjectFailureBlock)failure;

@end
