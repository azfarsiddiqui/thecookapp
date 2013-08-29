//
//  ImageHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 21/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageHelper : NSObject

// UIImage loads from disk directly bypassing UIImage cache.
+ (UIImage *)imageFromDiskNamed:(NSString *)name type:(NSString *)type;

// Sizes
+ (CGSize)thumbSize;

// UIImageView loading.
+ (void)configureImageView:(UIImageView *)imageView image:(UIImage *)image;

// Legacy screen capture.
+ (UIImage *)imageFromView:(UIView *)view;

// Image scaling.
+ (UIImage *)croppedImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)scaledImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)thumbImageForImage:(UIImage *)image;
+ (UIImage *)slicedImage:(UIImage *)image frame:(CGRect)frame;

// Blurring
+ (UIImage *)blurredImage:(UIImage *)image;
+ (void)blurredSignUpImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion;
+ (UIImage *)blurredRecipeImage:(UIImage *)image;
+ (UIImage *)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour;
+ (void)blurredImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion;
+ (void)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour completion:(void (^)(UIImage *blurredImage))completion;

@end
