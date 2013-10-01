//
//  RecipeSocialLikeLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSocialLikeLayout.h"

@implementation RecipeSocialLikeLayout

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    attributes.transform3D = CATransform3DMakeScale(0.9, 0.9, 1.0);
    attributes.alpha = 0.0;
    return attributes;
}

@end
