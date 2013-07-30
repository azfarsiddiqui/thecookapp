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

@interface CKBookCover ()

+ (NSDictionary *)settings;

@end

@implementation CKBookCover

#define kInitialCover           @"kCookInitialCover"
#define kInitialIllustration    @"kCookInitialIllustration"

+ (NSString *)initialCover {
    NSString *initialCover = [[NSUserDefaults standardUserDefaults] objectForKey:kInitialCover];
    if (!initialCover) {
        initialCover = [CKBookCover randomCover];
        [[NSUserDefaults standardUserDefaults] setObject:initialCover forKey:kInitialCover];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return initialCover;
}

+ (NSString *)initialIllustration {
    NSString *initialIllustration = [[NSUserDefaults standardUserDefaults] objectForKey:kInitialIllustration];
    if (!initialIllustration) {
        initialIllustration = [CKBookCover randomIllustration];
        [[NSUserDefaults standardUserDefaults] setObject:initialIllustration forKey:kInitialIllustration];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return initialIllustration;
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

+ (UIImage *)imageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Image", cover]];
    if (!imageName) {
        imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Image",
                                                             [CKBookCover randomCover]]];
    }
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)outlineImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Outline", cover]];
    if (!imageName) {
        imageName = [[CKBookCover settings] valueForKeyPath:@"Covers.Gray.Image"];
    }
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)thumbImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Thumb", cover]];
    return [UIImage imageNamed:imageName];
}

+ (UIColor *)colourForCover:(NSString *)cover {
    NSString *hexValue = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Hex", cover]];
    return [UIColor colorWithHexString:hexValue];
}

+ (UIColor *)backdropColourForCover:(NSString *)cover {
    NSString *hexValue = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.BackdropHex", cover]];
    return [UIColor colorWithHexString:hexValue];
}

+ (UIColor *)textColourForCover:(NSString *)cover {
    NSString *hexValue = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.TextHex", cover]];
    return [UIColor colorWithHexString:hexValue];
}

+ (UIImage *)thumbSliderContentImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.Slider", cover]];
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)recipeEditBackgroundImageForCover:(NSString *)cover {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Covers.%@.RecipeEdit", cover]];
    return [UIImage imageNamed:imageName];
}

+ (UIImage *)imageForIllustration:(NSString *)illustration {
    NSString *imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Illustrations.%@.Image", illustration]];
    if (!imageName) {
        
        // Direct image loading.
        imageName = illustration;
//        imageName = [[CKBookCover settings] valueForKeyPath:[NSString stringWithFormat:@"Illustrations.%@.Image",
//                                                           [CKBookCover randomIllustration]]];
        
    }
    return [UIImage imageNamed:imageName];
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

+ (BookCoverLayout)layoutForIllustration:(NSString *)illustration {
    return [self layoutForKey:[[CKBookCover settings] valueForKeyPath:
                               [NSString stringWithFormat:@"Illustrations.%@.Layout", illustration]]];
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

@end
