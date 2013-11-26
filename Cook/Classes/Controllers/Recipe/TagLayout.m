//
//  TagLayout.m
//  Cook
//
//  Created by Gerald Kim on 18/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "TagLayout.h"
#import "ViewHelper.h"

@interface TagLayout ()

@end

@implementation TagLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGRect bounds = self.collectionView.bounds;

    for (UICollectionViewLayoutAttributes *attribute in layoutAttributes)
    {
        [self applyTagsFading:attribute contentOffset:contentOffset bounds:bounds];
    }
    return layoutAttributes;
}

- (void)applyTagsFading:(UICollectionViewLayoutAttributes *)attributes contentOffset:(CGPoint)contentOffset
                     bounds:(CGRect)bounds {
    
    if (!attributes.representedElementKind) {
        
        CGFloat leftFadeOffset = contentOffset.x + 10;
        CGFloat rightFadeOffset = contentOffset.x + bounds.size.width - 10;
        CGFloat minAlpha = 0.0;
        CGFloat fadeRate = 1.5;
        
        CGRect frame = attributes.frame;
        if (frame.origin.x <= leftFadeOffset) {
            CGFloat effectiveDistance = 110.0;
            CGFloat distance = MIN(leftFadeOffset - frame.origin.x, effectiveDistance);
            attributes.alpha = MAX(minAlpha, 1.0 - fadeRate * (distance / effectiveDistance));
        } else if (frame.origin.x + frame.size.width >= rightFadeOffset) {
            CGFloat effectiveDistance = 110.0;
            CGFloat distance = MIN((frame.origin.x + frame.size.width) - rightFadeOffset, effectiveDistance);
            attributes.alpha = MAX(minAlpha, 1.0 - fadeRate * (distance / effectiveDistance));
        } else {
            attributes.alpha = 1.0;
        }
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

@end
