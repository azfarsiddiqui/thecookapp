//
//  PagingBenchtopBackgroundView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PagingBenchtopBackgroundView.h"
#import "UIImage+ImageEffects.h"
#import "MRCEnumerable.h"

@interface PagingBenchtopBackgroundView ()

@property (nonatomic, strong) NSMutableArray *colours;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIImageView *blurredImageView;

@end

@implementation PagingBenchtopBackgroundView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.colours = [NSMutableArray array];
    }
    return self;
}

- (void)addColour:(UIColor *)colour {
    [self.colours addObject:colour];
}

- (void)blend {
    
    // Remove previous gradient and associated blur view.
    [self.gradientLayer removeFromSuperlayer];
    [self.blurredImageView removeFromSuperview];
    
    // Create the gradient with the given colours.
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    
    CGFloat pageWidth = 1024.0;
    CGFloat colourWidth = 100.0;
    NSMutableArray *gradientColours = [NSMutableArray array];
    
    // Set direction from left to right.
    self.gradientLayer.startPoint = (CGPoint) { 0.0, 0.5 };
    self.gradientLayer.endPoint = (CGPoint) { 1.0, 0.5 };
    
    // Create the gradient colours and stops, and start with white.
    NSMutableArray *colourLocations = [NSMutableArray arrayWithCapacity:[self.colours count]];
    [gradientColours addObject:[UIColor whiteColor]];
    [colourLocations addObject:@0.0];
    
    // Loop through and create the gradient points.
    for (NSInteger colourIndex = 0; colourIndex < [self.colours count]; colourIndex++) {
        
        UIColor *colour = [self.colours objectAtIndex:colourIndex];
        
        // Start of colour.
        CGFloat offset = (colourIndex * pageWidth) + floorf((pageWidth - colourWidth) / 2.0);
        CGFloat offsetRatio = offset / self.bounds.size.width;
        [gradientColours addObject:colour];
        [colourLocations addObject:@(offsetRatio)];
        // DLog(@"Start Colour [%d] at [%f]", colourIndex, offsetRatio);
        
        // End of colour
        offset += colourWidth;
        offsetRatio = offset / self.bounds.size.width;
        [gradientColours addObject:colour];
        [colourLocations addObject:@(offsetRatio)];
        // DLog(@"  End Colour [%d] at [%f]", colourIndex, offsetRatio);
        
    }
    
    // Ends with white.
    [gradientColours addObject:[UIColor whiteColor]];
    [colourLocations addObject:@1.0];
    
    // Set the gradients onto the layer.
    self.gradientLayer.colors = [gradientColours collect:^id(UIColor *colour) {
        return (id)colour.CGColor;
    }];
    self.gradientLayer.locations = colourLocations;
    
    // Add the gradient to the view
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
    
    [self applyBlurEffect];
}

#pragma mark - Private methods

- (void)applyBlurEffect {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self drawViewHierarchyInRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blurImage = [self blurWithImage:image];
    
    self.blurredImageView = [[UIImageView alloc] initWithImage:blurImage];
    [self addSubview:self.blurredImageView];
}

- (UIImage *)blurWithImage:(UIImage *)image {
    
    return [image applyBlurWithRadius:30
                            tintColor:[UIColor colorWithWhite:1.0 alpha:0.7]
                saturationDeltaFactor:1.8
                            maskImage:nil];
}

- (UIImage *)coreImageBlurWithImage:(UIImage *)image {
    
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
