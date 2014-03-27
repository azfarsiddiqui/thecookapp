//
//  BookContentGridLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeGridLayout.h"
#import "ViewHelper.h"
#import "NSString+Utilities.h"
#import "BookNavigationView.h"
#import "CKRecipe.h"

@interface RecipeGridLayout ()

@property (nonatomic, weak) id<RecipeGridLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;
@property (nonatomic, strong) NSMutableArray *columnOffsets;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;

@property (nonatomic, assign) CGFloat cellStartOffset;
@property (nonatomic, assign) CGFloat headerStartOffset;

@end

@implementation RecipeGridLayout

#define kContentInsets      (UIEdgeInsets){ 20.0, 20.0, 0.0, 20.0 }
#define kUnitWidth          320.0
#define kRowGap             12.0
#define kColumnGap          12.0
#define kHeaderCellsGap     200.0
#define kHeaderCellsMinGap  40.0
#define kNumColumns         3
#define kFooterInsets       (UIEdgeInsets){ 5.0, 0.0, 10.0, 0.0 }

+ (CGSize)sizeForBookContentGridType:(RecipeGridType)gridType {
    CGSize size = CGSizeZero;
    switch (gridType) {
        case RecipeGridTypeExtraSmall:
            size = (CGSize){ kUnitWidth, 370.0 };
            break;
        case RecipeGridTypeSmall:
            size = (CGSize){ kUnitWidth, 510.0 };
            break;
        case RecipeGridTypeMedium:
            size = (CGSize){ kUnitWidth, 570.0 };
            break;
        case RecipeGridTypeLarge:
            size = (CGSize){ kUnitWidth, 650.0 };
            break;
        default:
            break;
    }
    return size;
}

