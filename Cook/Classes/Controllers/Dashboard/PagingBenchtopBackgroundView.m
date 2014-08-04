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

#define kLeftEdgeWhiteGap       50.0
#define kRightEdgeWhiteGap      50.0

+ (CGFloat)minBlendAlpha {
    return 0.6;
}

+ (CGFloat)maxBlendAlpha {
    return 0.75;
}

- (id)initWithFrame:(CGRect)frame pageWidth:(CGFloat)pageWidth {
    if (self = [super initWithFrame:frame]) {
        self.pageWidth = pageWidth;
        self.colours = [NSMutableArray array];
        self.leftEdgeColour = [UIColor whiteColor];
        self.rightEdgeColour = [UIColor whiteColor];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL equals = NO;
    if ([object isKindOfClass:[PagingBenchtopBackgroundView class]]) {
        PagingBenchtopBackgroundView *otherView = (PagingBenchtopBackgroundView *)object;
        
        if (CGSizeEqualToSize(self.frame.size, otherView.frame.size)
            && [self.colours count] == [otherView.colours count]) {
            
            // Assume to be YES until proven.
            equals = YES;
            
            for (NSUInteger colourIndex = 0; colourIndex < [self.colours count]; colourIndex++) {
                UIColor *colour = [self.colours objectAtIndex:colourIndex];
                UIColor *otherColour = [otherView.colours objectAtIndex:colourIndex];
                if (![colour isEqual:otherColour]) {
                    equals = NO;
                    break;
                }
            }
        }
    }
    return equals;
}

- (void)addColour:(UIColor *)colour {
    [self.colours addObject:colour];
}

- (void)blend {
    [self blendWithCompletion:nil];
}

- (void)blendWithCompletion:(void (^)())completion {
    
//    DLog(@"Blending Width[%f] Total[%f] Colours[%d]", self.pageWidth, self.bounds.size.width, [self.colours count]);
    
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
    [gradientColours addObject:self.leftEdgeColour];
    [colourLocations addObject:@0.0];
    [gradientColours addObject:self.leftEdgeColour];
    [colourLocations addObject:@(kLeftEdgeWhiteGap / self.bounds.size.width)];
    
    // Loop through and create the gradient points.
    for (NSInteger colourIndex = 0; colourIndex < [self.colours count]; colourIndex++) {
        
        UIColor *colour = [self.colours objectAtIndex:colourIndex];
        
        // Start of colour.
        CGFloat offset = (colourIndex * self.pageWidth) + floorf((self.pageWidth - colourWidth) / 2.0);
        CGFloat offsetRatio = offset / self.bounds.size.width;
        [gradientColours addObject:colour];
        [colourLocations addObject:@(offsetRatio)];
//        DLog(@"Start Colour [%d] at [%f][%f]", colourIndex, offset, offsetRatio);
        
        // End of colour
        offset += colourWidth;
        offsetRatio = offset / self.bounds.size.width;
        [gradientColours addObject:colour];
        [colourLocations addObject:@(offsetRatio)];
//        DLog(@"  End Colour [%d] at [%f][%f]", colourIndex, offset, offsetRatio);
        
    }
    
    // Ends with white.
    [gradientColours addObject:self.rightEdgeColour];
    [colourLocations addObject:@((self.bounds.size.width - kRightEdgeWhiteGap) / self.bounds.size.width)];
    [gradientColours addObject:self.rightEdgeColour];
    [colourLocations addObject:@1.0];
    
    // Set the gradients onto the layer.
    self.gradientLayer.colors = [gradientColours collect:^id(UIColor *colour) {
        return (id)colour.CGColor;
    }];
    self.gradientLayer.locations = colourLocations;
    
    // Add the gradient to the view
    [self.layer insertSublayer:self.gradientLayer atIndex:0];

    completion();
}

#pragma mark - Private methods

@end
