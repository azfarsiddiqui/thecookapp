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

@interface RecipeLike : CKModel
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) CKRecipe *recipe;

+(RecipeLike *) recipeLikeForUser:(CKUser *)user recipe:(CKRecipe*)recipe;

-(void) saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

@end
