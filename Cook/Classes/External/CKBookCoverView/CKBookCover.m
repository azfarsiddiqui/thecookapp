//
//  BookCover.m
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBookCover.h"
#import "MRCEnumerable.h"
#import "UIColor+Expanded.h"
#import "ImageHelper.h"
#import "CKUser.h"
#import "SDImageCache.h"

@interface CKBookCover ()

+ (NSDictionary *)settings;

@end

@implementation CKBookCover

#define kInitialCover           @"kCookInitialCover"
#define kInitialIllustration    @"kCookInitialIllustration"

+ (NSString *)guestCover {
    return @"Red";
}

+ (NSString *)guestIllustration {
    return @"Rice";
}

+ (NSString *)initialCover {
    return [CKBookCover randomCover];
}

+ (NSString *)initialIllustration {
    return [CKBookCover randomIllustration];
}

+ (NSString *)defaultColourName {
    return [self guestCover];
}

+ (NSString *)defaultCover {
    return [[CKBookCover settings] valueForKeyPath:@"Covers.Red.Image"];
}

+ (NSString *)defaultIllustration {
    return [[CKBookCover settings] valueForKeyPath:@"Illustrations.Cutlery.Image"];
}

+ (NSString *)randomCover {
    NSArray *covers = [CKBookCover covers];
    return [covers objectAtIndex:arc4random() % ([covers count] - 1)];
}

+ (NSString *)randomIllustration {
    NSArray *illustrations = [CKBookCover illustrations];
    return [illustrations objectAtIndex:arc4random() % ([illustrations count] - 1)];
}

+ (NSString *)blankFeaturedIllustrationImageName {
    return @"cook_book_graphic_featured_blank.png";
}

+ (UIImage *)likeImageForCover:(NSString *)cover selected:(BOOL)selected {
    if (selected) {
        UIImage *colouredIcon = [UIImage imageNamed:[self imageNameForBaseName:@"cook_book_inner_icon_small_likes_on" cover:cover selected:NO]];
        if (!colouredIcon) {
            colouredIcon = [UIImage imageNamed:@"cook_book_inner_icon_small_likes_on.png"];
        }
        return colouredIcon;
    } else {
        return [UIImage imageNamed:@"cook_book_inner_icon_small_likes_off.png"];
    }
}

+ (UIImage *)addCategoryImageForCover:(NSString *)cover selected:(BOOL)selected {
    return [UIImage imageNamed:[self imageNameForBaseName:@"cook_book_inner_category_add" cover:cover selected:selected]];
}

+ (UIImage *)addRecipeImageForCover:(NSString *)cover selected:(BOOL)selected {
    return [UIImage imageNamed:[self imageNameForBaseName:@"cook_book_inner_icon_add" cover:cover selected:selected]];
}

+ (UIImage *)editImageForCover:(NSString *)cover selected:(BOOL)selected {
    return [UIImage imageNamed:[self imageNameForBaseName:@"cook_book_inner_icon_edit" cover:cover selected:selected]];
}

+ (UIImage *)backImageForCover:(NSString *)cover selected:(BOOL)selected {
    return [UIImage imageNamed:[self imageNameForBaseName:@"cook_book_inner_icon_back" cover:cover selected:selected]];
}

+ (UIImage *)newIndicatorImageForCover:(NSString *)cover selected:(BOOL)selected {
    return [UIImage imageNamed:[self imageNameForBaseName:@"cook_book_inner_category_new" cover:cover selected:selected]];
}

+ (UIImage *)outlineImageForCover:(NSString *)cover left:(BOOL)left {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Outline", cover]];
    if (!imageName) {
        imageName = [[CKBookCover settings] valueForKeyPath:@"Covers.Gray.Image"];
    }
    imageName = [NSString stringWithFormat:@"%@_%@", imageName, left ? @"left" : @"right"];
    return [ImageHelper imageFromDiskNamed:imageName type:@"png"];
}

+ (UIImage *)thumbImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Thumb", cover]];
    return [UIImage imageNamed:imageName];
}

