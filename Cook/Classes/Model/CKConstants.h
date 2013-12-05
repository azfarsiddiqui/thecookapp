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
extern NSString *const kModelAttrModelUpdatedAt;

#pragma mark - User class

extern NSString *const kUserModelName;
extern NSString *const kUserAttrDefaultNameValue;
extern NSString *const kUserModelForeignKeyName;
extern NSString *const kUserAttrFacebookId;
extern NSString *const kUserAttrFacebookEmail;
extern NSString *const kUserAttrBookSuggestions;
extern NSString *const kUserAttrAdmin;
extern NSString *const kUserAttrFacebookFriends;
extern NSString *const kUserAttrFirstName;
extern NSString *const kUserAttrLastName;
extern NSString *const kUserAttrProfilePhoto;
extern NSString *const kUserAttrCoverPhoto;
extern NSString *const kUserAttrEmail;
extern NSString *const kUserAttrPassword;
extern NSString *const kUserAttrTheme;

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
extern NSString *const kBookAttrCoverPhoto;
extern NSString *const kBookAttrCoverPhotoThumb;
extern NSString *const kBookAttrIllustration;
extern NSString *const kBookAttrIllustrationImage;
extern NSString *const kBookAttrIllustrationLowImage;
extern NSString *const kBookAttrCaption;
extern NSString *const kBookAttrNumRecipes;
extern NSString *const kBookAttrPages;
extern NSString *const kBookAttrCategories;
extern NSString *const kBookAttrAuthor;
extern NSString *const kBookAttrFeatured;
extern NSString *const kBookAttrFeaturedOrder;
extern NSString *const kBookAttrDefaultNameValue;
extern NSString *const kBookAttrDefaultCaptionValue;
extern NSString *const kBookAttrStory;
extern NSString *const kBookAttrGuestNameValue;
extern NSString *const kBookAttrGuestCaptionValue;
extern NSString *const kBookAttrTitleRecipe;
extern NSString *const kBookAttrDisabled;

#pragma mark - Recipe class

extern NSString *const kRecipeModelName;
extern NSString *const kRecipeModelForeignKeyName;
extern NSString *const kRecipeAttrPage;
extern NSString *const kRecipeAttrStory;
extern NSString *const kRecipeAttrTags;
extern NSString *const kRecipeAttrDescription;
extern NSString *const kRecipeAttrCategoryIndex;
extern NSString *const kRecipeAttrRecipePhotos; // An array of objectIds.
extern NSString *const kRecipeAttrIngredients;
extern NSString *const kRecipeAttrNumServes;
extern NSString *const kRecipeAttrCookingTimeInMinutes;
extern NSString *const kRecipeAttrPrepTimeInMinutes;
extern NSString *const kRecipeAttrRecipeViewImageContentOffset;
extern NSString *const kRecipeAttrPrivacy;
extern NSString *const kRecipeAttrLocation;
extern NSString *const kRecipeAttrLocale;
extern NSString *const kRecipeAttrNumViews;
extern NSString *const kRecipeAttrNumLikes;
extern NSString *const kRecipeAttrNumComments;
extern NSString *const kRecipeAttrUserPhoto;
extern NSString *const kRecipeAttrUpdatedAt;

#pragma mark - RecipeImage class

extern NSString *const kRecipeImageModelName;
extern NSString *const kRecipeImageModelForeignKeyName;
extern NSString *const kRecipeImageAttrImageFile;
extern NSString *const kRecipeImageAttrThumbImageFile;
extern NSString *const kRecipeImageAttrImageUUID;
extern NSString *const kRecipeImageAttrThumnImageUUID;
extern NSString *const kRecipeImageAttrImageName;

#pragma mark - Location class

extern NSString *const kLocationModelName;
extern NSString *const kLocationModelForeignKeyName;
extern NSString *const kLocationGeoPoint;
extern NSString *const kLocationCountryCode;
extern NSString *const kLocationCountry;
extern NSString *const kLocationPostalCode;
extern NSString *const kLocationAdministrativeArea;
extern NSString *const kLocationSubAdministrativeArea;
extern NSString *const kLocationLocality;
extern NSString *const kLocationSubLocality;

#pragma mark - Category class

extern NSString *const kCategoryModelName;
extern NSString *const kCategoryModelForeignKeyName;
extern NSString *const kCategoryAttrOrder;

#pragma mark - RecipeLike class

extern NSString *const kRecipeLikeModelName;

#pragma mark - RecipeComment class

extern NSString *const kRecipeCommentModelName;
extern NSString *const kRecipeCommentText;

#pragma mark - RecipePin class

extern NSString *const kRecipePinPage;

#pragma mark - RecipeTag class

extern NSString *const kRecipeTagModelName;
extern NSString *const kRecipeTagDisplayNames;
extern NSString *const kRecipeTagCategory;
extern NSString *const kRecipeTagOrderIndex;
extern NSString *const kRecipeTagImageType;

#pragma mark - Activity class

extern NSString *const kActivityModelName;
extern NSString *const kActivityNameAddRecipe;
extern NSString *const kActivityNameUpdateRecipe;
extern NSString *const kActivityNameLikeRecipe;

#pragma mark - UserNotification class

extern NSString *const kUserNotificationModelName;
extern NSString *const kUserNotificationAttrRead;               // Whether notification was read.
extern NSString *const kUserNotificationAttrFriendRequestAccepted;
extern NSString *const kUserNotificationAttrActionUser;
extern NSString *const kUserNotificationTypeFriendRequest;
extern NSString *const kUserNotificationTypeFriendAccept;
extern NSString *const kUserNotificationTypeComment;
extern NSString *const kUserNotificationTypeLike;
extern NSString *const kUserNotificationTypePin;
