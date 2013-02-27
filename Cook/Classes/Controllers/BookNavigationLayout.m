//
//  BookNavigationLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationLayout.h"

@interface BookNavigationLayout ()

@property (nonatomic, assign) id<BookNavigationDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *contentPages;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;

@end

@implementation BookNavigationLayout

+ (CGSize)unitSize {
    return CGSizeMake(240.0, 596.0);
}

+ (UIEdgeInsets)pageInsets {
    return UIEdgeInsetsMake(80.0, 80.0, 72.0, 80.0);
}

+ (CGFloat)columnSeparatorWidth {
    return 72.0;
}

- (id)initWithDataSource:(id<BookNavigationDataSource>)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
    }
    return self;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    CGFloat width = 0;
    NSInteger contentStartSection = [self.dataSource bookNavigationContentStartSection];
    
    // Info pages: Profile, Home.
    width = contentStartSection * self.collectionView.bounds.size.width;
    
    // Category pages.
    for (NSArray *pages in self.contentPages) {
        
        // Section width is the number of pages multiple of the width.
        width += [pages count] * self.collectionView.bounds.size.width;
        
    }
    
    CGSize contentSize = CGSizeMake(width, self.collectionView.bounds.size.height);
    DLog(@"contentSize: %@", NSStringFromCGSize(contentSize));
    return contentSize;
}

- (void)prepareLayout {
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    
    [self buildInfoLayoutData];
    [self buildContentsLayoutData];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return NO;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
//    // Home view.
//    for (UICollectionViewLayoutAttributes *attributes in self.decorationLayoutAttributes) {
//        if (CGRectIntersectsRect(rect, attributes.frame)) {
//            [layoutAttributes addObject:attributes];
//        }
//    }
    
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
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.indexPathItemAttributes objectForKey:indexPath];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.indexPathSupplementaryAttributes objectForKey:indexPath];
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    return [super layoutAttributesForDecorationViewOfKind:decorationViewKind atIndexPath:indexPath];
}

#pragma mark - Private methods

- (void)buildInfoLayoutData {
    
    NSInteger contentStartSection = [self.dataSource bookNavigationContentStartSection];
    for (NSInteger section = 0; section < contentStartSection; section++) {
        
        // Add layout attributes for the meta/info sections before contents start.
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        CGSize size = self.collectionView.bounds.size;
        layoutAttributes.frame = CGRectMake(section * size.width, 0.0, size.width, size.height);
        [self.itemsLayoutAttributes addObject:layoutAttributes];
        [self.indexPathItemAttributes setObject:layoutAttributes forKey:indexPath];
        
    }
    
}

