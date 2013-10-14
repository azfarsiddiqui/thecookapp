//
//  CKRecipeTag.h
//  Cook
//
//  Created by Gerald Kim on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@class CKRecipe;

typedef void(^GetTagsSuccessBlock)(NSArray *tags);

@interface CKRecipeTag : CKModel

@property (nonatomic, readonly) NSString *displayName;

+ (void)tagListWithSuccess:(GetTagsSuccessBlock)success failure:(ObjectFailureBlock)failure;

@end
