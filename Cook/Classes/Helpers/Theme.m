//
//  Theme.m
//  Cook
//
//  Created by Jonny Sagorin on 11/27/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "Theme.h"


@implementation Theme

#pragma mark - General

+ (BOOL)IOS7Look {
    return YES;
}

#pragma makr - Updates Notes

+ (UIFont *)updateNotesFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:24.0];
}

+ (UIColor *)updateNotesColour {
//    return [[UIColor colorWithHexString:@"00b4ff"] colorWithAlphaComponent:0.7];
    return [UIColor colorWithHexString:@"00b4ff"];
}

#pragma mark - Common Fonts

+(UIFont *)defaultFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:size];
    
}

+(UIFont *)defaultLabelFont
{
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20];
}

+(UIFont*) defaultBoldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"BrandonGrotesque-Bold" size:size];
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
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:26.0];
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
    return [UIColor colorWithHexString:@"009ce5"];
}

+ (UIColor *)storeBookActionButtonColour {
    return [UIColor whiteColor];
}

+ (UIColor *)storeBookActionButtonShadowColour {
    return [UIColor blackColor];
}

+ (UIFont *)storeBookSummaryNameFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:30.0];
}

+ (UIColor *)storeBookSummaryNameColour {
    return [UIColor whiteColor];
}

+ (UIFont *)storeBookSummaryStoryFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
}

+ (UIColor *)storeBookSummaryStoryColour {
    return [UIColor colorWithHexString:@"FFFFFF"];
}

#pragma mark - Grid category headers

+ (UIColor *)categoryHeaderBackgroundColour {
    return [UIColor clearColor];
}

#pragma mark - Grid recipe cells

+ (UIColor *)recipeGridImageBackgroundColour {
    return [UIColor colorWithHexString:@"f5f5f5"];
}

+ (UIFont *)recipeGridTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:22.0];
}

+ (UIColor *)recipeGridTitleColour {
    return [UIColor colorWithHexString:@"3A3A3A"];
}

+ (UIFont *)recipeGridIngredientsFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
}

+ (UIColor *)recipeGridIngredientsColour {
    return [UIColor colorWithHexString:@"505050"];
}

+ (UIFont *)recipeGridTimeIntervalFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
}

+ (UIColor *)recipeGridTimeIntervalColour {
    return [UIColor colorWithHexString:@"b7b7b7"];
}

+ (UIFont *)recipeGridStoryFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:15.0];
}

+ (UIColor *)recipeGridStoryColour {
    return [UIColor colorWithHexString:@"4E4E4E"];
}

+ (UIFont *)recipeGridStatFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:16.0];
}

+ (UIColor *)recipeGridStatColour {
    return [UIColor colorWithHexString:@"A0A0A0"];
}

#pragma mark - Book contents/activities.

+ (UIFont *)bookIndexFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:22.0];
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
    return [UIColor colorWithHexString:@"333333"];
}

+ (UIFont *)storyFont
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
}

+ (UIFont *)tagsFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
}

+ (UIColor *)tagsNameColor
{
    return [UIColor colorWithHexString:@"333333"];
}

+ (UIFont *)recipeNameFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:52];
}

+ (UIColor *)recipeNameColor
{
    return [UIColor colorWithHexString:@"333333"];
    
}

+ (UIFont *)pageNameFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
}

+ (UIColor *)pageNameColour {
    return [UIColor colorWithHexString:@"333333"];
}

+(UIFont *)methodFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
}

+ (UIColor*) methodColor {
    return [UIColor colorWithHexString:@"333333"];
}

+(UIFont *)creditsFont {
    return [UIFont fontWithName:@"AvenirNext-Italic" size:17.0];
}

+ (UIColor *)creditsColor {
    return [UIColor colorWithHexString:@"888888"];
}

+ (UIFont *)recipeStatTextFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:12.0];
}

+ (UIColor *)recipeStatTextColour {
    return [UIColor colorWithHexString:@"505050"];
}

+ (UIFont *)recipeStatValueFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:21.0];
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

+ (UIFont *)measureTypeFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:17.0];
}

+ (UIColor *)measureTypeColor {
    return [UIColor colorWithHexString:@"505050"];
}

+ (UIColor *)recipeViewBackgroundColour {
    return [UIColor colorWithHexString:@"F8F8F8"];
}

+ (UIFont *)editPhotoFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:20.0];
}

+ (UIColor *)editPhotoColour {
    return [UIColor colorWithHexString:@"4E4E4E"];
}

+ (UIColor *)privacyInfoColour {
    return [UIColor colorWithHexString:@"959595"];
}

+ (UIFont *)privacyInfoFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:12.0];
}