+ (UIColor *)colourForCover:(NSString *)cover {
    NSString *hexValue = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Hex", cover]];
    if (!hexValue) {
        hexValue = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Hex", [CKBookCover defaultColourName]]];
    }
    return [UIColor colorWithHexString:hexValue];
}

+ (UIColor *)backdropColourForCover:(NSString *)cover {
    NSString *hexValue = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.BackdropHex", cover]];
    if (!hexValue) {
        hexValue = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.BackdropHex", [CKBookCover defaultColourName]]];
    }
    return [UIColor colorWithHexString:hexValue];
}

+ (UIColor *)bookContentTintColourForCover:(NSString *)cover {
    return [UIColor colorWithHexString:@"3D5766"];
}

+ (UIColor *)themeBackdropColourForCover:(NSString *)cover {
    BOOL vivid = NO;
    BOOL balance = NO;
    BOOL oppose = NO;
    switch ([CKUser currentTheme]) {
        case DashThemeVivid:
            vivid = YES;
            break;
        case DashThemeBalance:
            balance = YES;
            break;
        case DashThemeOppose:
            oppose = YES;
            break;
        default:
            break;
    }
    return [self backdropColourForCover:cover vivid:vivid balance:balance oppose:oppose];
}

+ (UIColor *)backdropColourForCover:(NSString *)cover vivid:(BOOL)vivid balance:(BOOL)balance oppose:(BOOL)oppose {
    if (vivid) {
        return [self backdropColourForCover:[[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Vivid", cover]]];
    } else if (balance) {
        return [self backdropColourForCover:[[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Balance", cover]]];
    } else if (oppose) {
        return [self backdropColourForCover:[[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Oppose", cover]]];
    } else {
        return [self backdropColourForCover:cover];
    }
}

+ (UIColor *)textColourForCover:(NSString *)cover {
    NSString *hexValue = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.TextHex", cover]];
    hexValue = ([hexValue length] > 0) ? hexValue : @"333333";
    return [UIColor colorWithHexString:hexValue];
}

+ (UIImage *)thumbSliderContentImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Slider", cover]];
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)recipeEditBackgroundImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.RecipeEdit", cover]];
    return [ImageHelper imageFromDiskNamed:imageName type:@"png"];
}

+ (UIImage *)imageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Image", cover]];
    if (!imageName) {
        imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Image",
                                                             [CKBookCover defaultColourName]]];
    }
    
    // Load direct from disk.
    imageName = [imageName stringByReplacingOccurrencesOfString:@".png" withString:@""];
    return [ImageHelper imageFromDiskNamed:imageName type:@".png"];
}

+ (UIImage *)imageForIllustration:(NSString *)illustration {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Illustrations.%@.Image", illustration]];
    if (!imageName) {
        
        // Direct image loading.
        imageName = illustration;
    }
    
    // Load direct from disk.
    imageName = [imageName stringByReplacingOccurrencesOfString:@".png" withString:@""];
    return [ImageHelper imageFromDiskNamed:imageName type:@".png"];
}

#pragma mark - Scaled and cached covers/illustrationsf.

+ (NSString *)smallImageNameForCover:(NSString *)cover {
    return [[NSString stringWithFormat:@"cover_%@_small", cover] lowercaseString];
}

+ (NSString *)smallImageNameForIllustration:(NSString *)illustration {
    return [[NSString stringWithFormat:@"illustration_%@_small", illustration] lowercaseString];
}

+ (NSArray *)covers {
    NSDictionary *settings = [CKBookCover settings];
    NSArray *enabledCovers = [[[settings valueForKey:@"Covers"] allKeys] select:^BOOL(NSString *cover) {
        return ([settings valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Index", cover]] != nil);
    }];
    return [enabledCovers sortedArrayUsingComparator:^NSComparisonResult(NSString *cover, NSString *cover2) {
        NSNumber *index = [settings valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Index", cover]];
        NSNumber *index2 = [settings valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Index", cover2]];
        return [index compare:index2];
    }];
}

+ (NSArray *)illustrations {
    return [[[CKBookCover settings] valueForKey:@"Illustrations"] allKeys];
}

+ (BookCoverLayout)layoutForIllustration:(NSString *)illustration guest:(BOOL)guest {
    if (guest) {
        return BookCoverLayoutTop;
    } else if (![self imageExistsForIllustration:illustration]) {
        return BookCoverLayoutMid;
    } else {
        return [self layoutForKey:[[CKBookCover settings] valueForKeyPath:
                                   [NSString stringWithFormat:@"Illustrations.%@.Layout", illustration]]];
    }
}

+ (NSString *)grayCoverName {
    return @"Gray";
}

#pragma mark - CKBookCoverView construction sizes

+ (CGSize)coverImageSize {
    return (CGSize) { 312.0, 438.0 };
}

+ (CGSize)coverShadowSize {
    return (CGSize) { 408.0, 534.0 };
}

+ (CGSize)mediumImageSize {
    return (CGSize) { 156.0, 219.0 };
}

+ (CGSize)mediumShadowSize {
    return (CGSize) { 204.0, 267.0 };
}

+ (CGSize)smallCoverImageSize {
    return (CGSize) { 104.0, 146.0 };
}

+ (CGSize)smallCoverShadowSize {
    return (CGSize) { 136.0, 178.0 };
}

+ (UIImage *)overlayImage {
    return [UIImage imageNamed:@"cook_book_overlay.png"];
}

+ (UIImage *)storeOverlayImage {
    return [ImageHelper scaledImage:[UIImage imageNamed:@"cook_book_overlay_small.png"]
                               size:[self mediumShadowSize]];
}

+ (UIImage *)illustrationPickerOverlayImage {
    return [ImageHelper scaledImage:[UIImage imageNamed:@"cook_book_overlay_small.png"]
                               size:[self smallCoverShadowSize]];
}

+ (UIImage *)placeholderCoverImage {
    return [UIImage imageNamed:[[CKBookCover settings] valueForKeyPath:@"Covers.Gray.Image"]];
}

+ (UIImage *)editButtonUnderlayImageForCover:(NSString *)cover {
    UIImage *underlayImage = [UIImage imageNamed:[NSString stringWithFormat:@"cook_dash_icons_customise_%@.png", [cover lowercaseString]]];
    return [ImageHelper mergeImage:underlayImage overImage:[UIImage imageNamed:@"cook_dash_icons_customise.png"]];
}

+ (UIImage *)editButtonUnderlayOnPressImageForCover:(NSString *)cover {
    UIImage *underlayImage = [UIImage imageNamed:[NSString stringWithFormat:@"cook_dash_icons_customise_%@.png", [cover lowercaseString]]];
    return [ImageHelper mergeImage:underlayImage overImage:[UIImage imageNamed:@"cook_dash_icons_customise_onpress.png"]];
}

+ (UIImage *)updatesIconImageForCover:(NSString *)cover {
    return [UIImage imageNamed:[NSString stringWithFormat:@"cook_dash_book_notifications_%@.png", [cover lowercaseString]]];
}

#pragma mark - Private

+ (NSDictionary *)settings {
    static dispatch_once_t pred;
    static NSDictionary *settings = nil;
    dispatch_once(&pred, ^{
        settings = [NSDictionary dictionaryWithContentsOfFile:
                    [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"covers.plist"]];
    });
    return settings;
}

+ (BookCoverLayout)layoutForKey:(NSString *)key {
    BookCoverLayout layout = BookCoverLayoutMid;
    if ([key isEqualToString:@"Layout1"]) {
        layout = BookCoverLayoutTop;
    } else if ([key isEqualToString:@"Layout2"]) {
        layout = BookCoverLayoutBottom;
    } else if ([key isEqualToString:@"Layout3"]) {
        layout = BookCoverLayoutMid;
    }
    return layout;
}

+ (NSString *)imageNameForBaseName:(NSString *)baseName cover:(NSString *)cover selected:(BOOL)selected {
    NSMutableString *imageName = [NSMutableString stringWithString:baseName];
    if (selected) {
        [imageName appendString:@"_onpress"];
    }
    [imageName appendFormat:@"_%@.png", [cover lowercaseString]];
    return imageName;
}

+ (BOOL)imageExistsForIllustration:(NSString *)illustration {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Illustrations.%@.Image", illustration]];
    return ([imageName length] > 0);
}

@end
