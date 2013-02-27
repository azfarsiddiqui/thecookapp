//
//  Theme.h
//  Cook
//
//  Created by Jonny Sagorin on 11/27/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Theme : NSObject

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

#pragma mark - Grid recipe cells
+ (UIFont *)recipeGridTitleFont;
+ (UIColor *)recipeGridTitleColour;
+ (UIFont *)recipeGridIngredientsFont;
+ (UIColor *)recipeGridIngredientsColour;
+ (UIFont *)recipeGridStoryFont;
+ (UIColor *)recipeGridStoryColour;

#pragma mark - Book contents/activities.
+ (UIFont *)bookProfileNameFont;
+ (UIColor *)bookContentsViewColour;
+ (UIFont *)bookContentsTitleFont;
+ (UIColor *)bookContentsTitleColour;
+ (UIFont *)bookContentsNameFont;
+ (UIColor *)bookContentsNameColour;
+ (UIFont *)bookContentsItemFont;
+ (UIColor *)bookContentsItemColour;
+ (UIColor *)activityInfoViewColour;
+ (UIColor *)activityActionColour;
+ (UIFont *)activityActionFont;
+ (UIColor *)activityTimeColour;
+ (UIFont *)activityTimeFont;
+ (UIColor *)activityTitleColour;
+ (UIFont *)activityTitleFont;
+ (UIColor *)activityNameColour;
+ (UIFont *)activityNameFont;

#pragma mark - Recipe View
+(UIColor*) ingredientsListColor;
+(UIFont*) ingredientsListFont;
+(UIColor*) storyColor;
+(UIFont*) storyFont;
+(UIFont*) recipeNameFont;
+(UIColor*) recipeNameColor;
+(UIFont*) methodFont;
+(UIColor*) methodColor;
+(UIFont*) cookingTimeFont;
+(UIColor*) cookingTimeColor;
+(UIFont*) servesFont;
+(UIColor*) servesColor;
+(UIColor*) userNameColor;
+(UIFont*) userNameFont;

#pragma mark - Category View
+(UIColor*)categoryViewTextColor;

#pragma mark - Settings
+ (UIFont *)settingsProfileFont;

#pragma mark - Ingredients
+ (UIFont *)ingredientAccessoryViewButtonTextFont;

#pragma mark - Book Cover
+ (UIFont *)bookCoverEditableAuthorTextFont;
+ (UIFont *)bookCoverEditableCaptionTextFont;
+ (UIFont *)bookCoverEditableTitleTextFont;
+ (UIFont *)bookCoverEditableFieldDescriptionFont;

+ (UIFont *)bookCoverViewModeAuthorFont;
+ (UIFont *)bookCoverViewModeCaptionFont;
+ (UIFont *)bookCoverViewModeTitleMinFont;
+ (UIFont *)bookCoverViewModeTitleMidFont;
+ (UIFont *)bookCoverViewModeTitleMaxFont;

#pragma mark - General reusable editable controls
+ (UIFont *)textEditableTextFont;
+ (UIFont *)textViewTitleFont;


@end

