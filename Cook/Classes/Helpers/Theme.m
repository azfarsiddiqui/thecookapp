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

#pragma mark - Common Colors

+(UIColor *)defaultLabelColor
{
    return [UIColor colorWithHexString:@"707070"];
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

#pragma mark - Grid recipe cells

+ (UIFont *)recipeGridTitleFont {
    return [self defaultBoldFontWithSize:30.0];
}

+ (UIColor *)recipeGridTitleColour {
    return [UIColor colorWithHexString:@"505050"];
}

#pragma mark - Recipe View
+(UIColor *)ingredientsListColor
{
    return [UIColor colorWithHexString:@"3a3a3a"];
    
}

+(UIFont *)ingredientsListFont
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
}

+(UIColor*) pageNumberPrefixLabelColor
{
    return [UIColor colorWithHexString:@"2D6CA9"];
}

#pragma mark - Category View
+(UIColor*)categoryViewTextColor
{
    return [UIColor colorWithHexString:@"505050"];
}

#pragma mark - Settings

+ (UIFont *)settingsProfileFont {
    return [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:18];
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

+(UIFont *)bookCoverViewModeTitleMinFont
{
    return [UIFont fontWithName:@"Neutraface2Condensed-Titling" size:60];;
}

+(UIFont *)bookCoverViewModeTitleMidFont
{
    return [UIFont fontWithName:@"Neutraface2Condensed-Titling" size:70];
}

+(UIFont *)bookCoverViewModeTitleMaxFont
{
    return [UIFont fontWithName:@"Neutraface2Condensed-Titling" size:96];
}

+(UIFont *)bookCoverViewModeAuthorFont
{
    return [UIFont fontWithName:@"Neutraface2Condensed-Bold" size:20];
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




@end
