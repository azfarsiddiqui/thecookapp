//
//  BookContentGridLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentGridLayout.h"
#import "ViewHelper.h"

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

#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define kUnitWidth          320.0
#define kRowGap             12.0
#define kColumnGap          12.0
#define kHeaderCellsGap     200.0
#define kHeaderCellsMinGap  20.0

+ (CGSize)sizeForBookContentGridType:(BookContentGridType)gridType {
    CGSize size = CGSizeZero;
    switch (gridType) {
        case BookContentGridTypeExtraSmall:
            size = (CGSize){ kUnitWidth, 340.0 };
            break;
        case BookContentGridTypeSmall:
            size = (CGSize){ kUnitWidth, 460.0 };
            break;
        case BookContentGridTypeMedium:
            size = (CGSize){ kUnitWidth, 560.0 };
            break;
        case BookContentGridTypeLarge:
            size = (CGSize){ kUnitWidth, 660.0 };
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
    
    DLog();
    CGSize contentSize = (CGSize){ self.collectionView.bounds.size.width, 0.0 };
    contentSize.height += kContentInsets.top;
    UIOffset offset = (UIOffset){ kContentInsets.left, kContentInsets.top };
    
    // Header offsets.
    CGSize headerSize = [self.delegate bookContentGridLayoutHeaderSize];
    offset.vertical += floorf((self.collectionView.bounds.size.height - headerSize.height) / 2.0) + headerSize.height + kHeaderCellsGap;
    
    // Remember cell start offset.
    self.cellStartOffset = offset.vertical;
    
    // Set up the column offsets.
    NSInteger numColumns = [self.delegate bookContentGridLayoutNumColumns];
    self.columnOffsets = [NSMutableArray arrayWithCapacity:numColumns];
    for (NSInteger columnIndex = 0; columnIndex < numColumns; columnIndex++) {
        [self.columnOffsets addObject:@(offset.vertical)];
    }
    
    // Now go ahead and figure it out.
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    CGFloat maxHeight = 0.0;
    for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
        
        // Get the gridType and size.
        BookContentGridType gridType = [self.delegate bookContentGridTypeForItemAtIndex:itemIndex];
        CGSize size = [BookContentGridLayout sizeForBookContentGridType:gridType];
        
        // Choose the column for this go to.
        NSInteger shortestColumnIndex = [self nextShortestColumn];
        
        // Update the offset for the column.
        CGFloat columnOffset = [[self.columnOffsets objectAtIndex:shortestColumnIndex] floatValue] + size.height + kRowGap;
        [self.columnOffsets replaceObjectAtIndex:shortestColumnIndex withObject:@(columnOffset)];
        
        // Remember the maxHeight.
        if (columnOffset > maxHeight) {
            maxHeight = columnOffset;
        }
        
    }
    
    // Resolve the contentSize.
    contentSize.height += maxHeight;
    contentSize.height += kContentInsets.bottom;
    
    // Cache the contentSize and inform layout finished.
    self.contentSize = contentSize;
    [self.delegate bookContentGridLayoutDidFinish];
    
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
    
    // Header cells.
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
    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
    headerAttributes.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - headerSize.width) / 2.0),
        floorf((self.collectionView.bounds.size.height - headerSize.height) / 2.0),
        headerSize.width,
        headerSize.height
    };
    self.headerStartOffset = headerAttributes.frame.origin.y;
    return headerAttributes;
}

- (void)buildGridLayout {
    
    // Set up the column offsets.
    UIOffset offset = (UIOffset){ kContentInsets.left, kContentInsets.top };
    
    // Increment by the header and headerGap.
    UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    offset.vertical += headerAttributes.frame.origin.y + headerAttributes.frame.size.height + kHeaderCellsGap;
    
    NSInteger numColumns = [self.delegate bookContentGridLayoutNumColumns];
    self.columnOffsets = [NSMutableArray arrayWithCapacity:numColumns];
    for (NSInteger columnIndex = 0; columnIndex < numColumns; columnIndex++) {
        [self.columnOffsets addObject:@(offset.vertical)];
    }
    
    // Now go ahead and figure it out.
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
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
        CGFloat dragRatio = 0.6;
        CGFloat effectiveDistance = self.cellStartOffset - self.headerStartOffset - headerSize.height - kHeaderCellsMinGap;
        CGFloat distance = visibleFrame.origin.y * dragRatio;
        CGFloat ratio = MIN(distance / effectiveDistance, 1.0);
        CGFloat translate = effectiveDistance * ratio;
        attributes.transform3D = CATransform3DMakeTranslation(0.0, translate, 0.0);
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
