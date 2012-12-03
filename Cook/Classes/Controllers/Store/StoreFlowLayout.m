//
//  StoreFlowLayout.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreFlowLayout.h"

@implementation StoreFlowLayout

#define kStoreBookInsertScale   0.5
#define kStoreBookScale         0.5

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
        attributes.transform3D = CATransform3DScale(attributes.transform3D, kStoreBookScale, kStoreBookScale, 1.0);
    }
    return layoutAttributes;
}


- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    // Start on the edge of the screen.
    CGFloat translateOffset = self.collectionView.bounds.size.width - initialAttributes.frame.origin.x;
    
    // Make books further apart so that they slide in at different distances.
    translateOffset += itemIndexPath.item * (initialAttributes.frame.size.width * 2.0);
    
    CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, translateOffset, 0.0, 0.0);
    CATransform3D scaleTransform = CATransform3DScale(initialAttributes.transform3D, kStoreBookInsertScale, kStoreBookInsertScale, 0.0);
    initialAttributes.transform3D = CATransform3DConcat(scaleTransform, translateTransform);
    return initialAttributes;
}

//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
//                                 withScrollingVelocity:(CGPoint)velocity {
//    CGFloat offsetAdjustment = MAXFLOAT;
//    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
//    
//    CGRect targetRect = CGRectMake(proposedContentOffset.x,
//                                   0.0,
//                                   self.collectionView.bounds.size.width,
//                                   self.collectionView.bounds.size.height);
//    
//    NSArray* array = [self layoutAttributesForElementsInRect:targetRect];
//    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
//        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
//        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
//            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
//        }
//    }
//    
//    CGPoint targetContentOffset = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
//    return targetContentOffset;
//}

#pragma mark - Private methods

@end
