//
//  BookCover.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKUser;

typedef enum {
	BookCoverLayoutTop,
	BookCoverLayoutBottom,
	BookCoverLayoutMid,
} BookCoverLayout;

@interface CKBookCover : NSObject

+ (NSString *)guestCover;
+ (NSString *)guestIllustration;
+ (NSString *)initialCover;
+ (NSString *)initialIllustration;
+ (NSString *)defaultCover;
+ (NSString *)defaultIllustration;
+ (NSString *)randomCover;
+ (NSString *)randomIllustration;
+ (UIImage *)addCategoryImageForCover:(NSString *)cover selected:(BOOL)selected;
+ (UIImage *)addRecipeImageForCover:(NSString *)cover selected:(BOOL)selected;
+ (UIImage *)newIndicatorImageForCover:(NSString *)cover selected:(BOOL)selected;
+ (UIImage *)imageForCover:(NSString *)cover;
+ (UIImage *)outlineImageForCover:(NSString *)cover left:(BOOL)left;
+ (UIImage *)thumbImageForCover:(NSString *)cover;
+ (UIColor *)colourForCover:(NSString *)cover;
+ (UIColor *)backdropColourForCover:(NSString *)cover;
+ (UIColor *)themeBackdropColourForCover:(NSString *)cover;
+ (UIColor *)backdropColourForCover:(NSString *)cover vivid:(BOOL)vivid balance:(BOOL)balance;
+ (UIColor *)textColourForCover:(NSString *)cover;
+ (UIImage *)thumbSliderContentImageForCover:(NSString *)cover;
+ (UIImage *)recipeEditBackgroundImageForCover:(NSString *)cover;
+ (UIImage *)imageForIllustration:(NSString *)illustration;
+ (NSArray *)covers;
+ (NSArray *)illustrations;
+ (NSString *)grayCoverName;

// CKBookCoverView construction sizes.
+ (CGSize)coverImageSize;
+ (CGSize)coverShadowSize;
+ (CGSize)mediumImageSize;
+ (CGSize)mediumShadowSize;
+ (CGSize)smallCoverImageSize;
+ (CGSize)smallCoverShadowSize;
+ (UIImage *)overlayImage;
+ (UIImage *)storeOverlayImage;
+ (UIImage *)illustrationPickerOverlayImage;
+ (UIImage *)placeholderCoverImage;

+ (BookCoverLayout)layoutForIllustration:(NSString *)illustration;

@end
