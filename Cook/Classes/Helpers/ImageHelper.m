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
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)negativeImageFor:(UIImage *)image {
    
    // get width and height as integers, since we'll be using them as
    // array subscripts, etc, and this'll save a whole lot of casting
    CGSize size = image.size;
    int width = size.width;
    int height = size.height;
    
    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // draw the current image to the newly created context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
    
    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];
        
        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            // get RGB values. We're dealing with premultiplied alpha
            // here, so we need to divide by the alpha channel (if it
            // isn't zero, of course) to get uninflected RGB. We
            // multiply by 255 to keep precision while still using
            // integers
            int r, g, b;
            if(linePointer[3])
            {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else
                r = g = b = 0;
            
            // perform the colour inversion
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;
            
            // multiply by alpha again, divide by 255 to undo the
            // scaling before, store the new values and advance
            // the pointer we're reading pixel data from
            linePointer[0] = r * linePointer[3] / 255;
            linePointer[1] = g * linePointer[3] / 255;
            linePointer[2] = b * linePointer[3] / 255;
            linePointer += 4;
        }
    }
    
    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);
    
    // and return
    return returnImage;
}

+ (UIImage *)croppedImage:(UIImage *)image size:(CGSize)size {
    return [image imageCroppedToFitSize:size];
}

+ (UIImage *)scaledImage:(UIImage *)image size:(CGSize)size {
    return [image imageScaledToFitSize:size];
}

+ (UIImage *)thumbImageForImage:(UIImage *)image {
    CGSize thumbSize = [self thumbSize];
    thumbSize.width = thumbSize.width;
    thumbSize.height = thumbSize.height;
    return [image imageScaledToFitSize:thumbSize];
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
    
    // First downscale to blur.
    UIImage *scaledImage = [self scaledImage:image size:[self blurredSize]];
    
    // Calls ImageEffects
    return [scaledImage applyBlurWithRadius:30
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
