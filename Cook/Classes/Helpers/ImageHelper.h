//
//  ImageHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 21/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageHelper : NSObject

// Sizes
+ (CGSize)thumbSize;

+ (void)configureImageView:(UIImageView *)imageView image:(UIImage *)image;

// Image scaling.
+ (UIImage *)croppedImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)scaledImage:(UIImage *)image size:(CGSize)size;
+ (UIImage *)thumbImageForImage:(UIImage *)image;

// Blurring
+ (UIImage *)blurredImage:(UIImage *)image;
+ (UIImage *)blurredSignUpImage:(UIImage *)image;
+ (UIImage *)blurredRecipeImage:(UIImage *)image;
+ (UIImage *)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour;
+ (void)blurredImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion;
+ (void)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour completion:(void (^)(UIImage *blurredImage))completion;

@end
