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
NSString *const kUserAttrActivities             = @"activities";
NSString *const kUserAttrFirstName              = @"firstName";
NSString *const kUserAttrLastName               = @"lastName";
NSString *const kUserAttrProfilePhoto           = @"profilePhoto";
NSString *const kUserAttrCoverPhoto             = @"coverPhoto";
NSString *const kUserAttrEmail                  = @"password";
NSString *const kUserAttrPassword               = @"email";
NSString *const kUserAttrTheme                  = @"theme";

#pragma mark - UserFriend class

NSString *const kUserFriendModelName            = @"UserFriend";
NSString *const kUserFriendFriend               = @"friend";
NSString *const kUserFriendAttrConnected        = @"connected";
NSString *const kUserFriendAttrRequestor        = @"requestor";

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
NSString *const kBookAttrPages                  = @"pages";
NSString *const kBookAttrCategories             = @"categories";
NSString *const kBookAttrAuthor                 = @"author";
NSString *const kBookAttrFeatured               = @"featured";
NSString *const kBookAttrFeaturedOrder          = @"featuredOrder";
NSString *const kBookAttrDefaultNameValue       = @"COOK";
NSString *const kBookAttrDefaultCaptionValue    = @"Tell us more about your book";
NSString *const kBookAttrStory                  = @"story";
NSString *const kBookAttrGuestNameValue         = @"YOUR BOOK";
NSString *const kBookAttrGuestCaptionValue      = @"Signup and add your recipes";

#pragma mark - Recipe class

NSString *const kRecipeModelName                = @"Recipe";
NSString *const kRecipeModelForeignKeyName      = @"recipe";
NSString *const kRecipeAttrPage                 = @"page";
NSString *const kRecipeAttrStory                = @"story";
NSString *const kRecipeAttrTags                 = @"tags";
NSString *const kRecipeAttrDescription          = @"description";
NSString *const kRecipeAttrCategoryIndex        = @"categoryIndex";
NSString *const kRecipeAttrRecipePhotos         = @"photos";
NSString *const kRecipeAttrIngredients          = @"ingredients";
NSString *const kRecipeAttrRecipeViewImageContentOffset = @"recipeViewImageContentOffset";
NSString *const kRecipeAttrNumServes            = @"numServes";
NSString *const kRecipeAttrCookingTimeInMinutes = @"cookingTimeMins";
NSString *const kRecipeAttrPrepTimeInMinutes    = @"prepTimeMins";
NSString *const kRecipeAttrPrivacy              = @"privacy";
NSString *const kRecipeAttrLocation             = @"location";

#pragma mark - RecipeImage class

NSString *const kRecipeImageModelName           = @"RecipeImage";
NSString *const kRecipeImageModelForeignKeyName = @"recipeImage";
NSString *const kRecipeImageAttrImageFile       = @"imageFile";
NSString *const kRecipeImageAttrThumbImageFile  = @"thumbImageFile";
NSString *const kRecipeImageAttrImageUUID       = @"imageUuid";
NSString *const kRecipeImageAttrThumnImageUUID  = @"thumbImageUuid";
NSString *const kRecipeImageAttrImageName       = @"imageName";

#pragma mark - Category class

NSString *const kCategoryModelName              = @"Category";
NSString *const kCategoryModelForeignKeyName    = @"category";
NSString *const kCategoryAttrOrder              = @"order";

#pragma mark - RecipeLike class

NSString *const kRecipeLikeModelName           = @"RecipeLike";

#pragma mark - RecipeComment class

NSString *const kRecipeCommentModelName        = @"RecipeComment";
NSString *const kRecipeCommentText              = @"text";

#pragma mark - Activity class

NSString *const kActivityModelName              = @"Activity";
NSString *const kActivityNameAddRecipe          = @"AddRecipe";
NSString *const kActivityNameUpdateRecipe       = @"UpdateRecipe";
NSString *const kActivityNameLikeRecipe         = @"LikeRecipe";

#pragma mark - UserNotification class

NSString *const kUserNotificationModelName          = @"UserNotification";
NSString *const kUserNotificationAttrRead           = @"read";
