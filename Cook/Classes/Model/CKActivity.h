//
//  CKActivity.h
//  Cook
//
//  Created by Jeff Tan-Ang on 21/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"
#import <Parse/Parse.h>

@class CKUser;
@class CKRecipe;

@interface CKActivity : CKModel

@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) CKRecipe *recipe;

+ (CKActivity *)activityForParseActivity:(PFObject *)parseActivity;
+ (void)saveAddRecipeActivityForRecipe:(CKRecipe *)recipe;
+ (void)saveUpdateRecipeActivityForRecipe:(CKRecipe *)recipe;
+ (void)saveLikeRecipeActivityForRecipe:(CKRecipe *)recipe;
+ (void)activitiesForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

- (NSString *)actionName;

@end
