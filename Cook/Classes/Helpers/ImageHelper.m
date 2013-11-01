//
//  ImageHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 21/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ImageHelper.h"
#import "UIImage+ProportionalFill.h"
#import "UIImage+ImageEffects.h"
#import "AppHelper.h"

@implementation ImageHelper

#define kBlurDefaultRadius  30.0

+ (UIImage *)imageFromDiskNamed:(NSString *)name type:(NSString *)type {
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type]];
}

+ (CGSize)thumbSize {
    CGFloat screenScale = [[AppHelper sharedInstance] screenScale];
    return (CGSize) {
        512.0 / screenScale,
        384.0 / screenScale
    };
}

+ (CGSize)profileSize {
    return (CGSize) { 512.0, 512.0 };
}

+ (CGSize)blurredSize {
    return (CGSize) {
        512.0,
        384.0
    };
}

+ (void)configureImageView:(UIImageView *)imageView image:(UIImage *)image {
    if (!imageView) {
        return;
    }
    
    if (image) {
        // Fade image in if there were no prior images.
        if (!imageView.image) {
            imageView.alpha = 0.0;
            imageView.image = image;
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:UIViewAnimationCurveEaseIn
                             animations:^{
                                 imageView.alpha = 1.0;
                             }
                             completion:^(BOOL finished)  {
                             }];
            
        } else {
            
            // Otherwise change image straight away.
            imageView.image = image;
        }
    } else {
        imageView.image = nil;
    }
    
}

+ (UIImage *)imageFromView:(UIView *)view {
    return [self imageFromView:view opaque:YES];
}

+ (UIImage *)imageFromView:(UIView *)view opaque:(BOOL)opaque {
    return [self imageFromView:view opaque:opaque scaling:NO];
}

// Scaling is to produce a lower quality snapshot for scaling purposes.
+ (UIImage *)imageFromView:(UIView *)view opaque:(BOOL)opaque scaling:(BOOL)scaling {
    CGFloat scalingFactor = 0.0;    // Native.
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, opaque, scalingFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (scaling) {
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    }
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)croppedImage:(UIImage *)image size:(CGSize)size {
    return [image imageCroppedToFitSize:size];
}

+ (UIImage *)scaledImage:(UIImage *)image size:(CGSize)size {
    return [image imageCroppedToFitSize:size];
}

+ (UIImage *)thumbImageForImage:(UIImage *)image {
    CGSize thumbSize = [self thumbSize];
    return [image imageCroppedToFitSize:thumbSize];
}

+ (UIImage *)profileImageForImage:(UIImage *)image {
    return [image imageCroppedToFitSize:[self profileSize]];
}

+ (UIImage *)slicedImage:(UIImage *)image frame:(CGRect)frame {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frame);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:[[AppHelper sharedInstance] screenScale]
                                     orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return cropped;
}

#pragma mark - Blending and merging.

+ (UIImage *)mergeImage:(UIImage *)image overImage:(UIImage *)secondImage {
    
    // get size of the first image
    CGImageRef firstImageRef = image.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef)/image.scale;
    CGFloat firstHeight = CGImageGetHeight(firstImageRef)/image.scale;
    
    // get size of the second image
    CGImageRef secondImageRef = secondImage.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef)/secondImage.scale;
    CGFloat secondHeight = CGImageGetHeight(secondImageRef)/secondImage.scale;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContextWithOptions(mergedSize, NO, 0.0);
    
    //Draw images onto the context
    [image drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [secondImage drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Blurring 

+ (UIImage *)blurredImage:(UIImage *)image {
    return [self blurredImage:image tintColour:[UIColor colorWithWhite:1.0 alpha:0.58]];
}

+ (UIImage *)blurredOverlayImage:(UIImage *)image {
    return [self blurredImage:image tintColour:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.38]];
}

+ (void)blurredOverlayImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion {
    [self blurredImage:image tintColour:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.38] completion:completion];
}

+ (UIImage *)blurredRecipeImage:(UIImage *)image {
    return [self blurredImage:image tintColour:[UIColor colorWithRed:22 green:35 blue:30 alpha:0.1]];
}

+ (UIImage *)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour {
    return [self blurredImage:image tintColour:tintColour radius:kBlurDefaultRadius];
}

+ (UIImage *)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour radius:(CGFloat)radius {
    
    // First downscale to blur.
    UIImage *scaledImage = [self scaledImage:image size:[self blurredSize]];
    
    // Calls ImageEffects
    return [scaledImage applyBlurWithRadius:radius
                                  tintColor:tintColour
                      saturationDeltaFactor:1.8
                                  maskImage:nil];
}

+ (UIImage *)blurredImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self blurredOverlayImage:image];
}

+ (void)blurredImageFromView:(UIView *)view completion:(void (^)(UIImage *blurredImage))completion {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self blurredOverlayImage:image completion:^(UIImage *blurredImage) {
        completion(blurredImage);
    }];
}

+ (void)blurredImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion {
    [self blurredImage:image tintColour:[UIColor colorWithWhite:1.0 alpha:0.58] completion:completion];
}

+ (void)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour
          completion:(void (^)(UIImage *blurredImage))completion {
    
    [self blurredImage:image tintColour:tintColour radius:kBlurDefaultRadius completion:completion];
}

+ (void)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour radius:(CGFloat)radius
          completion:(void (^)(UIImage *blurredImage))completion {
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        // This might take awhile.
        UIImage *blurredImage = [self blurredImage:image tintColour:tintColour radius:radius];
        
        // Cascade up to UIKit again on the mainthread.
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(blurredImage);
        });
    });
}

#pragma mark - Stretching

+ (UIImage *)stretchableXImageWithName:(NSString *)imageName
{
    UIImage *stretchImage = [UIImage imageNamed:imageName];
    return [stretchImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, stretchImage.size.width/2, 0, stretchImage.size.width/2)];
}

+ (UIImage *)stretchableYImageWithName:(NSString *)imageName
{
    UIImage *stretchImage = [UIImage imageNamed:imageName];
    return [stretchImage resizableImageWithCapInsets:UIEdgeInsetsMake(stretchImage.size.height/2, 0, stretchImage.size.height/2, 0)];
}

#pragma mark - Private

+ (UIImage *)coreImageBlurWithImage:(UIImage *)image {
    
    //create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    //setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    //CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    //add our blurred image to the scrollview
    return [UIImage imageWithCGImage:cgImage];
}

@end
