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
            CGFloat effectiveDistance = 100.0;
            CGFloat distance = MIN(leftFadeOffset - frame.origin.x, effectiveDistance);
            attributes.alpha = MAX(minAlpha, 1.0 - fadeRate * (distance / effectiveDistance));
            CATransform3D flipCellTransform = CATransform3DMakeRotation(M_PI/3 * (attributes.alpha - 1), 0.0f, -1.0f, 0.0f);
            CGFloat zDistance = 1000;
            flipCellTransform.m34 = 1 / zDistance;
            attributes.transform3D = flipCellTransform;
        } else if (frame.origin.x + frame.size.width >= rightFadeOffset) {
            CGFloat effectiveDistance = 100.0;
            CGFloat distance = MIN((frame.origin.x + frame.size.width) - rightFadeOffset, effectiveDistance);
            attributes.alpha = MAX(minAlpha, 1.0 - fadeRate * (distance / effectiveDistance));
            CATransform3D flipCellTransform = CATransform3DMakeRotation(-M_PI/3 * (attributes.alpha - 1), 0.0f, -1.0f, 0.0f);
            CGFloat zDistance = 1000;
            flipCellTransform.m34 = 1 / zDistance;
            attributes.transform3D = flipCellTransform;
        } else {
            attributes.alpha = 1.0;
        }
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}
@end