- (void)buildContentsLayoutData {
    
    // Content start section.
    NSInteger contentStartSection = [self.dataSource bookNavigationContentStartSection];
    NSInteger numContentSections = [self.collectionView numberOfSections] - contentStartSection;
    DLog(@"Number of content sections [%d]", numContentSections);
    
    // Page and items params.
    NSInteger numColumns = [self.dataSource bookNavigationLayoutNumColumns];
    CGSize unitSize = [BookNavigationLayout unitSize];
    UIEdgeInsets pageInsets = [BookNavigationLayout pageInsets];
    CGFloat columnSeparatorWidth = [BookNavigationLayout columnSeparatorWidth];
    CGFloat firstItemOffset = [self firstItemOffsetForSection];
    
    // Initialise the data structures to store all preloaded pages and attributes.
    self.contentPages = [NSMutableArray arrayWithCapacity:numContentSections];
    
    // Loop through each section and assemble the pages for each.
    for (NSInteger contentSection = 0; contentSection < numContentSections; contentSection++) {
        
        // Real book section.
        NSInteger section = contentSection + contentStartSection;
        
        CGFloat pageOffsetForSection = [self pageOffsetForSection:section];
        
        // Current xOffset of items.
        CGFloat xOffsetForItems = pageOffsetForSection + firstItemOffset;
        
        // First create the content header.
        NSInteger headerColumns = 2;
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:sectionIndexPath];
        headerAttributes.frame = CGRectMake(pageOffsetForSection + pageInsets.left,
                                            pageInsets.top,
                                            (headerColumns * unitSize.width) + ((headerColumns - 1) * columnSeparatorWidth),
                                            unitSize.height);
        [self.supplementaryLayoutAttributes addObject:headerAttributes];
        [self.indexPathSupplementaryAttributes setObject:headerAttributes forKey:sectionIndexPath];
        
        // Start off with one available column to make way for the category header.
        NSInteger availableColumns = 1;
        
        // Create pages array if not there already.
        NSMutableArray *pages = nil;
        if ([self.contentPages count] > contentSection) {
            pages = [self.contentPages objectAtIndex:contentSection];
        } else {
            pages = [NSMutableArray array];
            [self.contentPages addObject:pages];
        }
        
        // Loop through each item in the section and attempt to add them to the page.
        NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        DLog(@"Number of items in section [%d]: %d", section, numItems);
        for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
            
            // Get the current page items array.
            NSMutableArray *currentPageItems = [pages lastObject];
            if (currentPageItems == nil) {
                currentPageItems = [NSMutableArray array];
                [pages addObject:currentPageItems];
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:section];
            
            // Get the required column width for the current item.
            NSUInteger columnWidth = [self.dataSource bookNavigationLayoutColumnWidthForItemAtIndexPath:indexPath];
            
            // If we can't fit the current column, create a new page items array.
            if (columnWidth > availableColumns) {
                
                // Start with a new page items.
                currentPageItems = [NSMutableArray array];
                
                // Add it to the pages array.
                [pages addObject:currentPageItems];
                
                // Reset the number of columns.
                availableColumns = numColumns;
                
                // Increment xOffset to jump page division.
                xOffsetForItems += pageInsets.right + pageInsets.left;
                
            }
            
            // Now try fitting it in.
            if (columnWidth <= availableColumns) {
                
                // Increment xOffset if we have available columns.
                if (itemIndex > 0 && availableColumns < numColumns) {
                    xOffsetForItems += columnSeparatorWidth;
                }
                
                // Add item indexPath to the currentPage items.
                [currentPageItems addObject:indexPath];
                
                // Add layout attributes for the given indexPath.
                UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttributes.frame = CGRectMake(xOffsetForItems,
                                                    pageInsets.top,
                                                    unitSize.width * columnWidth + (columnSeparatorWidth * (columnWidth - 1)),
                                                    unitSize.height);
                [self.itemsLayoutAttributes addObject:layoutAttributes];
                [self.indexPathItemAttributes setObject:layoutAttributes forKey:indexPath];
                
                // Increment xOffset.
                xOffsetForItems += layoutAttributes.frame.size.width;
                
                // Decrement the number of available columns.
                availableColumns -= columnWidth;
                
            } else {
                
                // Skip this item and move on to the next item.
                continue;
                
            }
        }
    }
}

- (CGFloat)pageOffsetForSection:(NSInteger)section {
    
    NSInteger contentStartSection = [self.dataSource bookNavigationContentStartSection];
    NSInteger contentSection = section - contentStartSection;
    
    // Items start from the content start section.
    CGFloat pageOffset = [self.dataSource bookNavigationContentStartSection] * self.collectionView.bounds.size.width;
    
    if (contentSection > 0) {
        
        // Loop through the past pages
        for (NSInteger sectionIndex = 0; sectionIndex < contentSection; sectionIndex++) {
            
            // Section width is the number of pages multiple of the width.
            NSArray *sectionPages = [self.contentPages objectAtIndex:sectionIndex];
            pageOffset += [sectionPages count] * self.collectionView.bounds.size.width;
            
        }
        
    }
    return pageOffset;
}

- (CGFloat)firstItemOffsetForSection {
    return [BookNavigationLayout pageInsets].left + (2 * [BookNavigationLayout unitSize].width) + (2 * [BookNavigationLayout columnSeparatorWidth]);
}

@end