+ (UIColor *)progressSavingColour {
    return [UIColor whiteColor];
}

+ (UIFont *)progressSavingFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:40];
}

+ (UIFont *)changeMeasureFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
}

#pragma mark - Recipe Editing

+ (UIColor *)bookCoverInsideBackgroundColour {
    return [UIColor colorWithHexString:@"E8E8E8"];
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

+(UIColor *)categoryListSelectedColor {
    return [UIColor colorWithHexString:@"1b76b6"];
}

+ (UIFont *)typeItUpFont {
    return [Theme defaultBoldFontWithSize:28.0f];
}

+ (UIFont *)editServesTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:28.0];
}

+ (UIColor *)editServesTitleColour {
    return [UIColor darkGrayColor];
}

+ (UIFont *)editServesFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:28.0];
}

+ (UIColor *)editServesColour {
    return [UIColor colorWithRed:0.842 green:0.922 blue:0.997 alpha:1];
}

+ (UIFont *)editPrepTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:32.0];
}

+ (UIColor *)editPrepTitleColour {
    return [self editServesTitleColour];
}

+ (UIFont *)editPrepFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:32.0];
}

+ (UIColor *)editPrepColour {
    return [UIColor lightGrayColor];
}

+ (UIFont *)editCookTitleFont {
    return [self editPrepTitleFont];
}

+ (UIColor *)editCookTitleColour {
    return [self editPrepTitleColour];
}

+ (UIFont *)editCookFont {
    return [self editPrepFont];
}

+ (UIColor *)editCookColour {
    return [self editPrepColour];
}

+ (UIColor *)dividerRuleColour {
    return [UIColor colorWithHexString:@"EAEAEA"];
}

+ (UIFont *)tagTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:38.0];
}

+ (UIFont *)tagLabelFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:15];
}

+ (UIColor *)tagLabelColor {
    return [UIColor colorWithHexString:@"888888"];
}

+ (UIFont *)tagTitleNumberFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:38.0];
}

+ (UIColor *)tagTitleNumberColor {
    return [UIColor colorWithHexString:@"888888"];
}

+ (UIFont *)ingredientsHintTextFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20.0];
}

+ (UIColor *)ingredientsHintTextColor {
    return [UIColor colorWithHexString:@"ffffff"];
}

+ (UIColor *)ingredientsHintShadowColor {
    return [[UIColor blackColor]  colorWithAlphaComponent:0.1];
}

#pragma mark - Social view.

+ (UIFont *)recipeCommenterFont {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:20.0];
}

+ (UIColor *)recipeCommenterColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

+ (UIFont *)recipeCommentFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:18.0];
}

+ (UIColor *)recipeCommentColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

+ (UIFont *)overlayTimeFont {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:14.0];
}

+ (UIColor *)overlayTimeColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

+ (UIFont *)bookSocialTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:34.0];
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
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:13.0];
}

+ (UIFont *)settingsCookTagLineFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:12.0];
}

+ (UIColor *)settingsCookTagLineColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

#pragma mark - Ingredients

+ (UIFont *)ingredientAccessoryViewButtonTextFont {
    return [UIFont systemFontOfSize:22.0];
}

#pragma mark - Book Cover

+ (UIFont *)bookCoverViewModeNameMaxFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:58];
}

+ (UIFont *)bookCoverViewStoreModeNameMaxFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:58];
}

+ (UIFont *)bookCoverViewModeNameFontForSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:fontSize];
}

+(UIFont *)bookCoverViewModeTitleFont
{
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:14];
}

#pragma mark - Book navigation view.

+ (UIFont *)navigationTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:22.0];
}

+ (UIColor *)navigationTitleColour {
    return [UIColor colorWithHexString:@"707070"];
}

+ (UIFont *)suggestFacebookFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:22.0];
}

#pragma mark - Card messages

+ (UIFont *)cardViewTitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:16.0];
}

+ (UIColor *)cardViewTitleColour {
    return [UIColor darkGrayColor];
}

+ (UIFont *)cardViewSubtitleFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Regular" size:14.0];
}

+ (UIColor *)cardViewSubtitleColour {
    return [UIColor darkGrayColor];
}

#pragma mark - Text input text colour.

+ (UIColor *)textInputTintColour {
    return [UIColor colorWithHexString:@"56b7f0"];
}

#pragma mark - Hint text on dash.

+ (UIFont *)pullUpDownTextFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Light" size:20.0];
}

+ (UIColor *)pullUpDownTextColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

+ (UIColor *)pullUpDownShadowColour {
    return [[UIColor blackColor]  colorWithAlphaComponent:0.1];
}

@end
