//
//  StoreFlowLayout.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreFlowLayout.h"
#import "BenchtopBookCell.h"

@interface StoreFlowLayout ()

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@end

@implementation StoreFlowLayout

#define kStoreBookInsertScale   0.5

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertedIndexPaths = [NSMutableArray array];
    self.deletedIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
        else if (updateItem.updateAction == UICollectionUpdateActionDelete) {
            [self.deletedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
        }
    }
    
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == 0) {
            if (initialAttributes == nil) {
                initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
            }
            
            // Start on the edge of the screen.
            CGFloat translateOffset = self.collectionView.bounds.size.width - initialAttributes.frame.origin.x;
            
            // Make books further apart so that they slide in at different distances.
            translateOffset += itemIndexPath.item * (initialAttributes.frame.size.width * 2.0);
            
            CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, translateOffset, 0.0, 0.0);
            CATransform3D scaleTransform = CATransform3DScale(initialAttributes.transform3D, kStoreBookInsertScale, kStoreBookInsertScale, 0.0);
            // initialAttributes.transform3D = CATransform3DConcat(scaleTransform, translateTransform);
            initialAttributes.transform3D = translateTransform;
            initialAttributes.alpha = 1.0;
        }
        
    }

    return initialAttributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *finalAttributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    DLog(@"FINAL ATTRIBUTES %@", finalAttributes);
    DLog(@"DELETED INDEX PATHS %@", self.deletedIndexPaths);
    if ([self.deletedIndexPaths containsObject:itemIndexPath]) {
        finalAttributes.alpha = 0.0;
        finalAttributes.transform3D = CATransform3DScale(finalAttributes.transform3D, 0.1, 0.1, 0.0);
    }
    return finalAttributes;
}

- (void)finalizeCollectionViewUpdates {
    DLog();
    [self.insertedIndexPaths removeAllObjects];
    [self.deletedIndexPaths removeAllObjects];
    self.insertedIndexPaths = nil;
    self.deletedIndexPaths = nil;
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
