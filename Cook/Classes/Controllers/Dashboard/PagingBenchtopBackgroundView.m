//
//  PagingBenchtopBackgroundView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PagingBenchtopBackgroundView.h"
#import "MRCEnumerable.h"
#import "ImageHelper.h"

@interface PagingBenchtopBackgroundView ()

@property (nonatomic, assign) CGFloat pageWidth;
@property (nonatomic, strong) NSMutableArray *colours;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIImageView *blurredImageView;

@end

@implementation PagingBenchtopBackgroundView

- (id)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth {
    if (self = [super initWithFrame:frame]) {
        self.pageWidth = pageWidth;
        self.colours = [NSMutableArray array];
    }
    return self;
}

- (void)addColour:(UIColor *)colour {
    [self.colours addObject:colour];
}

- (void)blend {
    [self blendWithCompletion:nil];
}

- (void)blendWithCompletion:(void (^)())completion {
    
    // Remove previous gradient and associated blur view.
    [self.gradientLayer removeFromSuperlayer];
    [self.blurredImageView removeFromSuperview];
    
    // Create the gradient with the given colours.
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    
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
        CGFloat offset = (colourIndex * self.pageWidth) + floorf((self.pageWidth - colourWidth) / 2.0);
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
    
    // Apply blur effect.
//    [self applyBlurEffectCompletion:completion];
    // Add the gradient to the view
    [self.layer insertSublayer:self.gradientLayer atIndex:0];

    completion();
}

#pragma mark - Private methods

- (void)applyBlurEffectCompletion:(void (^)())completion {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Blur the image in the background and update the layer.
    [ImageHelper blurredImage:image completion:^(UIImage *blurredImage) {
        
        // Add the gradient to the view
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
        
        self.blurredImageView = [[UIImageView alloc] initWithImage:blurredImage];
        [self addSubview:self.blurredImageView];
        
        // Calls overall completion block.
        if (completion != nil) {
            completion();
        }
    }];
    
//    UIImage *blurImage = [ImageHelper blurredImage:image];
//    self.blurredImageView = [[UIImageView alloc] initWithImage:blurImage];
//    [self addSubview:self.blurredImageView];
    
}

@end
