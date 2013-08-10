//
//  Theme.h
//  Cook
//
//  Created by Jonny Sagorin on 11/27/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Theme : NSObject

#pragma mark - General

+ (BOOL)IOS7Look;

#pragma mark - Common Fonts
+(UIFont*) defaultFontWithSize:(CGFloat)size;
+(UIFont*) defaultLabelFont;
+(UIFont*) defaultBoldFontWithSize:(CGFloat)size;

#pragma mark - Common Colors
+(UIColor*) defaultLabelColor;
+(UIColor*) pageNumberPrefixLabelColor;

#pragma mark - Contents View
+ (UIColor*) contentsTitleColor;
+ (UIColor*) contentsItemColor;

#pragma mark - Grid category headers
+ (UIColor *)categoryHeaderBackgroundColour;

#pragma mark - Grid recipe cells
+ (UIColor *)recipeGridImageBackgroundColour;
+ (UIFont *)recipeGridTitleFont;
+ (UIColor *)recipeGridTitleColour;
+ (UIFont *)recipeGridIngredientsFont;
+ (UIColor *)recipeGridIngredientsColour;
+ (UIFont *)recipeGridStoryFont;
+ (UIColor *)recipeGridStoryColour;
+ (UIFont *)recipeGridStatFont;
+ (UIColor *)recipeGridStatColour;

#pragma mark - Store
+ (UIFont *)storeTabFont;
+ (UIColor *)storeTabTextColour;
+ (UIColor *)storeTabTextShadowColour;
+ (UIFont *)storeTabSelectedFont;
+ (UIColor *)storeTabSelectedTextColour;
+ (UIFont *)storeBookActionButtonFont;
+ (UIColor *)storeBookActionButtonColour;
+ (UIColor *)storeBookActionButtonShadowColour;
+ (UIFont *)storeBookSummaryNameFont;
+ (UIColor *)storeBookSummaryNameColour;
+ (UIFont *)storeBookSummaryStoryFont;
+ (UIColor *)storeBookSummaryStoryColour;

#pragma mark - Notifications
+ (UIFont *)notificationsHeaderFont;
+ (UIColor *)notificationsHeaderColour;
+ (UIFont *)notificationCellNameFont;
+ (UIColor *)notificationsCellNameColour;
+ (UIFont *)notificationCellActionFont;
+ (UIColor *)notificationsCellActionColour;
+ (UIFont *)notificationCellTimeFont;
+ (UIColor *)notificationsCellTimeColour;

#pragma mark - Book contents/activities.
+ (UIColor *)bookCoverInsideBackgroundColour;
+ (UIFont *)bookNavigationTitleFont;
+ (UIColor *)bookNavigationTitleColour;
+ (UIFont *)bookProfileNameFont;
+ (UIFont *)bookContentsTitleMinFont;
+ (UIColor *)bookContentsViewColour;
+ (UIFont *)bookContentsTitleFont;
+ (UIColor *)bookContentsTitleColour;
+ (UIFont *)bookContentsNameFont;
+ (UIColor *)bookContentsNameColour;
+ (UIFont *)bookContentsItemFont;
+ (UIColor *)bookContentsItemColour;
+ (UIFont *)bookActivityHeaderFont;
+ (UIColor *)bookActivityHeaderColour;
+ (UIColor *)activityInfoViewColour;
+ (UIColor *)activityActionColour;
+ (UIFont *)activityActionFont;
+ (UIColor *)activityTimeColour;
+ (UIFont *)activityTimeFont;
+ (UIColor *)activityTitleColour;
+ (UIFont *)activityTitleFont;
+ (UIColor *)activityNameColour;
+ (UIFont *)activityNameFont;
+ (UIFont *)bookIndexFont;
+ (UIColor *)bookIndexColour;
+ (UIFont *)bookIndexSubtitleFont;
+ (UIColor *)bookIndexSubtitleColour;
+ (UIFont *)bookIndexNumRecipesFont;
+ (UIColor *)bookIndexNumRecipesColour;

#pragma mark - Recipe View
+ (UIColor *)ingredientsListColor;
+ (UIFont *)ingredientsListFont;
+ (UIFont *)ingredientsListMeasurementFont;
+ (UIColor *)ingredientsListMeasurementColor;
+(UIColor*) storyColor;
+(UIFont*) storyFont;
+(UIFont*) recipeNameFont;
+(UIColor*) recipeNameColor;
+ (UIFont *)pageNameFont;
+ (UIColor *)pageNameColour;
+(UIFont*) methodFont;
+(UIColor*) methodColor;
+ (UIFont *)recipeStatTextFont;
+ (UIColor *)recipeStatTextColour;
+ (UIFont *)recipeStatValueFont;
+ (UIColor *)recipeStatValueColour;
+(UIFont*) cookingTimeFont;
+(UIColor*) cookingTimeColor;
+(UIFont*) servesFont;
+(UIColor*) servesColor;
+(UIFont*) categoryFont;
+(UIColor*) userNameColor;
+(UIFont*) userNameFont;
+ (UIColor *)recipeViewBackgroundColour;
+ (UIFont *)editPhotoFont;
+ (UIColor *)editPhotoColour;

#pragma mark - Recipe Editing
+ (UIFont *) cookServesPrepEditTitleFont;
+ (UIColor *) cookServesPrepEditTitleColor;
+ (UIColor *) cookServesNumberColor;
+ (UIFont *) cookPrepPickerFont;
+ (UIFont *) categoryListFont;
+ (UIColor *) categoryListSelectedColor;
+ (UIFont *) typeItUpFont;
+ (UIFont *) orJustAddFont;

+ (UIFont *)editServesTitleFont;
+ (UIColor *)editServesTitleColour;
+ (UIFont *)editServesFont;
+ (UIColor *)editServesColour;
+ (UIFont *)editPrepTitleFont;
+ (UIColor *)editPrepTitleColour;
+ (UIFont *)editPrepFont;
+ (UIColor *)editPrepColour;
+ (UIFont *)editCookTitleFont;
+ (UIColor *)editCookTitleColour;
+ (UIFont *)editCookFont;
+ (UIColor *)editCookColour;

+ (UIColor *)dividerRuleColour;

#pragma mark - Social view.

+ (UIFont *)bookSocialTitleFont;
+ (UIColor *)bookSocialTitleColour;
+ (UIFont *)bookSocialCommentBoxFont;
+ (UIColor *)bookSocialCommentBoxColour;

#pragma mark - Category View
+(UIColor*)categoryViewTextColor;

#pragma mark - Settings
+ (UIFont *)settingsProfileFont;
+ (UIFont *)settingsThemeFont;

#pragma mark - Ingredients
+ (UIFont *)ingredientAccessoryViewButtonTextFont;

#pragma mark - Book Cover
+ (UIFont *)bookCoverEditableAuthorTextFont;
+ (UIFont *)bookCoverEditableCaptionTextFont;
+ (UIFont *)bookCoverEditableTitleTextFont;
+ (UIFont *)bookCoverEditableFieldDescriptionFont;

+ (UIFont *)bookCoverViewModeTitleFont;
+ (UIFont *)bookCoverViewModeCaptionFont;
+ (UIFont *)bookCoverViewModeNameMaxFont;
+ (UIFont *)bookCoverViewStoreModeNameMaxFont;
+ (UIFont *)bookCoverViewModeNameFontForSize:(CGFloat)fontSize;

#pragma mark - General reusable editable controls
+ (UIFont *)textEditableTextFont;
+ (UIFont *)textViewTitleFont;

#pragma mark - Book navigation view.
+ (UIFont *)navigationTitleFont;

@end

