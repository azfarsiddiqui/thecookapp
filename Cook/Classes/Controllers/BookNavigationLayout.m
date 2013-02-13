//
//  BookNavigationLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationLayout.h"

@interface BookNavigationLayout ()

@property (nonatomic, assign) id<BookNavigationLayoutDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *sectionPages;
@property (nonatomic, strong) NSMutableArray *allLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathAttributes;

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

- (id)initWithDataSource:(id<BookNavigationLayoutDataSource>)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
    }
    return self;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    CGFloat width = 0;
    for (NSArray *pages in self.sectionPages) {
        
        // Section width is the number of pages multiple of the width.
        width += [pages count] * self.collectionView.bounds.size.width;
        
    }
    return CGSizeMake(width, self.collectionView.bounds.size.height);
}

- (void)prepareLayout {
    NSInteger numSections = [self.collectionView numberOfSections];
    DLog(@"Number of sections [%d]", numSections);
    
    // Page and items params.
    NSInteger numColumns = [self.dataSource bookNavigationLayoutNumColumns];
    CGSize unitSize = [BookNavigationLayout unitSize];
    UIEdgeInsets pageInsets = [BookNavigationLayout pageInsets];
    CGFloat columnSeparatorWidth = [BookNavigationLayout columnSeparatorWidth];
    CGFloat firstItemOffset = [self firstItemOffsetForSection];
    
    // Initialise the data structures to store all preloaded pages and attributes.
    self.sectionPages = [NSMutableArray arrayWithCapacity:numSections];
    self.allLayoutAttributes = [NSMutableArray array];
    self.indexPathAttributes = [NSMutableDictionary dictionary];
    
    // Current xOffset of items.
    CGFloat xOffset = firstItemOffset;
    
    // Loop through each section and assemble the pages for each.
    for (NSInteger section = 0; section < numSections; section++) {
        
        // Start off with one available column to make way for the category header.
        NSInteger availableColumns = 1;
        
        // A non-zero section always start off at page boundaries.
        if (section > 0) {
            xOffset = [self pageOffsetForSection:section] + firstItemOffset;
            DLog(@"Page break for section [%d] at [%f]", section, xOffset);
        }
        
        // Create pages array if not there already.
        NSMutableArray *pages = nil;
        if ([self.sectionPages count] > section) {
            pages = [self.sectionPages objectAtIndex:section];
        } else {
            pages = [NSMutableArray array];
            [self.sectionPages addObject:pages];
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
                xOffset += pageInsets.right + pageInsets.left;
                
            }
            
            // Now try fitting it in.
            if (columnWidth <= availableColumns) {
                
                // Increment xOffset if we have available columns.
                if (itemIndex > 0 && availableColumns < numColumns) {
                    xOffset += columnSeparatorWidth;
                }
                
                // Add item indexPath to the currentPage items.
                [currentPageItems addObject:indexPath];
                
                // Add layout attributes for the given indexPath.
                UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttributes.frame = CGRectMake(xOffset,
                                                    pageInsets.top,
                                                    unitSize.width * columnWidth + (columnSeparatorWidth * (columnWidth - 1)),
                                                    unitSize.height);
                [self.allLayoutAttributes addObject:layoutAttributes];
                [self.indexPathAttributes setObject:layoutAttributes forKey:indexPath];
                
                // Increment xOffset.
                xOffset += layoutAttributes.frame.size.width;
                
                // Decrement the number of available columns.
                availableColumns -= columnWidth;
                
            } else {
                
                // Skip this item and move on to the next item.
                continue;
                
            }
        }
    }
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return NO;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    for (UICollectionViewLayoutAttributes *attributes in self.allLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [self.indexPathAttributes objectForKey:indexPath];
    return attributes;
}

- (CGFloat)pageOffsetForSection:(NSInteger)section {
    CGFloat pageOffset = 0.0;
    if (section > 0) {
        
        // Loop through the past pages
        for (NSInteger sectionIndex = 0; sectionIndex < section; sectionIndex++) {
            
            // Section width is the number of pages multiple of the width.
            NSArray *sectionPages = [self.sectionPages objectAtIndex:sectionIndex];
            pageOffset += [sectionPages count] * self.collectionView.bounds.size.width;
            
        }
        
    }
    return pageOffset;
}

- (CGFloat)firstItemOffsetForSection {
    return [BookNavigationLayout pageInsets].left + (2 * [BookNavigationLayout unitSize].width) + (2 * [BookNavigationLayout columnSeparatorWidth]);
}

@end
