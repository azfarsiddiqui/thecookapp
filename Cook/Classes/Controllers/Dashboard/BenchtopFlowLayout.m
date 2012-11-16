//
//  CKBenchtopFlowLayout.m
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 9/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopFlowLayout.h"

@interface BenchtopFlowLayout ()

@property (nonatomic, assign) BOOL observingCollectionView;

@end

@implementation BenchtopFlowLayout

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    
    CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
    CGFloat sideGap = [self.benchtopDelegate benchtopSideGap];
    CGFloat itemOffset = [self.benchtopDelegate benchtopItemOffset];
    NSInteger numOtherBooks = [self.collectionView numberOfItemsInSection:1];
    
    // |62| + (300 + 300 + 300) + (300n) + |62| - itemOffset (600)
    numOtherBooks += 1; // Additional gap at the end.
    return CGSizeMake(sideGap + (itemSize.width * 3.0) + (itemSize.width * numOtherBooks) + sideGap + itemOffset,
                      self.collectionView.bounds.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    // Scale the books according to their distance away from the center.
    for (UICollectionViewLayoutAttributes* attributes in layoutAttributes) {
        
        if (attributes.representedElementCategory == UICollectionElementCategoryCell
            && attributes.indexPath.section == 1) {
            
            CGFloat scaleFactor = [self scaleFactorForCenter:attributes.center];
            attributes.transform3D = CATransform3DScale(attributes.transform3D, scaleFactor, scaleFactor, 1.0);
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    return attributes;
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

#pragma mark - Private

- (CGRect)visibleFrame {
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      self.collectionView.bounds.size.width,
                      self.collectionView.bounds.size.height);
}

- (CGFloat)scaleFactorForCenter:(CGPoint)center {
    CGRect visibleRect = [self visibleFrame];
    CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
    CGFloat minScaleFactor = [self.benchtopDelegate benchtopBookMinScaleFactor];
    CGFloat distance = CGRectGetMidX(visibleRect) - center.x;
    CGFloat normalizedDistance = distance / itemSize.width;
    
    if (ABS(distance) <= itemSize.width) {
        CGFloat scaleFactor = 1.0 - (ABS(normalizedDistance) * (1.0 - minScaleFactor));
        return scaleFactor;
    } else {
        return minScaleFactor;
    }
}

@end
