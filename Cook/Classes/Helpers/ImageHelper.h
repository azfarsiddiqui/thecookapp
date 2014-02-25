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
+ (CGSize)profileSize;

// UIImageView loading.
+ (void)configureImageView:(UIImageView *)imageView image:(UIImage *)image;

// Legacy screen capture.
+ (UIImage *)imageFromView:(UIView *)view;
+ (UIImage *)imageFromView:(UIView *)view opaque:(BOOL)opaque;
+ (UIImage *)imageFromView:(UIView *)view opaque:(BOOL)opaque scaling:(BOOL)scaling;

// Image scaling.
+ (UIImage *)croppedImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)scaledImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)thumbImageForImage:(UIImage *)image;
+ (UIImage *)slicedImage:(UIImage *)image frame:(CGRect)frame;

//Image stretching
+ (UIImage *)stretchableXImageWithName:(NSString *)imageName;
+ (UIImage *)stretchableYImageWithName:(NSString *)imageName;

// Image merge/blending.
+ (UIImage *)mergeImage:(UIImage *)image overImage:(UIImage *)image;

// Blurring
+ (UIImage *)blurredImage:(UIImage *)image;
+ (UIImage *)blurredOverlayImage:(UIImage *)image;
+ (void)blurredOverlayImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion;
+ (UIImage *)blurredRecipeImage:(UIImage *)image;
+ (UIImage *)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour;
+ (UIImage *)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour radius:(CGFloat)radius;
+ (UIImage *)blurredImageFromView:(UIView *)view;
+ (void)blurredImageFromView:(UIView *)view completion:(void (^)(UIImage *blurredImage))completion;
+ (void)blurredImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion;
+ (void)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour completion:(void (^)(UIImage *blurredImage))completion;
+ (void)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour radius:(CGFloat)radius
          completion:(void (^)(UIImage *blurredImage))completion;
+ (CGSize)blurredSize;

// Image generation.
+ (UIImage *)imageWithColour:(UIColor *)colour size:(CGSize)size;

@end
