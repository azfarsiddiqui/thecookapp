//
//  BookNavigationLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 12/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationLayout.h"
#import "BookLeftPageDividerView.h"
#import "BookRightPageDividerView.h"

@interface BookNavigationLayout ()

@property (nonatomic, assign) id<BookNavigationDataSource> dataSource;
@property (nonatomic, assign) id<BookNavigationLayoutDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *contentPages;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableArray *decorationLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathDecorationAttributes;
@property (nonatomic, strong) NSMutableArray *pageOffsetsForSections;

@end

@implementation BookNavigationLayout

#define kPageDividerLeftKind    @"PageDividerLeftKind"
#define kPageDividerRightKind   @"PageDividerRightKind"

+ (CGSize)unitSize {
    return CGSizeMake(240.0, 596.0);
}

+ (UIEdgeInsets)contentPageInsets {
    return UIEdgeInsetsMake(80.0, 80.0, 72.0, 80.0);
}

+ (UIEdgeInsets)otherPageInsets {
    return UIEdgeInsetsMake(80.0, 30.0, 30.0, 30.0);
}

+ (CGFloat)columnSeparatorWidth {
    return 72.0;
}

- (id)initWithDataSource:(id<BookNavigationDataSource>)dataSource delegate:(id<BookNavigationLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.dataSource = dataSource;
        self.delegate = delegate;
        
        [self registerClass:[BookLeftPageDividerView class] forDecorationViewOfKind:kPageDividerLeftKind];
        [self registerClass:[BookRightPageDividerView class] forDecorationViewOfKind:kPageDividerRightKind];
    }
    return self;
}

- (CGFloat)pageOffsetForSection:(NSInteger)section {
    
    NSInteger contentStartSection = [self.dataSource bookNavigationContentStartSection];
    NSInteger contentSection = section - contentStartSection;
    
    // Items start from the content start section.
    CGFloat pageOffset = contentStartSection * self.collectionView.bounds.size.width;
    
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

- (NSInteger)numberOfPages {
    NSInteger numSections = self.collectionView.numberOfSections - [self.dataSource bookNavigationContentStartSection];
    NSInteger numPages = 0;
    for (NSInteger sectionIndex = 0; sectionIndex < numSections; sectionIndex++) {
        NSArray *sectionPages = [self.contentPages objectAtIndex:sectionIndex];
        numPages += [sectionPages count];
    }
    return numPages;
}

- (NSArray *)pageOffsetsForContentsSections {
    return self.pageOffsetsForSections;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    DLog(@"Number of sections [%d]", [self.contentPages count]);
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
    return contentSize;
}

- (void)prepareLayout {
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.decorationLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    self.indexPathDecorationAttributes = [NSMutableDictionary dictionary];
    self.pageOffsetsForSections = [NSMutableArray array];
    
    [self buildBookOtherLayoutData];
    [self buildBookRecipesLayoutData];
    
    // Inform end of layout prep.
    [self.delegate prepareLayoutDidFinish];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return NO;
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
    
    // Decoration views.
    for (UICollectionViewLayoutAttributes *attributes in self.decorationLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind
                                                                        atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathSupplementaryAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                                                  atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathDecorationAttributes objectForKey:indexPath];
}

#pragma mark - Private methods

- (void)buildBookOtherLayoutData {
    
    UIEdgeInsets pageInsets = [BookNavigationLayout otherPageInsets];
    NSInteger contentStartSection = [self.dataSource bookNavigationContentStartSection];
    for (NSInteger section = 0; section < contentStartSection; section++) {
        
        // Add layout attributes for the meta/info sections before contents start.
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        CGSize size = self.collectionView.bounds.size;
        layoutAttributes.frame = CGRectMake((section * size.width) + pageInsets.left,
                                            pageInsets.top,
                                            size.width - pageInsets.left - pageInsets.right,
                                            size.height - pageInsets.top - pageInsets.bottom);
        [self.itemsLayoutAttributes addObject:layoutAttributes];
        [self.indexPathItemAttributes setObject:layoutAttributes forKey:indexPath];
        
    }
    
}

- (void)buildBookRecipesLayoutData {
    
    // Content start section.
    NSInteger contentStartSection = [self.dataSource bookNavigationContentStartSection];
    NSInteger numContentSections = [self.collectionView numberOfSections] - contentStartSection;
    DLog(@"Number of content sections [%d]", numContentSections);
    
    // Page and items params.
    NSInteger numColumns = [self.dataSource bookNavigationLayoutNumColumns];
    CGSize unitSize = [BookNavigationLayout unitSize];
    UIEdgeInsets pageInsets = [BookNavigationLayout contentPageInsets];
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
        
        // Keep track of page offsets for sections.
        [self.pageOffsetsForSections addObject:[NSNumber numberWithFloat:pageOffsetForSection]];
        
        // Start off with one available column to make way for the category header.
        NSInteger availableColumns = 1;
        
        // Create pages array if not there already.
        NSMutableArray *pages = nil;
        if ([self.contentPages count] > contentSection) {
            
            // Existing section.
            pages = [self.contentPages objectAtIndex:contentSection];
            
        } else {
            
            // New section.
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
    
    // Create page dividers between the content pages.
    for (NSUInteger sectionIndex = 0; sectionIndex < [self.contentPages count]; sectionIndex++) {
        
        BOOL firstSection = (sectionIndex == 0);
        BOOL lastSection = (sectionIndex == [self.contentPages count] - 1);
        
        NSInteger collectionSection = contentStartSection + sectionIndex;
        CGFloat sectionPageOffset = [self pageOffsetForSection:collectionSection];
        
        NSArray *pagesInSection = [self.contentPages objectAtIndex:sectionIndex];
        
        // Loop through each page within the section.
        for (NSInteger pageIndex = 0; pageIndex < [pagesInSection count]; pageIndex++) {
            
            CGFloat pageOffset = sectionPageOffset + (pageIndex * self.collectionView.bounds.size.width) * self.collectionView.bounds.size.width;
            NSArray *pageIndexPaths = [pagesInSection objectAtIndex:pageIndex];
            NSIndexPath *anyIndexPath = [pageIndexPaths lastObject];
            
            // Left page divider if not the first page.
            if (!(firstSection && pageIndex == 0)) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:anyIndexPath.section];
                UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kPageDividerLeftKind
                                                                                                                                 withIndexPath:indexPath];
                layoutAttributes.frame = CGRectMake(pageOffset, 0.0, 1.0, self.collectionView.bounds.size.height);
                [self.decorationLayoutAttributes addObject:layoutAttributes];
                [self.indexPathDecorationAttributes setObject:layoutAttributes forKey:indexPath];
            }
            
            // Right page divider if not the last page.
            if (!(lastSection && pageIndex == [pagesInSection count] - 1)) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:anyIndexPath.section];
                UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kPageDividerRightKind
                                                                                                                                 withIndexPath:indexPath];
                layoutAttributes.frame = CGRectMake(pageOffset + self.collectionView.bounds.size.width, 0.0, 1.0, self.collectionView.bounds.size.height);
                [self.decorationLayoutAttributes addObject:layoutAttributes];
                [self.indexPathDecorationAttributes setObject:layoutAttributes forKey:indexPath];
            }
            
        }
        
    }
    
}

- (CGFloat)firstItemOffsetForSection {
    return [BookNavigationLayout contentPageInsets].left + (2 * [BookNavigationLayout unitSize].width) + (2 * [BookNavigationLayout columnSeparatorWidth]);
}

@end
