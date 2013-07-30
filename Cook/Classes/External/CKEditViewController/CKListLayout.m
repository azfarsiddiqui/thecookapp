//
//  CKListLayout.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 23/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListLayout.h"
#import "UICollectionView+Draggable.h"
#import "LSCollectionViewHelper.h"

@interface CKListLayout ()

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@end

@implementation CKListLayout

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

//// TODO Draggable doesn't work with initial/final
//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    
//    // If dragging, then default to LS behaviour.
//    if ([self.collectionView getHelper].dragging) {
//        return [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//    }
//    
//    UICollectionViewLayoutAttributes *attributes = nil;
//    if ([self animationRequiredForIndexPath:itemIndexPath]) {
//        attributes = [self startEndAttributesForIndexPath:itemIndexPath];
//    } else {
//        attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        attributes.alpha = 1.0;
//    }
//    
//    return attributes;
//}
//
//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    
//    // If dragging, then default to LS behaviour.
//    if ([self.collectionView getHelper].dragging) {
//        return [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
//    }
//
//    return [self initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//}

#pragma mark - Private methods

- (BOOL)animationRequiredForIndexPath:(NSIndexPath *)itemIndexPath {
    return (!self.dragging
            || ([self.insertedIndexPaths containsObject:itemIndexPath] || [self.deletedIndexPaths containsObject:itemIndexPath]));
}

- (UICollectionViewLayoutAttributes *)startEndAttributesForIndexPath:(NSIndexPath *)itemIndexPath {
    
    // Start from teh first row.
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    attributes.alpha = 1.0;
    attributes.zIndex = -itemIndexPath.item;
    return attributes;
}


@end
