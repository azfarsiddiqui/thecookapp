//
//  BookIndexLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookIndexLayout.h"
#import "BookIndexCell.h"

@interface BookIndexLayout ()

@property (nonatomic, assign) id<BookIndexLayoutDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;

@end

@implementation BookIndexLayout

#define kNumCellsPerColumn   5
#define kMaxCells           10
#define kColumnGap          30.0
#define kRowGap             15.0
#define kIndexYOffset       150.0

- (id)initWithDataSource:(id<BookIndexLayoutDataSource>)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
    }
    return self;
}

- (CGSize)collectionViewContentSize {
    return self.collectionView.bounds.size;
}

- (void)prepareLayout {
    [self buildIndexLayoutData];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return NO;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.itemsLayoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (NSInteger)numberOfCategoriesToDisplay {
    NSArray *categories = [self.dataSource bookIndexLayoutCategories];
    return ([categories count] > kMaxCells) ? kMaxCells : [categories count];
}

#pragma mark - Private methods

- (void)buildIndexLayoutData {
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    
    NSInteger numCategoriesToDisplay = [self numberOfCategoriesToDisplay];
    
    for (NSInteger categoryIndex = 0; categoryIndex < numCategoriesToDisplay; categoryIndex++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:categoryIndex inSection:0];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        layoutAttributes.frame = [self frameForCategoryIndex:categoryIndex];
        [self.itemsLayoutAttributes addObject:layoutAttributes];
        [self.indexPathItemAttributes setObject:layoutAttributes forKey:indexPath];
    }
    
}

- (NSInteger)numberOfColumns {
    NSInteger numCategoriesToDisplay = [self numberOfCategoriesToDisplay];
    return (numCategoriesToDisplay > kNumCellsPerColumn) ? 2 : 1;
}

- (CGRect)frameForCategoryIndex:(NSInteger)categoryIndex {
    CGSize cellSize = [BookIndexCell cellSize];
    NSInteger column = [self columnForCategoryIndex:categoryIndex];
    CGPoint columnOrigin = [self originForColumn:column];
    NSInteger firstCategoryIndex = [self firstCategoryIndexForColumn:column];
    NSInteger row = (categoryIndex - firstCategoryIndex);
    return CGRectMake(columnOrigin.x,
                      columnOrigin.y + (row * cellSize.height) + (row * kRowGap),
                      cellSize.width,
                      cellSize.height);
}

- (CGPoint)originForColumn:(NSInteger)column {
    CGSize cellSize = [BookIndexCell cellSize];
    CGSize availableSize = self.collectionView.bounds.size;
    NSInteger numColumns = [self numberOfColumns];
    CGFloat requiredWidth = (numColumns * cellSize.width) + ((numColumns - 1) * kColumnGap);
    CGFloat columnOffset = floorf((availableSize.width - requiredWidth) / 2.0) + ((column - 1) * (cellSize.width + kColumnGap));
    return CGPointMake(columnOffset, kIndexYOffset);
}

- (NSInteger)columnForCategoryIndex:(NSInteger)categoyIndex {
    return (categoyIndex >= kNumCellsPerColumn) ? 2 : 1;
}

- (NSInteger)firstCategoryIndexForColumn:(NSInteger)column {
    return kNumCellsPerColumn * (column - 1);
}

@end