+ (RecipeGridType)gridTypeForRecipe:(CKRecipe *)recipe {
    
    // Defaults to large, which makes computing combinations easier.
    RecipeGridType gridType = RecipeGridTypeLarge;
    
    if ([recipe hasPhotos]) {
        
        if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title -Story -Method -Ingredients
            gridType = RecipeGridTypeSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo +Title -Story -Method -Ingredients
            gridType = RecipeGridTypeSmall;
            
        } else if (![recipe hasTitle] && [recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title +Story -Method -Ingredients
            gridType = RecipeGridTypeMedium;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // +Photo -Title -Story +Method -Ingredients
            gridType = RecipeGridTypeMedium;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && [recipe hasIngredients]) {
            
            // +Photo -Title -Story -Method +Ingredients
            gridType = RecipeGridTypeMedium;
            
        }
        
    } else {
        
        if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo +Title -Story -Method -Ingredients
            gridType = RecipeGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && [recipe hasStory] && ![recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo -Title +Story -Method -Ingredients
            gridType = RecipeGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo -Title -Story +Method -Ingredients
            gridType = RecipeGridTypeExtraSmall;
            
        } else if (![recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && [recipe hasIngredients]) {
            
            // -Photo -Title -Story -Method +Ingredients
            gridType = RecipeGridTypeExtraSmall;
            
        } else if ([recipe hasTitle] && [recipe hasStory] && ![recipe hasIngredients]) {
            
            // -Photo +Title +Story (+/-)Method -Ingredients
            gridType = RecipeGridTypeSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo +Title -Story +Method -Ingredients
            gridType = RecipeGridTypeSmall;
            
        } else if ([recipe hasTitle] && ![recipe hasStory] && ![recipe hasMethod] && [recipe hasIngredients]) {
            
            // -Photo +Title -Story -Method +Ingredients
            gridType = RecipeGridTypeSmall;
            
        } else if (![recipe hasTitle] && [recipe hasStory] && [recipe hasMethod] && ![recipe hasIngredients]) {
            
            // -Photo -Title +Story +Method
            gridType = RecipeGridTypeExtraSmall;
        }
    }
    
    //    DLog(@"recipe[%@] gridType[%d]", recipe.name, gridType);
    
    return gridType;
}

+ (NSString *)cellIdentifierForGridType:(RecipeGridType)gridType {
    return [NSString stringWithFormat:@"GridType%ld", (unsigned long)gridType];
}

#pragma mark - Instance methods

- (id)initWithDelegate:(id<RecipeGridLayoutDelegate>)delegate {
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
    UIOffset offset = (UIOffset){ kContentInsets.left, [self.delegate recipeGridCellsOffset] };
    
    // Remember cell start offset.
    self.cellStartOffset = offset.vertical;
    
    // Set up the column offsets.
    NSInteger numColumns = kNumColumns;
    self.columnOffsets = [NSMutableArray arrayWithCapacity:numColumns];
    for (NSInteger columnIndex = 0; columnIndex < numColumns; columnIndex++) {
        [self.columnOffsets addObject:@(offset.vertical)];
    }
    
    // Now go ahead and figure it out.
    offset.vertical = [self.delegate recipeGridCellsOffset];
    NSInteger numItems = [self.delegate recipeGridLayoutNumItems];
    
    CGFloat maxHeight = 0.0;
    for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
        
        // Get the gridType and size.
        RecipeGridType gridType = [self.delegate recipeGridTypeForItemAtIndex:itemIndex];
        CGSize size = [RecipeGridLayout sizeForBookContentGridType:gridType];
        
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
    if ([self.delegate recipeGridLayoutLoadMoreEnabled]) {
        contentSize.height += kFooterInsets.top;
        contentSize.height += [self.delegate recipeGridLayoutFooterSize].height;
        contentSize.height += kFooterInsets.bottom;
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
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    self.insertedIndexPaths = [NSMutableArray array];
    
    if ([self.delegate recipeGridLayoutHeaderEnabled]) {
        [self buildHeaderLayout];
    }
    
    [self buildGridLayout];
    
    if ([self.delegate recipeGridLayoutLoadMoreEnabled] && ![self.delegate recipeGridLayoutDisabled]) {
        [self buildFooterLayout];
    }
    
    // Mark layout as generated.
    self.layoutCompleted = YES;
    
    // Inform end of layout prep.
    [self.delegate recipeGridLayoutDidFinish];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertedIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    [self.insertedIndexPaths removeAllObjects];
    self.insertedIndexPaths = nil;
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

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        
        // only change attributes on inserted cells
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        // Configure attributes ...
        attributes.alpha = 0.0;
        
        if ([self.delegate respondsToSelector:@selector(recipeGridInitialOffset)]) {
            attributes.transform3D = CATransform3DMakeTranslation(0.0, [self.delegate recipeGridInitialOffset], 0.0);
        }
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([self.delegate respondsToSelector:@selector(recipeGridFinalOffset)]) {
        
        // only change attributes on inserted cells
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        // Configure attributes ...
        attributes.alpha = 0.0;
        
        attributes.transform3D = CATransform3DMakeTranslation(0.0, [self.delegate recipeGridFinalOffset], 0.0);
    }
    
    return attributes;
}


#pragma mark - Private methods

- (void)buildHeaderLayout {
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *headerAttributes = [self headerLayoutAttributesForIndexPath:headerIndexPath];
    [self.supplementaryLayoutAttributes addObject:headerAttributes];
    [self.indexPathSupplementaryAttributes setObject:headerAttributes forKey:headerIndexPath];
}

- (UICollectionViewLayoutAttributes *)headerLayoutAttributesForIndexPath:(NSIndexPath *)headerIndexPath {
    CGSize headerSize = [self.delegate recipeGridLayoutHeaderSize];
    CGFloat navigationHeight = [BookNavigationView navigationHeight];
    CGFloat availableHeaderHeight = [self.delegate recipeGridCellsOffset] - navigationHeight;
    
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
    NSInteger numItems = [self.delegate recipeGridLayoutNumItems];
    
    if (numItems > 0) {
        NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:numItems inSection:0];
        UICollectionViewLayoutAttributes *footerAttributes = [self footerLayoutAttributesForIndexPath:footerIndexPath];
        [self.itemsLayoutAttributes addObject:footerAttributes];
        [self.indexPathItemAttributes setObject:footerAttributes forKey:footerIndexPath];
    }
}

- (UICollectionViewLayoutAttributes *)footerLayoutAttributesForIndexPath:(NSIndexPath *)footerIndexPath {
    CGSize footerSize = [self.delegate recipeGridLayoutFooterSize];
    
    CGFloat maxColumnHeight = [self maxHeightForColumns];
    UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:footerIndexPath];
    footerAttributes.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - footerSize.width) / 2.0),
        maxColumnHeight + kFooterInsets.top,
        footerSize.width,
        footerSize.height
    };
    return footerAttributes;
}

- (void)buildGridLayout {
    
    // Set up the column offsets.
    UIOffset offset = (UIOffset){ kContentInsets.left, [self.delegate recipeGridCellsOffset] };
    
    NSInteger numColumns = kNumColumns;
    self.columnOffsets = [NSMutableArray arrayWithCapacity:numColumns];
    for (NSInteger columnIndex = 0; columnIndex < numColumns; columnIndex++) {
        [self.columnOffsets addObject:@(offset.vertical)];
    }
    
    // Now go ahead and figure it out.
    NSInteger numItems = [self.delegate recipeGridLayoutNumItems];
    
    for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
        
        // Get the gridType and size.
        RecipeGridType gridType = [self.delegate recipeGridTypeForItemAtIndex:itemIndex];
        CGSize size = [RecipeGridLayout sizeForBookContentGridType:gridType];
        
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
    CGSize headerSize = [self.delegate recipeGridLayoutHeaderSize];
    
    if (visibleFrame.origin.y > 0.0) {
        
        CGFloat navigationHeight = [BookNavigationView navigationHeight];
        CGFloat availableHeaderHeight = [self.delegate recipeGridCellsOffset] - visibleFrame.origin.y - navigationHeight;

        CGRect frame = attributes.frame;
        frame.origin.y = visibleFrame.origin.y + navigationHeight + floorf((availableHeaderHeight - headerSize.height) / 2.0),
        frame.origin.y = MIN(frame.origin.y, [self.delegate recipeGridCellsOffset] - kHeaderCellsMinGap - headerSize.height);
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
