//
//  StoreFlowLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreFlowLayout.h"
#import "StoreBookCell.h"

@implementation StoreFlowLayout

- (id)init {
    if (self = [super init]) {
        self.itemSize = [StoreBookCell cellSize];
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    }
    return self;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    CGFloat distance = self.collectionView.bounds.size.width * (itemIndexPath.item + 1);
    initialAttributes.transform3D = CATransform3DTranslate(initialAttributes.transform3D, distance, 0.0, 0.0);
    return initialAttributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *finalAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemIndexPath];
    CGFloat distance = self.collectionView.bounds.size.width;
    finalAttributes.transform3D = CATransform3DTranslate(finalAttributes.transform3D, distance, 0.0, 0.0);
    return finalAttributes;
}

@end
