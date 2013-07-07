//
//  BookCover.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	BookCoverLayoutTop,
	BookCoverLayoutBottom,
} BookCoverLayout;

@interface CKBookCover : NSObject

+ (NSString *)initialCover;
+ (NSString *)initialIllustration;
+ (NSString *)defaultCover;
+ (NSString *)defaultIllustration;
+ (NSString *)randomCover;
+ (NSString *)randomIllustration;
+ (UIImage *)imageForCover:(NSString *)cover;
+ (UIImage *)outlineImageForCover:(NSString *)cover;
+ (UIImage *)thumbImageForCover:(NSString *)cover;
+ (UIColor *)colourForCover:(NSString *)cover;
+ (UIColor *)backdropColourForCover:(NSString *)cover;
+ (UIColor *)textColourForCover:(NSString *)cover;
+ (UIImage *)thumbSliderContentImageForCover:(NSString *)cover;
+ (UIImage *)imageForIllustration:(NSString *)illustration;
+ (NSArray *)covers;
+ (NSArray *)illustrations;
+ (NSString *)grayCoverName;

// CKBookCoverView construction sizes.
+ (CGSize)coverImageSize;
+ (CGSize)coverShadowSize;
+ (CGSize)smallCoverImageSize;
+ (CGSize)smallCoverShadowSize;
+ (UIImage *)overlayImage;
+ (UIImage *)storeOverlayImage;
+ (UIImage *)placeholderCoverImage;

+ (BookCoverLayout)layoutForIllustration:(NSString *)illustration;

@end
