//
//  RecipeLike.h
//  Cook
//
//  Created by Jonny Sagorin on 12/7/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@class CKRecipe;
@class CKUser;

@interface CKRecipeLike : CKModel

@property (nonatomic, strong) CKUser *user;

+ (CKRecipeLike *)recipeLikeForUser:(CKUser *)user recipe:(CKRecipe *)recipe;

@end
