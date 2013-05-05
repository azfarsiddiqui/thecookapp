//
//  CKListCollectionViewFlowLayout.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 1/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListCollectionViewFlowLayout.h"

@interface CKListCollectionViewFlowLayout ()

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@end

@implementation CKListCollectionViewFlowLayout

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
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
    UICollectionViewLayoutAttributes *attributes = nil;
    
    if ([self animationRequiredForIndexPath:itemIndexPath]) {
        attributes = [self startEndAttributesForIndexPath:itemIndexPath];
    } else {
        attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        attributes.alpha = 1.0;
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    return [self initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
}

#pragma mark - Private methods

- (UICollectionViewLayoutAttributes *)startEndAttributesForIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    attributes.alpha = 1.0;
    attributes.zIndex = -itemIndexPath.item;
    return attributes;
}

- (BOOL)animationRequiredForIndexPath:(NSIndexPath *)itemIndexPath {
    return (!self.jumpEditMode
            && ([self.insertedIndexPaths containsObject:itemIndexPath]
                || [self.deletedIndexPaths containsObject:itemIndexPath]));
}

@end
