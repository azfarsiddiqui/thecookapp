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

+ (CKRecipeLike *)recipeLikeForUser:(CKUser *)user;
+ (CKRecipeLike *)recipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe;

@end
