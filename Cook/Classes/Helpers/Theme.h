//
//  Theme.h
//  Cook
//
//  Created by Jonny Sagorin on 11/27/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+Expanded.h"

@interface Theme : NSObject

#pragma mark - General

+ (BOOL)IOS7Look;

#pragma mark - Update Notes Buttons

+ (UIFont *)updateNotesFont;
+ (UIColor *)updateNotesColour;

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
+ (UIFont *)recipeGridTimeIntervalFont;
+ (UIColor *)recipeGridTimeIntervalColour;
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
+ (UIColor *)storeBookActionButtonColour;
+ (UIColor *)storeBookActionButtonShadowColour;
+ (UIFont *)storeBookSummaryNameFont;
+ (UIColor *)storeBookSummaryNameColour;
+ (UIFont *)storeBookSummaryStoryFont;
+ (UIColor *)storeBookSummaryStoryColour;

#pragma mark - Book contents/activities.

+ (UIColor *)bookCoverInsideBackgroundColour;
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
+ (UIColor *) storyColor;
+ (UIFont *) storyFont;
+ (UIFont *)tagsFont;
+ (UIColor *)tagsNameColor;
+ (UIFont *) recipeNameFont;
+ (UIColor *) recipeNameColor;
+ (UIFont *)pageNameFont;
+ (UIColor *)pageNameColour;
+ (UIFont *) methodFont;
+ (UIColor *) methodColor;
+ (UIFont *)recipeStatTextFont;
+ (UIColor *)recipeStatTextColour;
+ (UIFont *)recipeStatValueFont;
+ (UIColor *)recipeStatValueColour;
+ (UIFont *) cookingTimeFont;
+ (UIColor *) cookingTimeColor;
+ (UIFont *) servesFont;
+ (UIColor *) servesColor;
+ (UIColor *) userNameColor;
+ (UIFont *) userNameFont;
+ (UIColor *)recipeViewBackgroundColour;
+ (UIFont *)editPhotoFont;
+ (UIColor *)editPhotoColour;
+ (UIColor *)privacyInfoColour;
+ (UIFont *)privacyInfoFont;
+ (UIColor *)progressSavingColour;
+ (UIFont *)progressSavingFont;

#pragma mark - Recipe Editing

+ (UIColor *) cookServesPrepEditTitleColor;
+ (UIColor *) cookServesNumberColor;
+ (UIFont *) cookPrepPickerFont;
+ (UIColor *) categoryListSelectedColor;
+ (UIFont *) typeItUpFont;

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
+ (UIFont *)tagLabelFont;
+ (UIColor *)tagLabelColor;

#pragma mark - Social view.

+ (UIFont *)recipeCommenterFont;
+ (UIColor *)recipeCommenterColour;
+ (UIFont *)recipeCommentFont;
+ (UIColor *)recipeCommentColour;
+ (UIFont *)overlayTimeFont;
+ (UIColor *)overlayTimeColour;

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

+ (UIFont *)bookCoverViewModeTitleFont;
+ (UIFont *)bookCoverViewModeNameMaxFont;
+ (UIFont *)bookCoverViewStoreModeNameMaxFont;
+ (UIFont *)bookCoverViewModeNameFontForSize:(CGFloat)fontSize;

#pragma mark - Book navigation view.
+ (UIFont *)navigationTitleFont;
+ (UIColor *)navigationTitleColour;
+ (UIFont *)suggestFacebookFont;

#pragma mark - Card messages

+ (UIFont *)cardViewTitleFont;
+ (UIColor *)cardViewTitleColour;
+ (UIFont *)cardViewSubtitleFont;
+ (UIColor *)cardViewSubtitleColour;

#pragma mark - Text input tint colour.

+ (UIColor *)textInputTintColour;

@end

