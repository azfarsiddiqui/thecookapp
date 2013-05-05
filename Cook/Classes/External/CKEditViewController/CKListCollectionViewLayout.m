//
//  CKListCollectionViewLayout.m
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 2/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKListCollectionViewLayout.h"

@interface CKListCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) BOOL insertionDeletionAnimation;

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@end

@implementation CKListCollectionViewLayout

#define kHeaderHeight   91.0
#define kFooterHeight   91.0
#define kRowSpacing     15.0

#pragma mark - UICollectionViewLayout methods

- (id)initWithItemSize:(CGSize)itemSize {
    if (self = [super init]) {
        self.itemSize = itemSize;
        self.insertionDeletionAnimation = YES;
    }
    return self;
}

- (void)enableInsertionDeletionAnimation:(BOOL)enable {
    self.insertionDeletionAnimation = enable;
}

#pragma mark - UICollectionViewLayout methods

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return NO;
}

- (CGSize)collectionViewContentSize {
    CGFloat requiredHeight = 0.0;
    
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    requiredHeight += kHeaderHeight;
    requiredHeight += (numItems * self.itemSize.height) + ((numItems - 1) * kRowSpacing);
    requiredHeight += (self.collectionView.bounds.size.height - kHeaderHeight - self.itemSize.height);
    
    CGSize contentSize = CGSizeMake(self.collectionView.bounds.size.width, requiredHeight);
    return contentSize;
}

- (void)prepareLayout {
    [self buildItemLayout];
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

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSMutableArray* layoutAttributes = [NSMutableArray array];
//    
//    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
//        if (CGRectIntersectsRect(rect, attributes.frame)) {
//            [layoutAttributes addObject:attributes];
//        }
//    }
//    
//    return layoutAttributes;
    
    return self.itemsLayoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
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

- (void)buildItemLayout {
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    [self buildListLayout];
}

- (void)buildListLayout {
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    CGFloat itemOffset = kHeaderHeight;
    for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        layoutAttributes.frame = CGRectMake(floorf((self.collectionView.bounds.size.width - self.itemSize.width) / 2.0),
                                            itemOffset,
                                            self.itemSize.width,
                                            self.itemSize.height);
        
        [self.itemsLayoutAttributes addObject:layoutAttributes];
        [self.indexPathItemAttributes setObject:layoutAttributes forKey:indexPath];
        
        // Update yOffset
        itemOffset += self.itemSize.height + kRowSpacing;
    }
}

- (UICollectionViewLayoutAttributes *)startEndAttributesForIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    attributes.alpha = 1.0;
    attributes.zIndex = -itemIndexPath.item;
    return attributes;
}

- (BOOL)animationRequiredForIndexPath:(NSIndexPath *)itemIndexPath {
    return (self.insertionDeletionAnimation && ([self.insertedIndexPaths containsObject:itemIndexPath]
            || [self.deletedIndexPaths containsObject:itemIndexPath]));
}

@end
