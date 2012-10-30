//
//  CKConstants.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Model class

extern NSString *const kModelAttrId;
extern NSString *const kModelAttrName;
extern NSString *const kModelAttrCreatedAt;
extern NSString *const kModelAttrUpdatedAt;

#pragma mark - User class

extern NSString *const kUserModelName;
extern NSString *const kUserAttrDefaultNameValue;
extern NSString *const kUserModelForeignKeyName;
extern NSString *const kUserAttrFacebookId;
extern NSString *const kUserAttrBookSuggestions;
extern NSString *const kUserAttrAdmin;

#pragma mark - Book Follow class

extern NSString *const kBookFollowModelName;
extern NSString *const kBookFollowAttrSuggest;

#pragma mark - Book follow suggestions.

extern NSString *const kBookFollowSuggestionModelName;
extern NSString *const kBookFollowSuggestionAttrUser;

#pragma mark - Book class

extern NSString *const kBookModelName;
extern NSString *const kBookModelForeignKeyName;
extern NSString *const kBookAttrCover;
extern NSString *const kBookAttrIllustration;
extern NSString *const kBookAttrCaption;
extern NSString *const kBookAttrNumRecipes;
extern NSString *const kBookAttrDefaultNameValue;
extern NSString *const kBookAttrDefaultCaptionValue;

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


