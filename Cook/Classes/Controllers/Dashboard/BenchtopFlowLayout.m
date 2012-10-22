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

- (void)dealloc {
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - CKBenchtopLayout methods

- (void)layoutCompleted {
    [self applyScalingTransformAnimated:YES];
}

#pragma mark - KVO methods.

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self applyScalingTransformAnimated:NO];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UICollectionViewLayout methods

- (void)prepareLayout {
    [super prepareLayout];
    
    if (!self.observingCollectionView) {
        [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew
                                 context:NULL];
        self.observingCollectionView = YES;
    }
}

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

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes
                                                    layoutAttributesForCellWithIndexPath:indexPath];
    CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
    CGFloat sideGap = [self.benchtopDelegate benchtopSideGap];
    CGFloat itemOffset = [self.benchtopDelegate benchtopItemOffset];
    attributes.size = itemSize;
    
    if (indexPath.section == 0) {
        
        // |62| + 300 + 150
        attributes.center = CGPointMake(sideGap + itemSize.width + (itemSize.width / 2.0) + itemOffset, self.collectionView.center.y);
        
    } else {
        
        // Starts at |62| + 300 + 300 + 300 + (300n + 150)
        CGFloat offset = sideGap + itemSize.width * 3.0 + (itemSize.width * indexPath.row + (itemSize.width / 2.0)) + itemOffset;
        attributes.center = CGPointMake(offset, self.collectionView.center.y);
        // [self applyScalingTransformToLayoutAttributes:attributes];
    }
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Add my book only if it's supposed to be within frame.
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    if (attributes.frame.origin.x < rect.origin.x + rect.size.width) {
        [layoutAttributes addObject:attributes];
    }
    
    NSInteger numItems = [self.collectionView numberOfItemsInSection:1];
    for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:
                                                        [NSIndexPath indexPathForItem:itemIndex inSection:1]];
        if (attributes.frame.origin.x < rect.origin.x + rect.size.width) {
            [layoutAttributes addObject:attributes];
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

#pragma mark - Private

- (CGRect)visibleFrame {
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      self.collectionView.bounds.size.width,
                      self.collectionView.bounds.size.height);
}

- (void)applyScalingTransformAnimated:(BOOL)animated {
    CGRect visibleRect = [self visibleFrame];
    NSArray *array = [self layoutAttributesForElementsInRect:visibleRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        if (layoutAttributes.indexPath.section == 1) {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:layoutAttributes.indexPath];
            CGFloat scaleFactor = [self scaleFactorForCenter:cell.center];
            if (animated) {
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options:UIViewAnimationCurveEaseOut
                                 animations:^{
                                     cell.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            } else {
                cell.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
            }
        }
    }
}

- (void)applyScalingTransformToLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGFloat scaleFactor = [self scaleFactorForCenter:attributes.center];
    attributes.transform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
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
