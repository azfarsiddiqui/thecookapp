//
//  CKBenchtopCollectionViewStackLayout.m
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 13/07/12.
//  Copyright (c) 2012 Apps Perhaps Pty Ltd. All rights reserved.
//

#import "BenchtopStackLayout.h"

@interface BenchtopStackLayout ()

@end

@implementation BenchtopStackLayout

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
    UICollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    NSInteger numItems = [self.collectionView numberOfItemsInSection:indexPath.section];
    
    if (attributes.representedElementCategory == UICollectionElementCategoryCell
        && indexPath.section == 1) {
        
        CGFloat sideGap = [self.benchtopDelegate benchtopSideGap];
        CGFloat itemOffset = [self.benchtopDelegate benchtopItemOffset];
        CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
        
        // |62| + 300 + 150
        attributes.center = CGPointMake(sideGap + itemSize.width * 3.0 + (itemSize.width / 2.0) + itemOffset,
                                        self.collectionView.center.y);
        attributes.transform3D = [self transformForIndexPath:indexPath];
        attributes.zIndex = (numItems - 1) - indexPath.item;
    }
    
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    for (UICollectionViewLayoutAttributes* attributes in layoutAttributes) {
        
        // Hide selected book.
        NSIndexPath *selectedIndexPath = [self.benchtopDelegate benchtopOpenedIndexPath];
        if ([attributes.indexPath compare:selectedIndexPath] == NSOrderedSame) {
            attributes.alpha = 0.0;
        }
        
    }
    
    return layoutAttributes;
}

#pragma mark - Private methods

- (CATransform3D)transformForIndexPath:(NSIndexPath *)indexPath {
    NSInteger numItems = [self.collectionView numberOfItemsInSection:indexPath.section];
    CGFloat scale = 1.0 - (indexPath.item * 0.1);
    CGFloat translation = indexPath.item * -40;
    
//    return CATransform3DMakeRotation([self rotationForIndexPath:indexPath], 0.0, 0.0, 1.0);
    
    // The -1 in the z-axis transform ensures that they don't overlap books in front. Changing layouts disregard
    // the z-index of the cell.
    return CATransform3DConcat(CATransform3DMakeTranslation(0.0, translation, (numItems - 1) - indexPath.item), CATransform3DMakeScale(scale, scale, 1.0));
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
