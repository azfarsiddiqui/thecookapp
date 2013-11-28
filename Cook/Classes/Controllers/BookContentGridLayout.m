//
//  BookContentGridLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentGridLayout.h"
#import "ViewHelper.h"
#import "NSString+Utilities.h"
#import "BookNavigationView.h"

@interface BookContentGridLayout ()

@property (nonatomic, weak) id<BookContentGridLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;
@property (nonatomic, strong) NSMutableArray *columnOffsets;
@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, assign) CGFloat cellStartOffset;
@property (nonatomic, assign) CGFloat headerStartOffset;

@end

@implementation BookContentGridLayout

#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 0.0, 20.0 }
#define kUnitWidth          320.0
#define kRowGap             12.0
#define kColumnGap          12.0
#define kCellsStartOffset   700.0
#define kHeaderCellsGap     200.0
#define kHeaderCellsMinGap  40.0
#define kCellsFooterGap     12.0

+ (CGSize)sizeForBookContentGridType:(BookContentGridType)gridType {
    CGSize size = CGSizeZero;
    switch (gridType) {
        case BookContentGridTypeExtraSmall:
            size = (CGSize){ kUnitWidth, 370.0 };
            break;
        case BookContentGridTypeSmall:
            size = (CGSize){ kUnitWidth, 480.0 };
            break;
        case BookContentGridTypeMedium:
            size = (CGSize){ kUnitWidth, 540.0 };
            break;
        case BookContentGridTypeLarge:
            size = (CGSize){ kUnitWidth, 640.0 };
            break;
        default:
            break;
    }
    return size;
}

- (id)initWithDelegate:(id<BookContentGridLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setNeedsRelayout:(BOOL)relayout {
    self.layoutCompleted = !relayout;
    self.contentSize = CGSizeZero;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    
    // Return cached contentSize if we have one.
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        return self.contentSize;
    }
    
    CGSize contentSize = (CGSize){ self.collectionView.bounds.size.width, 0.0 };
    contentSize.height += kContentInsets.top;
    UIOffset offset = (UIOffset){ kContentInsets.left, kCellsStartOffset };
    
    // Remember cell start offset.
    self.cellStartOffset = offset.vertical;
    
    // Set up the column offsets.
    NSInteger numColumns = [self.delegate bookContentGridLayoutNumColumns];
    self.columnOffsets = [NSMutableArray arrayWithCapacity:numColumns];
    for (NSInteger columnIndex = 0; columnIndex < numColumns; columnIndex++) {
        [self.columnOffsets addObject:@(offset.vertical)];
    }
    
    // Now go ahead and figure it out.
    offset.vertical = kCellsStartOffset;
    NSInteger numItems = [self.delegate bookContentGridLayoutNumItems];
    
    CGFloat maxHeight = 0.0;
    for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
        
        // Get the gridType and size.
        BookContentGridType gridType = [self.delegate bookContentGridTypeForItemAtIndex:itemIndex];
        CGSize size = [BookContentGridLayout sizeForBookContentGridType:gridType];
        
        // Choose the column for this go to.
        NSInteger shortestColumnIndex = [self nextShortestColumn];
        
        // Update the offset for the column.
        CGFloat columnOffset = [[self.columnOffsets objectAtIndex:shortestColumnIndex] floatValue] + size.height;
        if (itemIndex != numItems - 1) {
            columnOffset += kRowGap;    // Row gap for all rows in between.
        }
        
        [self.columnOffsets replaceObjectAtIndex:shortestColumnIndex withObject:@(columnOffset)];
        
        // Remember the maxHeight.
        if (columnOffset > maxHeight) {
            maxHeight = columnOffset;
        }
        
    }
    
    // Resolve the contentSize.
    contentSize.height += maxHeight;
    
    // Load more?
    if ([self.delegate bookContentGridLayoutLoadMoreEnabled]) {
        contentSize.height += kCellsFooterGap;
        contentSize.height += [self.delegate bookContentGridLayoutFooterSize].height;
    }
    
    contentSize.height += kContentInsets.bottom;
    contentSize.height = MAX(contentSize.height, self.collectionView.bounds.size.height);
    
    // Cache the contentSize and inform layout finished.
    self.contentSize = contentSize;
    
    return contentSize;
}

- (void)prepareLayout {
    
    // Skip if layout does not need to be regenerated.
    if (self.layoutCompleted) {
        return;
    }
    DLog();
    
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    
    [self buildHeaderLayout];
    [self buildGridLayout];
    [self buildFooterLayout];
    
    // Mark layout as generated.
    self.layoutCompleted = YES;
    
    // Inform end of layout prep.
    [self.delegate bookContentGridLayoutDidFinish];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Header/footer cells.
    for (UICollectionViewLayoutAttributes *attributes in self.supplementaryLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    // Item cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    // Apply transform for paging.
    [self applyPagingEffects:layoutAttributes];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathSupplementaryAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

#pragma mark - Private methods

- (void)buildHeaderLayout {
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *headerAttributes = [self headerLayoutAttributesForIndexPath:headerIndexPath];
    [self.supplementaryLayoutAttributes addObject:headerAttributes];
    [self.indexPathSupplementaryAttributes setObject:headerAttributes forKey:headerIndexPath];
}

- (UICollectionViewLayoutAttributes *)headerLayoutAttributesForIndexPath:(NSIndexPath *)headerIndexPath {
    CGSize headerSize = [self.delegate bookContentGridLayoutHeaderSize];
    CGFloat navigationHeight = [BookNavigationView navigationHeight];
    CGFloat availableHeaderHeight = kCellsStartOffset - navigationHeight;
    
    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
    headerAttributes.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - headerSize.width) / 2.0),
        navigationHeight + floorf((availableHeaderHeight - headerSize.height) / 2.0),
        headerSize.width,
        headerSize.height
    };
    self.headerStartOffset = headerAttributes.frame.origin.y;
    return headerAttributes;
}

