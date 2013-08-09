//
//  Theme.m
//  Cook
//
//  Created by Jonny Sagorin on 11/27/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "Theme.h"
#import "UIColor+Expanded.h"


@implementation Theme

#pragma mark - General

+ (BOOL)IOS7Look {
    return YES;
}

#pragma mark - Common Fonts

+(UIFont *)defaultFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:size];
    
}

+(UIFont *)defaultLabelFont
{
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:20];
}

+(UIFont*) defaultBoldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:size];
}

#pragma mark - Common Styles

+(UIColor *)defaultLabelColor
{
    return [UIColor colorWithHexString:@"707070"];
}

+(UIColor*) pageNumberPrefixLabelColor
{
    return [UIColor colorWithHexString:@"2D6CA9"];
}

+(UIColor*) userNameColor
{
    return [UIColor colorWithHexString:@"717171"];
}

+ (UIFont *)userNameFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:18];
}

#pragma mark - Contents View

+ (UIColor *) contentsTitleColor
{
    return [UIColor colorWithHexString:@"505050"];
}

+ (UIColor *) contentsItemColor
{
    return [self contentsTitleColor];
}

#pragma mark - Store

+ (UIFont *)storeTabFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:20.0];
}

+ (UIColor *)storeTabTextColour {
    return [UIColor grayColor];
}

+ (UIColor *)storeTabTextShadowColour {
    return [UIColor colorWithHexString:@"0d60b1"];
}

+ (UIFont *)storeTabSelectedFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:26.0];
}

+ (UIColor *)storeTabSelectedTextColour {
    return [UIColor grayColor];
}

+ (UIFont *)storeBookActionButtonFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:16.0];
}

+ (UIColor *)storeBookActionButtonColour {
    return [UIColor whiteColor];
}

+ (UIColor *)storeBookActionButtonShadowColour {
    return [UIColor blackColor];
}

+ (UIFont *)storeBookSummaryNameFont {
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:30.0];
}

+ (UIColor *)storeBookSummaryNameColour {
    return [UIColor whiteColor];
}

+ (UIFont *)storeBookSummaryStoryFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
}

+ (UIColor *)storeBookSummaryStoryColour {
    return [UIColor whiteColor];
}

#pragma mark - Grid category headers

+ (UIColor *)categoryHeaderBackgroundColour {
    return [UIColor clearColor];
}

#pragma mark - Grid recipe cells

+ (UIColor *)recipeGridImageBackgroundColour {
    return [UIColor colorWithHexString:@"EFEFEF"];
}

+ (UIFont *)recipeGridTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:22.0];
}

+ (UIColor *)recipeGridTitleColour {
    return [UIColor colorWithHexString:@"3A3A3A"];
}

+ (UIFont *)recipeGridIngredientsFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:15.0];
}

+ (UIColor *)recipeGridIngredientsColour {
    return [UIColor colorWithHexString:@"3A3A3A"];
}

+ (UIFont *)recipeGridStoryFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:15.0];
}

+ (UIColor *)recipeGridStoryColour {
    return [UIColor colorWithHexString:@"4E4E4E"];
}

+ (UIFont *)recipeGridStatFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:13.0];
}

+ (UIColor *)recipeGridStatColour {
    return [UIColor colorWithHexString:@"888888"];
}

#pragma mark - Notifications

+ (UIFont *)notificationsHeaderFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:36.0];
}

+ (UIColor *)notificationsHeaderColour {
    return [UIColor darkGrayColor];
}

+ (UIFont *)notificationCellNameFont {
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:20.0];
}

+ (UIColor *)notificationsCellNameColour {
    return [UIColor darkGrayColor];
}

+ (UIFont *)notificationCellActionFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:20.0];
}

+ (UIColor *)notificationsCellActionColour {
    return [UIColor darkGrayColor];
}

+ (UIFont *)notificationCellTimeFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:16.0];
}

+ (UIColor *)notificationsCellTimeColour {
    return [UIColor lightGrayColor];
}

#pragma mark - Book contents/activities.

+ (UIFont *)bookNavigationTitleFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:16.0];
}

+ (UIColor *)bookNavigationTitleColour {
    return [UIColor colorWithHexString:@"888888"];
}

