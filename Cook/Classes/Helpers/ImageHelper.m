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

+ (CGSize)thumbSize {
    return (CGSize) { 512.0, 384.0 };
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
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)croppedImage:(UIImage *)image size:(CGSize)size {
    return [image imageCroppedToFitSize:size];
}

+ (UIImage *)scaledImage:(UIImage *)image size:(CGSize)size {
    return [image imageScaledToFitSize:size];
}

+ (UIImage *)thumbImageForImage:(UIImage *)image {
    return [image imageScaledToFitSize:[self thumbSize]];
}

+ (UIImage *)slicedImage:(UIImage *)image frame:(CGRect)frame {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frame);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:[[AppHelper sharedInstance] screenScale]
                                     orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return cropped;
}

#pragma mark - Blurring 

+ (UIImage *)blurredImage:(UIImage *)image {
    return [self blurredImage:image tintColour:[UIColor colorWithWhite:1.0 alpha:0.58]];
}

+ (void)blurredSignUpImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion {
    [self blurredImage:image tintColour:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.38] completion:completion];
}

+ (UIImage *)blurredRecipeImage:(UIImage *)image {
    return [self blurredImage:image tintColour:[UIColor colorWithRed:22 green:35 blue:30 alpha:0.1]];
}

+ (UIImage *)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour {
    
    // Calls ImageEffects
    return [image applyBlurWithRadius:30
                            tintColor:tintColour
                saturationDeltaFactor:1.8
                            maskImage:nil];
}

+ (void)blurredImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion {
    [self blurredImage:image tintColour:[UIColor colorWithWhite:1.0 alpha:0.58] completion:completion];
}

+ (void)blurredImage:(UIImage *)image tintColour:(UIColor *)tintColour
          completion:(void (^)(UIImage *blurredImage))completion {
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        // This might take awhile.
        UIImage *blurredImage = [self blurredImage:image tintColour:tintColour];
        
        // Cascade up to UIKit again on the mainthread.
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(blurredImage);
        });
    });
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
