//
//  CKRecipeComment.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@class CKUser;
@class CKRecipe;

@interface CKRecipeComment : CKModel

@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) NSString *text;

+ (CKRecipeComment *)recipeCommentForUser:(CKUser *)user recipe:(CKRecipe *)recipe text:(NSString *)text;

@end
