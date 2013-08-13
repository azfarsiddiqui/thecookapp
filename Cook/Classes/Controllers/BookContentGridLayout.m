//
//  BookContentGridLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentGridLayout.h"

@interface BookContentGridLayout ()

@property (nonatomic, weak) id<BookContentGridLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *columnOffsets;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation BookContentGridLayout

#define kContentInsets  (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define kRowGap         15.0

+ (CGSize)sizeForBookContentGridType:(BookContentGridType)gridType {
    CGSize size = CGSizeZero;
    switch (gridType) {
        case BookContentGridTypeExtraSmall:
            size = (CGSize){ 320.0, 340.0 };
            break;
        case BookContentGridTypeSmall:
            size = (CGSize){ 320.0, 460.0 };
            break;
        case BookContentGridTypeMedium:
            size = (CGSize){ 320.0, 560.0 };
            break;
        case BookContentGridTypeLarge:
            size = (CGSize){ 320.0, 660.0 };
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
    UIOffset offset = (UIOffset){ kContentInsets.left, kContentInsets.top };
    
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
    
    [self buildGridLayout];
    
    // Mark layout as generated.
    self.layoutCompleted = YES;
    
    // Inform end of layout prep.
    [self.delegate bookContentGridLayoutDidFinish];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
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

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

#pragma mark - Private methods

- (void)buildGridLayout {
    
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
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

@end
