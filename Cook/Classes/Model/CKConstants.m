//
//  CKConstants.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKConstants.h"

#pragma mark - Model class

NSString *const kModelAttrName                  = @"name";
NSString *const kModelObjectId                  = @"objectId";
NSString *const kModelAttrCreatedAt             = @"createdAt";
NSString *const kModelAttrUpdatedAt             = @"updatedAt";

#pragma mark - User class

NSString *const kUserModelName                  = @"_User";
NSString *const kUserAttrDefaultNameValue       = @"Your Name";
NSString *const kUserModelForeignKeyName        = @"user";
NSString *const kUserAttrFacebookId             = @"facebookId";
NSString *const kUserAttrAdmin                  = @"admin";
NSString *const kUserAttrBookSuggestions        = @"suggestedBooks";
NSString *const kUserAttrFacebookFriends        = @"facebookFriends";

#pragma mark - User Friends class

NSString *const kUserFriendsModelName           = @"UserFriends";
NSString *const kUserFriendsAttrFriends         = @"friends";

#pragma mark - User Book Follow class

NSString *const kUserBookFollowModelName       = @"UserBookFollow";
NSString *const kUserBookFollowAttrOrder       = @"order";

#pragma mark - BookFollow

NSString *const kBookFollowModelName            = @"BookFollow";
NSString *const kBookFollowAttrSuggest          = @"suggest";
NSString *const kBookFollowAttrMerge            = @"merged";
NSString *const kBookFollowAttrAdmin            = @"admin";

#pragma mark - Book follow suggestions.

NSString *const kBookFollowSuggestionModelName  = @"BookFollowSuggestion";
NSString *const kBookFollowSuggestionAttrUser   = @"suggestedUser";

#pragma mark - Book class

NSString *const kBookModelName                  = @"Book";
NSString *const kBookModelForeignKeyName        = @"book";
NSString *const kBookAttrCover                  = @"cover";
NSString *const kBookAttrIllustration           = @"illustration";
NSString *const kBookAttrCaption                = @"caption";
NSString *const kBookAttrNumRecipes             = @"numRecipes";
NSString *const kBookAttrCategories             = @"categories";
NSString *const kBookAttrDefaultNameValue       = @"COOK";
NSString *const kBookAttrDefaultCaptionValue    = @"Tell us more about your book";

#pragma mark - Recipe class
NSString *const kRecipeModelName                = @"Recipe";
NSString *const kRecipeModelForeignKeyName      = @"recipe";
NSString *const kRecipeAttrDescription          = @"description";
NSString *const kRecipeAttrCategoryIndex        = @"categoryIndex";
NSString *const kRecipeAttrRecipeImages         = @"images";
NSString *const kRecipeAttrIngredients          = @"ingredients";
NSString *const kRecipeAttrRecipeViewImageContentOffset = @"recipeViewImageContentOffset";
NSString *const kRecipeAttrNumServes            = @"numServes";
NSString *const kRecipeAttrCookingTimeInSeconds = @"cookingTimeSecs";

#pragma mark - RecipeImage class
NSString *const kRecipeImageModelName           = @"RecipeImage";
NSString *const kRecipeImageModelForeignKeyName = @"recipeImage";
NSString *const kRecipeImageAttrImageFile       = @"imageFile";
NSString *const kRecipeImageAttrImageName       = @"imageName";

#pragma mark - Category class
NSString *const kCategoryModelName              = @"Category";
NSString *const kCategoryModelForeignKeyName    = @"category";


#pragma mark - RecipeLike class
NSString *const kRecipeLikeModelName           = @"RecipeLike";
NSString *const kRecipeLikeModelForeignKeyName = @"recipeLike";

