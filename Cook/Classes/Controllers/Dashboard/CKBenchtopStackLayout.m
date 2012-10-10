//
//  CKBenchtopCollectionViewStackLayout.m
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 13/07/12.
//  Copyright (c) 2012 Apps Perhaps Pty Ltd. All rights reserved.
//

#import "CKBenchtopStackLayout.h"

@interface CKBenchtopStackLayout ()

- (CGFloat)rotationForIndexPath:(NSIndexPath *)indexPath;
- (CATransform3D)transformForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation CKBenchtopStackLayout

#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)

#pragma mark - UICollectionViewLayout methods

- (void)prepareLayout {
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize {
    // |62| + (300 + 300 + 300) + 300 + 300 + |62|
    // CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
    // CGFloat sideGap = [self.benchtopDelegate benchtopSideGap];
    // return CGSizeMake(sideGap + (itemSize.width * 5.0) + sideGap, self.collectionView.bounds.size.height);
    return self.collectionView.bounds.size;
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
        attributes.center = CGPointMake(sideGap + itemSize.width + (itemSize.width / 2.0) + itemOffset,
                                        self.collectionView.center.y);
    } else {
        // |62| + 300 + 150
        attributes.center = CGPointMake(sideGap + itemSize.width * 3.0 + (itemSize.width / 2.0) + itemOffset,
                                        self.collectionView.center.y);
        attributes.transform3D = [self transformForIndexPath:indexPath];
        attributes.zIndex = -indexPath.item;
    }
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // TODO potential optimisation here to include only first few books instead of all.
    for (NSInteger section = 0; section < 2; section++) {
        NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:
                                                            [NSIndexPath indexPathForItem:itemIndex inSection:section]];
            [layoutAttributes addObject:attributes];
        }
    }
    
    return layoutAttributes;
}

#pragma mark - Private methods

- (CATransform3D)transformForIndexPath:(NSIndexPath *)indexPath {
    return CATransform3DMakeRotation([self rotationForIndexPath:indexPath], 0.0, 0.0, 1.0);
}

- (CGFloat)rotationForIndexPath:(NSIndexPath *)indexPath {
    CGFloat rotation = 0.0;
    switch (indexPath.item % 5) {
        case 0:
            rotation = 0.0;
            break;
        case 1:
            rotation = DEGREES_TO_RADIANS(3.0);
            break;
        case 2:
            rotation = DEGREES_TO_RADIANS(5.0);
            break;
        case 3:
            rotation = -DEGREES_TO_RADIANS(3.0);
            break;
        case 4:
            rotation = -DEGREES_TO_RADIANS(5.0);
            break;
        default:
            break;
    }
    return rotation;
}

@end
