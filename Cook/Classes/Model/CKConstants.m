//
//  CKConstants.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKConstants.h"

#pragma mark - Model class

NSString *const kModelAttrName = @"name";
NSString *const kModelAttrCreatedAt = @"createdAt";
NSString *const kModelAttrUpdatedAt = @"updatedAt";

#pragma mark - User class

NSString *const kUserModelName = @"_User";
NSString *const kUserModelForeignKeyName = @"user";
NSString *const kUserAttrFacebookId  = @"facebookId";
NSString *const kUserAttrFollows  = @"follows";
NSString *const kUserAttrAdmin = @"admin";

#pragma mark - Book class

NSString *const kBookModelName = @"Book";
NSString *const kBookModelForeignKeyName = @"book";
NSString *const kBookAttrCoverPhotoName  = @"coverPhotoName";
NSString *const kBookAttrDefaultNameValue = @"My Book";

#pragma mark - Recipe class
NSString *const kRecipeModelName = @"Recipe";
NSString *const kRecipeModelForeignKeyName = @"recipe";
NSString *const kRecipeAttrDescription = @"description";
NSString *const kRecipeAttrCategoryIndex = @"categoryIndex";
NSString *const kRecipeAttrRecipeImages  = @"images";
NSString *const kRecipeAttrIngredients = @"ingredients";

#pragma mark - RecipeImage class
NSString *const kRecipeImageModelName = @"RecipeImage";
NSString *const kRecipeImageModelForeignKeyName = @"recipeImage";
NSString *const kRecipeImageAttrImageFile = @"imageFile";
NSString *const kRecipeImageAttrImageName = @"imageName";

#pragma mark - Category class
NSString *const kCategoryModelName = @"Category";
NSString *const kCategoryModelForeignKeyName = @"category";

