//
//  BenchtopFlowLayout.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "BenchtopCollectionFlowLayout.h"
#import "BenchtopBookCoverViewCell.h"

@implementation BenchtopCollectionFlowLayout

#define kBookScaleFactor            1.02
#define kBookRotationDegrees        5.0
#define kBookTranslate              20.0
#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        if ([self scalingRequiredForAttributes:attributes]) {
            CGFloat scaleFactor = [self scaleFactorForCenter:attributes.center];
            attributes.transform3D = CATransform3DScale(attributes.transform3D, scaleFactor, scaleFactor, 1.0);
            
        }
    }
    return layoutAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x,
                                   0.0,
                                   self.collectionView.bounds.size.width,
                                   self.collectionView.bounds.size.height);
    
    NSArray* array = [self layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    CGPoint targetContentOffset = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
    return targetContentOffset;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    CATransform3D scaleTransform = CATransform3DMakeScale(kBookScaleFactor, kBookScaleFactor, 0.0);
    CATransform3D translateTransform = CATransform3DMakeTranslation(0.0, kBookTranslate, 0.0);
    initialAttributes.alpha = 0.0;
//    initialAttributes.transform3D = scaleTransform;
    initialAttributes.transform3D = CATransform3DConcat(scaleTransform, translateTransform);
//    initialAttributes.transform3D = translateTransform;
    return initialAttributes;
}

#pragma mark - Private methods

- (CGRect)visibleFrame {
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      self.collectionView.bounds.size.width,
                      self.collectionView.bounds.size.height);
}

- (CGFloat)scaleFactorForCenter:(CGPoint)center {
    CGRect visibleRect = [self visibleFrame];
    CGSize itemSize = [BenchtopBookCoverViewCell cellSize];
    CGFloat minScaleFactor = 0.78;
    CGFloat distance = CGRectGetMidX(visibleRect) - center.x;
    CGFloat normalizedDistance = distance / itemSize.width;
    
    if (ABS(distance) <= itemSize.width) {
        CGFloat scaleFactor = 1.0 - (ABS(normalizedDistance) * (1.0 - minScaleFactor));
        return scaleFactor;
    } else {
        return minScaleFactor;
    }
}

- (BOOL)scalingRequiredForAttributes:(UICollectionViewLayoutAttributes *)attributes {
    return YES;     
    // return (attributes.indexPath.section == 1);
}

@end
