//
//  CKPagingCollectionViewLayout.m
//  CKPagingBenchtopDemo
//
//  Created by Jeff Tan-Ang on 8/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PagingCollectionViewLayout.h"

@interface PagingCollectionViewLayout ()

@property (nonatomic, weak) id<PagingCollectionViewLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;
@property (nonatomic, strong) NSMutableDictionary *deletedIndexPathItemAttributes;

@end

@implementation PagingCollectionViewLayout

#define kContentInsets          UIEdgeInsetsMake(165.0, 0.0, 155.0, 0.0)
#define kBookSize               (CGSize){ 300.0, 438.0 }
#define kMyBookSection          0
#define kFollowSection          1
#define kBookScaleFactor        1.1
#define kBookDeleteScaleFactor  0.9

+ (CGSize)bookSize {
    return kBookSize;
}

- (id)initWithDelegate:(id<PagingCollectionViewLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)markLayoutDirty {
    self.layoutCompleted = NO;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    CGSize minSize = self.collectionView.bounds.size;
    NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
    CGFloat emptyBookGap = kBookSize.width;
    
    CGSize requiredSize = (CGSize){
        kBookSize.width + emptyBookGap + (numFollowBooks * kBookSize.width),
        self.collectionView.bounds.size.height
    };
    
    return requiredSize.width > minSize.width ? requiredSize : minSize;
}

- (void)prepareLayout {
    [self buildLayout:NO];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    DLog();
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertedIndexPaths = [NSMutableArray array];
    self.deletedIndexPaths = [NSMutableArray array];
    self.deletedIndexPathItemAttributes = [NSMutableDictionary dictionary];
    
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
        else if (updateItem.updateAction == UICollectionUpdateActionDelete) {
            [self.deletedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates {
    DLog();
    [super finalizeCollectionViewUpdates];
    
    [self.insertedIndexPaths removeAllObjects];
    [self.deletedIndexPaths removeAllObjects];
    self.insertedIndexPaths = nil;
    self.deletedIndexPaths = nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Item cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    // Apply transform for paging.
    [self applyPagingEffects:layoutAttributes];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    initialAttributes.alpha = 1.0;
    
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == kMyBookSection) {
            
            // Inserted my book plops down.
            CATransform3D scaleTransform = CATransform3DScale(initialAttributes.transform3D, kBookScaleFactor, kBookScaleFactor, 0.0);
            initialAttributes.transform3D = scaleTransform;
            
        } else if (itemIndexPath.section == kFollowSection) {
            
            // Inserted followed book slides in.
            CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, 62.0, 0.0, 0.0);
            initialAttributes.transform3D = translateTransform;
        }
        
    }
    
    return initialAttributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *finalAttributes = nil;
    
    // Custom deleted item.
    if ([self.deletedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == kMyBookSection) {
            
            // Deleted my book fades away.
            finalAttributes = [self layoutAttributesForMyBook];
            finalAttributes.alpha = 0.0;
            finalAttributes.transform3D = CATransform3DScale(finalAttributes.transform3D, kBookDeleteScaleFactor, kBookDeleteScaleFactor, 0.0);
            finalAttributes.transform3D = CATransform3DTranslate(finalAttributes.transform3D, 0.0, finalAttributes.frame.size.height, 0.0);
            
        } else if (itemIndexPath.section == kFollowSection) {
            
            // Deleted follow book fades away.
            finalAttributes = [self layoutAttributesForFollowBookAtIndex:itemIndexPath.item];
            finalAttributes.alpha = 0.0;
            finalAttributes.transform3D = CATransform3DScale(finalAttributes.transform3D, kBookDeleteScaleFactor, kBookDeleteScaleFactor, 0.0);
            finalAttributes.transform3D = CATransform3DTranslate(finalAttributes.transform3D, 0.0, finalAttributes.frame.size.height, 0.0);
            
        }
    }
    
    return finalAttributes;
}

#pragma mark - Private methods

- (void)buildLayout:(BOOL)force {
    
    // If layout has already completed and not forced, then return immediately.
    if (!force && self.layoutCompleted) {
        return;
    }
    
    DLog(@"Building layout");
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    
    CGPoint cellOffset = (CGPoint) { kContentInsets.left, kContentInsets.top };
    
    // Do we have my book?
    if ([self.collectionView numberOfItemsInSection:kMyBookSection] != 0) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForMyBook];
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:attributes.indexPath];
    }
    
    // Compulsory gap: my book + empty book
    cellOffset = (CGPoint) { kBookSize.width + kBookSize.width, cellOffset.y };
    
    // Do we have followed books?
    NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
    for (NSInteger bookIndex = 0; bookIndex < numFollowBooks; bookIndex++) {
        
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForFollowBookAtIndex:bookIndex];
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:attributes.indexPath];

        cellOffset.x += kBookSize.width;
    }
    
    // Mark layout as completed.
    self.layoutCompleted = YES;
    
    // Inform delegate of updated layout.
    [self.delegate pagingLayoutDidUpdate];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForMyBook {
    NSIndexPath *myBookIndexPath = [NSIndexPath indexPathForItem:0 inSection:kMyBookSection];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:myBookIndexPath];
    attributes.frame = (CGRect) {
        kContentInsets.left,
        kContentInsets.top,
        kBookSize.width,
        kBookSize.height
    };
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForFollowBookAtIndex:(NSInteger)bookIndex {
    
    // Compulsory gap: my book + empty book
    CGPoint cellOffset = (CGPoint) { kBookSize.width + kBookSize.width, kContentInsets.top };
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:bookIndex inSection:kFollowSection];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = (CGRect) {
        cellOffset.x + (bookIndex * kBookSize.width),
        kContentInsets.top,
        kBookSize.width,
        kBookSize.height
    };
    return attributes;
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        CGFloat scaleFactor = [self scaleFactorForCenter:attributes.center];
        attributes.transform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
    }
}

- (CGRect)visibleFrame {
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      self.collectionView.bounds.size.width,
                      self.collectionView.bounds.size.height);
}

- (CGFloat)scaleFactorForCenter:(CGPoint)center {
    CGRect visibleRect = [self visibleFrame];
    CGFloat minScaleFactor = 0.78;
    CGFloat distance = CGRectGetMidX(visibleRect) - center.x;
    CGFloat normalizedDistance = distance / kBookSize.width;
    CGFloat scaleFactor = 0.0;
    
    if (ABS(distance) <= kBookSize.width) {
        scaleFactor = 1.0 - (ABS(normalizedDistance) * (1.0 - minScaleFactor));
    } else {
        scaleFactor = minScaleFactor;
    }
    
    return scaleFactor;
}

@end