- (void)buildFooterLayout {
    NSInteger numItems = [self.delegate bookContentGridLayoutNumItems];
    
    if (numItems > 0 && [self.delegate bookContentGridLayoutLoadMoreEnabled]
        && ![self.delegate bookContentGridLayoutFastForwardEnabled]) {
        
        NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:numItems inSection:0];
        UICollectionViewLayoutAttributes *footerAttributes = [self footerLayoutAttributesForIndexPath:footerIndexPath];
        [self.itemsLayoutAttributes addObject:footerAttributes];
        [self.indexPathItemAttributes setObject:footerAttributes forKey:footerIndexPath];
    }
}

- (UICollectionViewLayoutAttributes *)footerLayoutAttributesForIndexPath:(NSIndexPath *)footerIndexPath {
    CGSize footerSize = [self.delegate bookContentGridLayoutFooterSize];
    
    CGFloat maxColumnHeight = [self maxHeightForColumns];
    UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:footerIndexPath];
    footerAttributes.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - footerSize.width) / 2.0),
        maxColumnHeight + kCellsFooterGap,
        footerSize.width,
        footerSize.height
    };
    return footerAttributes;
}

- (void)buildGridLayout {
    
    // Set up the column offsets.
    UIOffset offset = (UIOffset){ kContentInsets.left, kCellsStartOffset };
    
    NSInteger numColumns = [self.delegate bookContentGridLayoutNumColumns];
    self.columnOffsets = [NSMutableArray arrayWithCapacity:numColumns];
    for (NSInteger columnIndex = 0; columnIndex < numColumns; columnIndex++) {
        [self.columnOffsets addObject:@(offset.vertical)];
    }
    
    // Now go ahead and figure it out.
    NSInteger numItems = [self.delegate bookContentGridLayoutNumItems];
    
    for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
        
        // Get the gridType and size.
        BookContentGridType gridType = [self.delegate bookContentGridTypeForItemAtIndex:itemIndex];
        CGSize size = [BookContentGridLayout sizeForBookContentGridType:gridType];
        
        // Choose the column for this go to.
        NSInteger shortestColumnIndex = [self nextShortestColumn];
        CGFloat columnOffset = [[self.columnOffsets objectAtIndex:shortestColumnIndex] floatValue];
        
        // Build the attributes.
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = (CGRect){
            [self offsetForColumnIndex:shortestColumnIndex],
            columnOffset,
            size.width,
            size.height
        };
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:indexPath];
        
        // Update the offset for the column.
        [self.columnOffsets replaceObjectAtIndex:shortestColumnIndex withObject:@(columnOffset + size.height + kRowGap)];
    }
    
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [self applyHeaderPagingEffects:attributes];
        }
    }
}

- (void)applyHeaderPagingEffects:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGSize headerSize = [self.delegate bookContentGridLayoutHeaderSize];
    
    if (visibleFrame.origin.y > 0.0) {
        
        CGFloat navigationHeight = [BookNavigationView navigationHeight];
        CGFloat availableHeaderHeight = kCellsStartOffset - visibleFrame.origin.y - navigationHeight;

        CGRect frame = attributes.frame;
        frame.origin.y = visibleFrame.origin.y + navigationHeight + floorf((availableHeaderHeight - headerSize.height) / 2.0),
        frame.origin.y = MIN(frame.origin.y, kCellsStartOffset - kHeaderCellsMinGap - headerSize.height);
        attributes.frame = frame;
    }
    
}

- (NSInteger)nextShortestColumn {
    NSInteger shortestColumnIndex = 0.0;
    CGFloat offset = MAXFLOAT;
    for (NSInteger columnIndex = 0; columnIndex < [self.columnOffsets count]; columnIndex++) {
        CGFloat currentOffset = [[self.columnOffsets objectAtIndex:columnIndex] floatValue];
        if (currentOffset < offset) {
            offset = currentOffset;
            shortestColumnIndex = columnIndex;
        }
    }
    return shortestColumnIndex;
}

- (CGFloat)maxHeightForColumns {
    CGFloat maxHeight = 0.0;
    for (NSInteger columnIndex = 0; columnIndex < [self.columnOffsets count]; columnIndex++) {
        CGFloat currentOffset = [[self.columnOffsets objectAtIndex:columnIndex] floatValue];
        if (currentOffset > maxHeight) {
            maxHeight = currentOffset;
        }
    }
    return maxHeight;
}

- (CGFloat)offsetForColumnIndex:(NSInteger)columnIndex {
    CGFloat offset = kContentInsets.left + (columnIndex * kUnitWidth);
    if (columnIndex > 0) {
        offset += columnIndex * kColumnGap;
    }
    return offset;
}

@end