+ (UIFont *)bookProfileNameFont {
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:40.0];
}

+ (UIColor *)bookContentsViewColour {
    return [UIColor colorWithHexString:@"3885C4"];
}

+ (UIFont *)bookContentsTitleFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:100.0];
}

+ (UIFont *)bookContentsTitleMinFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:90.0];
}

+ (UIColor *)bookContentsTitleColour {
    return [UIColor blackColor];
}

+ (UIFont *)bookContentsNameFont {
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:30.0];
}

+ (UIColor *)bookContentsNameColour {
    return [UIColor blackColor];
}

+ (UIFont *)bookContentsItemFont {
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:20.0];
}

+ (UIColor *)bookContentsItemColour {
    return [UIColor whiteColor];
}

+ (UIFont *)bookActivityHeaderFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:80.0];
}

+ (UIColor *)bookActivityHeaderColour {
    return [UIColor lightGrayColor];
}

+ (UIColor *)activityInfoViewColour {
    return [UIColor colorWithHexString:@"3885C4"];
}

+ (UIColor *)activityActionColour {
    return [UIColor whiteColor];
}

+ (UIFont *)activityActionFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:14.0];
}

+ (UIColor *)activityTimeColour {
    return [UIColor whiteColor];
}

+ (UIFont *)activityTimeFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:14.0];
}

+ (UIColor *)activityTitleColour {
    return [UIColor whiteColor];
}

+ (UIFont *)activityTitleFont {
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:20.0];
}

+ (UIColor *)activityNameColour {
    return [UIColor whiteColor];
}

+ (UIFont *)activityNameFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:16.0];
}

+ (UIFont *)bookIndexFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:24];
}

+ (UIColor *)bookIndexColour {
    return [UIColor blackColor];
}

+ (UIFont *)bookIndexSubtitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:13];
}

+ (UIColor *)bookIndexSubtitleColour {
    return [UIColor blackColor];
}

+ (UIFont *)bookIndexNumRecipesFont {
    return [self bookIndexFont];
}

+ (UIColor *)bookIndexNumRecipesColour {
    return [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.5];
}

#pragma mark - Recipe View

+ (UIColor *)ingredientsListColor {
    return [UIColor colorWithHexString:@"505050"];
}

+ (UIFont *)ingredientsListFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
}

+ (UIFont *)ingredientsListMeasurementFont {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:17.0];
}

+ (UIColor *)ingredientsListMeasurementColor {
    return [UIColor colorWithHexString:@"505050"];
}

+ (UIColor *)storyColor {
    return [UIColor colorWithHexString:@"505050"];
}

+(UIFont *)storyFont
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
}

+ (UIFont *)recipeNameFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:50];
}

+(UIColor *)recipeNameColor
{
    return [UIColor colorWithHexString:@"4e4e4e"];
    
}

+(UIFont *)methodFont
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
}

+(UIColor*) methodColor
{
    return [UIColor colorWithHexString:@"333333"];
}

+ (UIFont *)recipeStatTextFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:12.0];
}

+ (UIColor *)recipeStatTextColour {
    return [UIColor colorWithHexString:@"505050"];
}

+ (UIFont *)recipeStatValueFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:22.0];
}

+ (UIColor *)recipeStatValueColour {
    return [UIColor colorWithHexString:@"505050"];
}

+(UIFont*) cookingTimeFont
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
}
+(UIColor*) cookingTimeColor
{
    return [UIColor colorWithHexString:@"3a3a3a"];
}

+(UIFont*) servesFont
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
}

+(UIColor*) servesColor
{
    return [UIColor colorWithHexString:@"4e4e4e"];
}

+(UIFont*) categoryFont
{
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:30.0f];
}

+ (UIColor *)recipeViewBackgroundColour {
    return [UIColor colorWithHexString:@"F8F8F8"];
}

+ (UIFont *)editPhotoFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:18.0];
}

+ (UIColor *)editPhotoColour {
    return [UIColor colorWithHexString:@"4e4e4e"];
}

#pragma mark - Recipe Editing

+ (UIColor *)bookCoverInsideBackgroundColour {
    return [UIColor colorWithHexString:@"E8E8E8"];
}

