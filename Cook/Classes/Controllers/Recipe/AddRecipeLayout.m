//
//  AddRecipeLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "AddRecipeLayout.h"
#import "ModalOverlayHeaderView.h"
#import "AddRecipePageCell.h"
#import "ViewHelper.h"

@interface AddRecipeLayout ()

@property (nonatomic, weak) id<AddRecipeLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, assign) CGSize cachedContentSize;

@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *headerAttributes;

@end

@implementation AddRecipeLayout

#define kContentInsets      (UIEdgeInsets){ 0.0, 15.0, 50.0, 15.0 }
#define kMaxItemsPerRow     3
#define kRowGap             30.0
#define kColGap             30.0

- (id)initWithDelegate:(id<AddRecipeLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setNeedsRelayout:(BOOL)relayout {
    self.cachedContentSize = CGSizeZero;
    self.layoutCompleted = !relayout;
}

#pragma mark - UICollectionViewLayout methods

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (CGSize)collectionViewContentSize {
    if (!CGSizeEqualToSize(self.cachedContentSize, CGSizeZero)) {
        return self.cachedContentSize;
    }
    
    CGFloat requiredHeight = 0.0;
    
    // Top inset.
    requiredHeight += kContentInsets.top;
    
    // Header.
    requiredHeight += [ModalOverlayHeaderView unitSize].height;
    
    // Page items.
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    if (numItems > 0) {
        requiredHeight += [self requiredSizeForCells].height;
    }
    
    // Bottom inset.
    requiredHeight += kContentInsets.bottom;
    
    self.cachedContentSize = (CGSize){
        self.collectionView.bounds.size.width,
        MAX(requiredHeight, self.collectionView.bounds.size.height)
    };
    return self.cachedContentSize;
}

- (void)prepareLayout {
    
    // Skip if layout does not need to be regenerated.
    if (self.layoutCompleted) {
        return;
    }
    DLog();
    
    [self buildLayout];
    
    // Mark layout as generated.
    self.layoutCompleted = YES;
    
    // Inform end of layout prep.
    [self.delegate addRecipeLayoutDidFinish];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGRect bounds = self.collectionView.bounds;
    
    // Always contain all supplementary views and effects.
    NSMutableArray* layoutAttributes = [NSMutableArray arrayWithObject:self.headerAttributes];
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
//        [self applyStickyHeaderFooter:attributes contentOffset:contentOffset bounds:bounds];
    }
    
    // Item cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        
        // Comments.
        if (CGRectIntersectsRect(visibleFrame, attributes.frame)) {
//            [self applyCommentsFading:attributes contentOffset:contentOffset bounds:bounds];
            [layoutAttributes addObject:attributes];
        }
        
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return self.headerAttributes;
}

#pragma mark - Private methods

- (void)buildLayout {
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.headerAttributes = nil;
    
    CGRect bounds = self.collectionView.bounds;
    [self buildPagesLayoutWithBounds:bounds];
}

- (void)buildPagesLayoutWithBounds:(CGRect)bounds {
    
    // Init the vertical offset.
    CGFloat yOffset = kContentInsets.top;
    
    // Header layout.
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    self.headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                                withIndexPath:headerIndexPath];
    self.headerAttributes.frame = (CGRect){
        bounds.origin.x,
        yOffset,
        bounds.size.width,
        [ModalOverlayHeaderView unitSize].height
    };
    yOffset += self.headerAttributes.frame.size.height;
    self.headerAttributes = self.headerAttributes;
    
    // Center the block of cells.
    CGSize requiredSizeForCells = [self requiredSizeForCells];
    if (requiredSizeForCells.height < self.collectionView.bounds.size.height - self.headerAttributes.frame.size.height) {
        yOffset = floorf((self.collectionView.bounds.size.height - requiredSizeForCells.height) / 2.0);
    }
    
    // Pages layout.
    CGFloat sideOffset = floorf((self.collectionView.bounds.size.width - requiredSizeForCells.width) / 2.0);
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    CGSize cellSize = [AddRecipePageCell cellSize];
    
    CGFloat xOffset = sideOffset;
    CGFloat colIndex = 0;
    for (NSInteger pageIndex = 0; pageIndex < numItems; pageIndex++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:pageIndex inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){
            xOffset,
            yOffset,
            cellSize.width,
            cellSize.height
        };
        
        // Next row down.
        if (colIndex == kMaxItemsPerRow - 1) {
            colIndex = 0;
            xOffset = sideOffset;
            yOffset += kRowGap;
        } else {
            colIndex += 1;
            xOffset += cellSize.width + kColGap;
        }
        
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:indexPath];
        
    }
}

- (CGSize)requiredSizeForCells {
    CGSize requiredSize = CGSizeZero;
    CGSize cellSize = [AddRecipePageCell cellSize];
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    if (numItems > 0) {
        
        NSInteger numRows = (numItems / kMaxItemsPerRow) + 1;
        
        // Width.
        NSInteger numCols = kMaxItemsPerRow;
        if (numItems < kMaxItemsPerRow) {
            numCols = numItems;
        }
        requiredSize.width += (numCols * cellSize.width);
        requiredSize.width += ((numCols - 1) * kColGap);
        
        // Height
        requiredSize.height += (numRows * cellSize.height);
        requiredSize.height += ((numRows - 1) * kRowGap);
        
    }
    return requiredSize;
}

@end
