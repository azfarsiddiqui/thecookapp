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

@implementation ImageHelper

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

+ (UIImage *)scaledImage:(UIImage *)image size:(CGSize)size {
    return [image imageScaledToFitSize:size];
}

+ (UIImage *)blurredImage:(UIImage *)image {
    
    // Calls ImageEffects
    return [image applyBlurWithRadius:30
                            tintColor:[UIColor colorWithWhite:1.0 alpha:0.58]
                saturationDeltaFactor:1.8
                            maskImage:nil];
}

+ (void)blurredImage:(UIImage *)image completion:(void (^)(UIImage *blurredImage))completion {
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        
        // This might take awhile.
        UIImage *blurredImage = [self blurredImage:image];
        
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
