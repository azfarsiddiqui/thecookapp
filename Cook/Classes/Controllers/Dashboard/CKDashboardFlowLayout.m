//
//  CKDashboardFlowLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKDashboardFlowLayout.h"

@interface CKDashboardFlowLayout ()

- (CGFloat)sideInset;

@end

@implementation CKDashboardFlowLayout

#define kItemSize           CGSizeMake(300.0, 438.0)
#define kMinScale           0.78

+ (CGSize)itemSize {
    return kItemSize;
}

- (id)init {
    if ([super init]) {
        self.nextDashboard = NO;
        self.itemSize = kItemSize;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 0.0;
        self.minimumInteritemSpacing = 0.0;
        self.sectionInset = UIEdgeInsetsMake(155.0, 0.0, 155.0, 0.0);
    }
    return self;
}

- (id)initWithNextDashboard {
    if ([self init]) {
        self.nextDashboard = YES;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize {
    CGSize contentSize = CGSizeZero;
    
    if (self.nextDashboard) {
        contentSize = [super collectionViewContentSize];
        contentSize = CGSizeMake(contentSize.width - 600.0, contentSize.height);
    } else {
        contentSize = self.collectionView.bounds.size;
    }
    return contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

-  (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.nextDashboard) {
        CGSize itemSize = [CKDashboardFlowLayout itemSize];
        rect.origin.x = rect.origin.x + (itemSize.width * 2.0);
    }
    
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    CGPoint itemOffset = [self itemOffset];
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        attributes.center = CGPointMake(attributes.center.x + itemOffset.x, attributes.center.y);
        [self applyScalingTransformToLayoutAttributes:attributes];
    }
    
    return layoutAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    //horizontalCenter += [self itemOffset].x + 10.0;
    
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

    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

- (CGSize)fullContentSize {
    return [super collectionViewContentSize];
}

#pragma mark - RPDashboardFlowLayout methods

- (CGFloat)minScale {
    return kMinScale;
}

- (CGPoint)itemOffset {
    // CGFloat offset = self.nextDashboard ? -600.0 : 0.0; // Past the left edge for nextDashboard.
    CGFloat offset = self.nextDashboard ? -600.0 : 0.0; // Past the left edge for nextDashboard.
    CGPoint itemOffset = CGPointMake(offset, 0.0);
    return itemOffset;
}

- (void)applyScalingTransformToLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x,
                                    self.collectionView.contentOffset.y,
                                    self.collectionView.bounds.size.width,
                                    self.collectionView.bounds.size.height);
    CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
    CGFloat normalizedDistance = distance / kItemSize.width;
    
    if (ABS(distance) <= kItemSize.width) {
        CGFloat scaleFactor = 1.0 - (ABS(normalizedDistance) * (1.0 - kMinScale));
        attributes.transform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
        attributes.zIndex = attributes.indexPath.item;
    } else {
        attributes.transform3D = CATransform3DMakeScale(kMinScale, kMinScale, 1.0);
    }
    
}

#pragma mark - Private methods

- (CGFloat)sideInset {
    return floorf((self.collectionView.superview.bounds.size.width - (kItemSize.width * 3.0)) / 2.0);
}

@end
