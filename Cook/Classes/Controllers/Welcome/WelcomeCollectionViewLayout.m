//
//  WelcomeCollectionViewLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 28/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "WelcomeCollectionViewLayout.h"

@interface WelcomeCollectionViewLayout ()

@property (nonatomic, assign) id<WelcomeCollectionViewLayoutDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;

@end

@implementation WelcomeCollectionViewLayout

#define kSectionSize        CGSizeMake(500.0, 500.0)
#define kAdornmentOffset    128.0
#define kWelcomeSection     0
#define kCreateSection      1
#define kCollectSection     2
#define kSignUpSection      3

- (id)initWithDataSource:(id<WelcomeCollectionViewLayoutDataSource>)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
    }
    return self;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    NSInteger numPages = [self.dataSource numberOfPagesForWelcomeLayout];
    return CGSizeMake(self.collectionView.bounds.size.width * numPages,
                      self.collectionView.bounds.size.height);
}

- (void)prepareLayout {
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    
    [self buildPages];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Section cells.
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
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind
                                                                        atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathSupplementaryAttributes objectForKey:indexPath];
}

#pragma mark - Private methods

- (void)buildPages {
    NSInteger numPages = [self.dataSource numberOfPagesForWelcomeLayout];
    
    for (NSInteger page = 0; page < numPages; page++) {
        
        // Section
        [self buildSectionLabelForPage:page];

        // Cells
        [self buildAdornmentsForPage:page];
    }
    
}

- (void)buildSectionLabelForPage:(NSInteger)page {
    CGSize size = self.collectionView.bounds.size;
    CGFloat pageOffset = [self pageOffsetForPage:page];
    
    NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:page];
    UICollectionViewLayoutAttributes *sectionAttributes = [UICollectionViewLayoutAttributes
                                                           layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                           withIndexPath:sectionIndexPath];
    sectionAttributes.frame = CGRectMake(pageOffset + floorf((size.width - kSectionSize.width) / 2.0),
                                         floorf((size.height - kSectionSize.height) / 2.0),
                                         kSectionSize.width,
                                         kSectionSize.height);
    [self.supplementaryLayoutAttributes addObject:sectionAttributes];
    [self.indexPathSupplementaryAttributes setObject:sectionAttributes forKey:sectionIndexPath];
}

- (void)buildAdornmentsForPage:(NSInteger)page {
    switch (page) {
        case kWelcomeSection:
            [self buildWelcomeAdornments];
            break;
        case kCreateSection:
            [self buildCreateAdornments];
            break;
        case kCollectSection:
            [self buildCollectAdornments];
            break;
        case kSignUpSection:
            [self buildSignUpAdornments];
            break;
        default:
            break;
    }
}

- (void)buildWelcomeAdornments {
    CGFloat pageOffset = [self pageOffsetForPage:kWelcomeSection];
    CGSize size = self.collectionView.bounds.size;
    
    // Left adornment.
    NSIndexPath *leftIndexPath = [NSIndexPath indexPathForItem:0 inSection:kWelcomeSection];
    CGSize leftSize = [self.dataSource sizeOfAdornmentForIndexPath:leftIndexPath];
    UICollectionViewLayoutAttributes *leftLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:leftIndexPath];
    leftLayoutAttributes.frame = CGRectMake(pageOffset - kAdornmentOffset,
                                            floorf((size.height - leftSize.height) / 2.0),
                                            leftSize.width,
                                            leftSize.height);
    [self.itemsLayoutAttributes addObject:leftLayoutAttributes];
    [self.indexPathItemAttributes setObject:leftLayoutAttributes forKey:leftIndexPath];
    
    // Right adornment.
    NSIndexPath *rightIndexPath = [NSIndexPath indexPathForItem:1 inSection:kWelcomeSection];
    CGSize rightSize = [self.dataSource sizeOfAdornmentForIndexPath:rightIndexPath];
    UICollectionViewLayoutAttributes *rightLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:rightIndexPath];
    rightLayoutAttributes.frame = CGRectMake(pageOffset + size.width - rightSize.width + kAdornmentOffset,
                                             floorf((size.height - rightSize.height) / 2.0),
                                             rightSize.width,
                                             rightSize.height);
    [self.itemsLayoutAttributes addObject:rightLayoutAttributes];
    [self.indexPathItemAttributes setObject:rightLayoutAttributes forKey:rightIndexPath];
}

- (void)buildCreateAdornments {
    
    CGFloat pageOffset = [self pageOffsetForPage:kCreateSection];
    CGSize size = self.collectionView.bounds.size;
    
    // Right adornment.
    NSIndexPath *rightIndexPath = [NSIndexPath indexPathForItem:0 inSection:kCreateSection];
    CGSize rightSize = [self.dataSource sizeOfAdornmentForIndexPath:rightIndexPath];
    UICollectionViewLayoutAttributes *rightLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:rightIndexPath];
    rightLayoutAttributes.frame = CGRectMake(pageOffset + size.width - rightSize.width - kAdornmentOffset,
                                             floorf((size.height - rightSize.height) / 2.0),
                                             rightSize.width,
                                             rightSize.height);
    [self.itemsLayoutAttributes addObject:rightLayoutAttributes];
    [self.indexPathItemAttributes setObject:rightLayoutAttributes forKey:rightIndexPath];
    
}

- (void)buildCollectAdornments {
    CGFloat pageOffset = [self pageOffsetForPage:kCollectSection];
    CGSize size = self.collectionView.bounds.size;
    
    // Left adornment.
    NSIndexPath *leftIndexPath = [NSIndexPath indexPathForItem:0 inSection:kCollectSection];
    CGSize leftSize = [self.dataSource sizeOfAdornmentForIndexPath:leftIndexPath];
    UICollectionViewLayoutAttributes *leftLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:leftIndexPath];
    leftLayoutAttributes.frame = CGRectMake(pageOffset - kAdornmentOffset,
                                            floorf((size.height - leftSize.height) / 2.0),
                                            leftSize.width,
                                            leftSize.height);
    [self.itemsLayoutAttributes addObject:leftLayoutAttributes];
    [self.indexPathItemAttributes setObject:leftLayoutAttributes forKey:leftIndexPath];
    
    // Right adornment.
    NSIndexPath *rightIndexPath = [NSIndexPath indexPathForItem:1 inSection:kCollectSection];
    CGSize rightSize = [self.dataSource sizeOfAdornmentForIndexPath:rightIndexPath];
    UICollectionViewLayoutAttributes *rightLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:rightIndexPath];
    rightLayoutAttributes.frame = CGRectMake(pageOffset + size.width - rightSize.width + kAdornmentOffset,
                                             floorf((size.height - rightSize.height) / 2.0),
                                             rightSize.width,
                                             rightSize.height);
    [self.itemsLayoutAttributes addObject:rightLayoutAttributes];
    [self.indexPathItemAttributes setObject:rightLayoutAttributes forKey:rightIndexPath];
}

- (void)buildSignUpAdornments {
    // No adornments.
}

- (CGFloat)pageOffsetForPage:(NSInteger)page {
    CGSize size = self.collectionView.bounds.size;
    return size.width * page;
}

@end
