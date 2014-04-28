//
//  StoreCollectionViewLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 24/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreCollectionViewLayout.h"
#import "StoreBookCoverViewCell.h"
#import "CKCollectionViewSpringsHelper.h"

@interface StoreCollectionViewLayout ()

@property (nonatomic, weak) id<StoreCollectionViewLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@property (nonatomic, assign) BOOL springsEnabled;
@property (nonatomic, strong) CKCollectionViewSpringsHelper *springsHelper;

@end

@implementation StoreCollectionViewLayout

#define PAGE_INSETS (UIEdgeInsets){ 22.0, 60.0, 0.0, 60.0 }
#define BOOK_GAP    25.0

- (id)initWithDelegate:(id<StoreCollectionViewLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        
        self.springsEnabled = YES;
        if (self.springsEnabled) {
            self.springsHelper = [[CKCollectionViewSpringsHelper alloc] initWithCollectionViewLayout:self];
        }
    }
    return self;
}

- (void)setNeedsRelayout:(BOOL)relayout {
    self.layoutCompleted = !relayout;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    CGSize size = [StoreBookCoverViewCell cellSize];
    
    if (numItems > 0) {
        return (CGSize) {
            PAGE_INSETS.left + (numItems * size.width) + ((numItems - 1) * BOOK_GAP) + PAGE_INSETS.right,
            self.collectionView.bounds.size.height
        };
    } else {
        return self.collectionView.bounds.size;
    }
    
}

- (void)prepareLayout {
    
    // Skip if layout does not need to be regenerated.
    if (self.layoutCompleted) {
        return;
    }
    DLog();
    
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    
    [self buildBooksLayout];
    
    // Mark layout as generated.
    self.layoutCompleted = YES;
    
    // Inform end of layout prep.
    [self.delegate storeCollectionViewLayoutDidFinish];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    if (self.springsEnabled) {
        return [self.springsHelper shouldInvalidateAfterApplyingOffsetsForNewBounds:newBounds collectionView:self.collectionView];
    } else {
        return NO;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    if (self.springsEnabled) {
        [layoutAttributes addObjectsFromArray:[self.springsHelper layoutAttributesInFrame:rect]];
    } else {
        
        // Item cells.
        for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [layoutAttributes addObject:attributes];
            }
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.springsEnabled) {
        return [self.springsHelper layoutAttributesAtIndexPath:indexPath];
    } else {
        return [self.indexPathItemAttributes objectForKey:indexPath];
    }
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
            CGFloat translateOffset = self.collectionView.bounds.size.width - 60.0;
            
            // Make books further apart so that they slide in at different distances.
            translateOffset += itemIndexPath.item * (initialAttributes.frame.size.width * 3.0);
            
            CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, translateOffset, 0.0, 0.0);
            initialAttributes.transform3D = translateTransform;
            initialAttributes.alpha = 1.0;
        }
        
    }
    
    return initialAttributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *finalAttributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
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


#pragma mark - Private methods

- (void)buildBooksLayout {
    
    // Reset all behaviours.
    if (self.springsEnabled) {
        [self.springsHelper reset];
    }
    
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    CGSize size = [StoreBookCoverViewCell cellSize];
    
    for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
        
        // Single page layout.
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        attributes.frame = (CGRect){
            PAGE_INSETS.left + (itemIndex * size.width) + (itemIndex * BOOK_GAP),
            PAGE_INSETS.top,
            size.width,
            size.height
        };
//        DLog(@"*** ORIGIN %@", NSStringFromCGPoint(attributes.frame.origin));
        
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:indexPath];
        
        if (self.springsEnabled) {
            [self.springsHelper applyAttachmentBehaviourToAttributes:attributes];
        }
        
    }
}

@end
