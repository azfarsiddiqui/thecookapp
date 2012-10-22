//
//  CKConstants.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Model class

extern NSString *const kModelAttrName;
extern NSString *const kModelAttrCreatedAt;
extern NSString *const kModelAttrUpdatedAt;

#pragma mark - User class

extern NSString *const kUserModelName;
extern NSString *const kUserAttrDefaultNameValue;
extern NSString *const kUserModelForeignKeyName;
extern NSString *const kUserAttrFacebookId;
extern NSString *const kUserAttrFollows;
extern NSString *const kUserAttrAdmin;

#pragma mark - User Follows pending class

extern NSString *const kFollowRequestModelName;
extern NSString *const kFollowRequestAttrRequestedUser;

#pragma mark - Book class

extern NSString *const kBookModelName;
extern NSString *const kBookModelForeignKeyName;
extern NSString *const kBookAttrCover;
extern NSString *const kBookAttrIllustration;
extern NSString *const kBookAttrTagline;
extern NSString *const kBookAttrNumRecipes;
extern NSString *const kBookAttrDefaultNameValue;
extern NSString *const kBookAttrDefaultTaglineValue;

#pragma mark - Recipe class
extern NSString *const kRecipeModelName;
extern NSString *const kRecipeModelForeignKeyName;
extern NSString *const kRecipeAttrDescription;
extern NSString *const kRecipeAttrCategoryIndex;
extern NSString *const kRecipeAttrRecipeImages;
extern NSString *const kRecipeAttrIngredients;

#pragma mark - RecipeImage class
extern NSString *const kRecipeImageModelName;
extern NSString *const kRecipeImageModelForeignKeyName;
extern NSString *const kRecipeImageAttrImageFile;
extern NSString *const kRecipeImageAttrImageName;

#pragma mark - Category class
extern NSString *const kCategoryModelName;
extern NSString *const kCategoryModelForeignKeyName;


