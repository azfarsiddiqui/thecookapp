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
extern NSString *const kModelObjectId;
extern NSString *const kModelAttrCreatedAt;
extern NSString *const kModelAttrUpdatedAt;

#pragma mark - User class

extern NSString *const kUserModelName;
extern NSString *const kUserAttrDefaultNameValue;
extern NSString *const kUserModelForeignKeyName;
extern NSString *const kUserAttrFacebookId;
extern NSString *const kUserAttrBookSuggestions;
extern NSString *const kUserAttrAdmin;
extern NSString *const kUserAttrFacebookFriends;
extern NSString *const kUserAttrFirstName;
extern NSString *const kUserAttrLastName;
extern NSString *const kUserAttrProfilePhoto;
extern NSString *const kUserAttrCoverPhoto;
extern NSString *const kUserAttrEmail;
extern NSString *const kUserAttrPassword;

#pragma mark - UserFriend class

extern NSString *const kUserFriendModelName;
extern NSString *const kUserFriendFriend;
extern NSString *const kUserFriendAttrConnected;
extern NSString *const kUserFriendAttrRequestor;

#pragma mark - User Book Follow class

extern NSString *const kUserBookFollowModelName;
extern NSString *const kUserBookFollowAttrOrder;

#pragma mark - Book Follow class

extern NSString *const kBookFollowModelName;
extern NSString *const kBookFollowAttrSuggest;
extern NSString *const kBookFollowAttrMerge;
extern NSString *const kBookFollowAttrAdmin;

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
extern NSString *const kBookAttrCategories;
extern NSString *const kBookAttrAuthor;
extern NSString *const kBookAttrFeatured;
extern NSString *const kBookAttrFeaturedOrder;
extern NSString *const kBookAttrDefaultNameValue;
extern NSString *const kBookAttrDefaultCaptionValue;
extern NSString *const kBookAttrStory;

#pragma mark - Recipe class
extern NSString *const kRecipeModelName;
extern NSString *const kRecipeModelForeignKeyName;
extern NSString *const kRecipeAttrStory;
extern NSString *const kRecipeAttrDescription;
extern NSString *const kRecipeAttrCategoryIndex;
extern NSString *const kRecipeAttrRecipePhotos; // An array of objectIds.
extern NSString *const kRecipeAttrIngredients;
extern NSString *const kRecipeAttrNumServes;
extern NSString *const kRecipeAttrCookingTimeInMinutes;
extern NSString *const kRecipeAttrPrepTimeInMinutes;
extern NSString *const kRecipeAttrRecipeViewImageContentOffset;
extern NSString *const kRecipeAttrPrivacy;
extern NSString *const kRecipeAttrLikes;

#pragma mark - RecipeImage class
extern NSString *const kRecipeImageModelName;
extern NSString *const kRecipeImageModelForeignKeyName;
extern NSString *const kRecipeImageAttrImageFile;
extern NSString *const kRecipeImageAttrImageName;

#pragma mark - Category class
extern NSString *const kCategoryModelName;
extern NSString *const kCategoryModelForeignKeyName;
extern NSString *const kCategoryAttrOrder;

#pragma mark - RecipeLike class
extern NSString *const kRecipeLikeModelName;
extern NSString *const kRecipeLikeModelForeignKeyName;

#pragma mark - Activity class

extern NSString *const kActivityModelName;
extern NSString *const kActivityNameAddRecipe;
extern NSString *const kActivityNameUpdateRecipe;
extern NSString *const kActivityNameLikeRecipe;

#pragma mark - UserNotification class

extern NSString *const kUserNotificationModelName;
extern NSString *const kUserNotificationNameFriendRequest;  // Name of the notification type
extern NSString *const kUserNotificationUserFriend;         // References the UserFriend model
extern NSString *const kUserNotificationUnread;             // Whether notification was read.
