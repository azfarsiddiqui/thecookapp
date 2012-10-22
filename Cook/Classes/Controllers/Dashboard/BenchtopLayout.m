//
//  CKBenchtopLayout.m
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopLayout.h"

@interface BenchtopLayout ()

@end

@implementation BenchtopLayout

- (id)initWithBenchtopDelegate:(id<BenchtopDelegate>)benchtopDelegate {
    if ([super init]) {
        self.benchtopDelegate = benchtopDelegate;
    }
    return self;
}

// Subclasses to implement what to do after layout has completed after animation.
- (void)layoutCompleted {
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    CGFloat scaleFactor = [self.benchtopDelegate benchtopBookMinScaleFactor];
    initialAttributes.alpha = 0.0;
    initialAttributes.transform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 0.0);
    return initialAttributes;
}

@end