+ (UIFont *)cookServesPrepEditTitleFont {
    return [UIFont fontWithName:@"Neutraface2Condensed-Titling" size:50.0];
}


+ (UIColor *)cookServesPrepEditTitleColor {
    return [UIColor whiteColor];
}

+ (UIColor *)cookServesNumberColor {
    return [UIColor lightGrayColor];
}

+ (UIFont *)cookPrepPickerFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:24.0f];
}

+(UIFont *)categoryListFont {
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:50.0];
}

+(UIColor *)categoryListSelectedColor {
    return [UIColor colorWithHexString:@"1b76b6"];
}


+ (UIFont *) typeItUpFont {
    return [Theme defaultBoldFontWithSize:28.0f];
}

+ (UIFont *) orJustAddFont {
   return [UIFont fontWithName:@"Neutraface2Display-Medium" size:20.0f];
}

+ (UIFont *)editServesTitleFont {
    return [UIFont fontWithName:@"Neutraface2Display-Bold" size:42.0];
}

+ (UIColor *)editServesTitleColour {
    return [UIColor darkGrayColor];
}

+ (UIFont *)editServesFont {
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:54.0];
}

+ (UIColor *)editServesColour {
    return [UIColor lightGrayColor];
}

+ (UIFont *)editPrepTitleFont {
    return [self editServesTitleFont];
}

+ (UIColor *)editPrepTitleColour {
    return [self editServesTitleColour];
}

+ (UIFont *)editPrepFont {
    return [self editServesFont];
}

+ (UIColor *)editPrepColour {
    return [self editServesColour];
}

+ (UIFont *)editCookTitleFont {
    return [self editServesTitleFont];
}

+ (UIColor *)editCookTitleColour {
    return [self editServesTitleColour];
}

+ (UIFont *)editCookFont {
    return [self editServesFont];
}

+ (UIColor *)editCookColour {
    return [self editServesColour];
}

+ (UIColor *)dividerRuleColour {
    return [UIColor colorWithHexString:@"EAEAEA"];
}

#pragma mark - Social view.

+ (UIFont *)bookSocialTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:32.0];
}

+ (UIColor *)bookSocialTitleColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

+ (UIFont *)bookSocialCommentBoxFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20.0];
}

+ (UIColor *)bookSocialCommentBoxColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

#pragma mark - Category View
+(UIColor*)categoryViewTextColor
{
    return [UIColor colorWithHexString:@"505050"];
}

#pragma mark - Settings

+ (UIFont *)settingsProfileFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:12.0];
}

+ (UIFont *)settingsThemeFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:14.0];
}

#pragma mark - Ingredients
+(UIFont *)ingredientAccessoryViewButtonTextFont
{
   return [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:24];
}
#pragma mark - Book Cover
+ (UIFont *)bookCoverEditableAuthorTextFont
{
   return [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:80];
}
+ (UIFont *)bookCoverEditableCaptionTextFont
{
   return [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:55];
}
+ (UIFont *)bookCoverEditableTitleTextFont
{
   return [UIFont fontWithName:@"Neutraface2Condensed-Titling" size:80];
}

+(UIFont *)bookCoverEditableFieldDescriptionFont
{
    return [UIFont fontWithName:@"Neutraface2Condensed-Titling" size:30];
}

+ (UIFont *)bookCoverViewModeNameMaxFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:56];
}

+ (UIFont *)bookCoverViewStoreModeNameMaxFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:56];
}

+ (UIFont *)bookCoverViewModeNameFontForSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:fontSize];
}

+(UIFont *)bookCoverViewModeTitleFont
{
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:14];
}

+(UIFont *)bookCoverViewModeCaptionFont
{
    return [UIFont fontWithName:@"Neutraface2Condensed-Medium" size:24];
}

#pragma mark - General reusable editable controls
+ (UIFont *)textViewTitleFont
{
    return [UIFont fontWithName:@"Neutraface2Condensed-Titling" size:30];
}

+ (UIFont *)textEditableTextFont
{
    return [UIFont fontWithName:@"Neutraface2Condensed-Medium" size:55];
}

#pragma mark - Book navigation view.

+ (UIFont *)navigationTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:16.0];
}

@end
