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
    attributes.size = CGSizeMake(kItemWidth, kItemHeight);
    
    if (!attributes.representedElementKind) {
        CGFloat leftFadeOffset = contentOffset.x + 20;
        CGFloat rightFadeOffset = contentOffset.x + bounds.size.width - 20;
        CGFloat minAlpha = 0.0;
        CGFloat fadeRate = 1.0;
        
        CGRect frame = attributes.frame;
        if (frame.origin.x <= leftFadeOffset) {
            CGFloat effectiveDistance = 200;
            CGFloat distance = MIN(leftFadeOffset - frame.origin.x, effectiveDistance);
            CGFloat alphaNum = [self easeInWithInput:MAX(minAlpha,(1-fadeRate * (distance / effectiveDistance)))];
            attributes.alpha = alphaNum > 0.0 ? alphaNum : minAlpha;
            CATransform3D flipCellTransform = CATransform3DMakeRotation(MIN((M_PI_2) * (attributes.alpha - 1), 0), 0.0f, -1.0f, 0.0f);
            CGFloat zDistance = 1000;
            flipCellTransform.m34 = 1 / zDistance;

            CGFloat xTransform = distance * ([self easeOffsetWithInput:(1-fadeRate * (distance / effectiveDistance))] - 1);
//            CGFloat xTransform = MIN(filteredDistance * (attributes.alpha - 1), 10);
            flipCellTransform = CATransform3DTranslate(flipCellTransform, -xTransform, 0.0f, -xTransform);
            attributes.transform3D = flipCellTransform;
        
        } else if (frame.origin.x + frame.size.width >= rightFadeOffset) {
            CGFloat effectiveDistance = 200.0;
            CGFloat distance = MIN((frame.origin.x + frame.size.width) - rightFadeOffset, effectiveDistance);
            CGFloat alphaNum = [self easeInWithInput:MAX(minAlpha,(1-fadeRate * (distance / effectiveDistance)))];
            attributes.alpha = alphaNum > 0.0 ? alphaNum : minAlpha;
            CATransform3D flipCellTransform = CATransform3DMakeRotation(MAX(-M_PI_2 * (attributes.alpha - 1),0), 0.0f, -1.0f, 0.0f);
            CGFloat zDistance = 1000;
            flipCellTransform.m34 = 1 / zDistance;
            CGFloat xTransform = distance * ([self easeOffsetWithInput:(1-fadeRate * (distance / effectiveDistance))] - 1);
            flipCellTransform = CATransform3DTranslate(flipCellTransform, -xTransform, 0.0f, -xTransform);
            attributes.transform3D = flipCellTransform;
        } else {
            attributes.alpha = 1.0;
        }
    }
}

- (CGFloat)easeInWithInput:(CGFloat)t  {
//    DLog(@"T is : %f", t);
    return powf(2,8*t-8);
}

- (CGFloat)easeOffsetWithInput:(CGFloat)t {
    return t;//powf(6,4*t-4);//1.5 * powf(t-0.25,2) + 0.15; //powf(2,t)-1;
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
