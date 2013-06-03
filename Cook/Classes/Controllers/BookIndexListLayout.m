//
//  BookIndexListLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 3/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookIndexListLayout.h"
#import "BookIndexCell.h"

@interface BookIndexListLayout ()

@property (nonatomic, assign) id<BookIndexListLayoutDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;

@end

@implementation BookIndexListLayout

#define kContentInsets      UIEdgeInsetsMake(70.0, 100.0, 70.0, 100.0)
#define kMaxYOffset         180.0
#define kRowGap             15.0

- (id)initWithDataSource:(id<BookIndexListLayoutDataSource>)dataSource {
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

#pragma mark - Private methods

- (void)buildIndexLayoutData {
    NSArray *categories = [self.dataSource bookIndexListLayoutCategories];
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    
    UIEdgeInsets contentInsets = [self contentInsets];
    CGFloat yOffset = contentInsets.top;
    CGSize size = [BookIndexCell cellSize];
    
    for (NSInteger categoryIndex = 0; categoryIndex < [categories count]; categoryIndex++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:categoryIndex inSection:0];
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        layoutAttributes.frame = (CGRect) {
            contentInsets.left,
            yOffset,
            self.collectionView.bounds.size.width - contentInsets.left - contentInsets.right,
            size.height
        };
        yOffset += size.height;
        if (categoryIndex < [categories count] - 1) {
            yOffset += kRowGap;
        }
        [self.itemsLayoutAttributes addObject:layoutAttributes];
        [self.indexPathItemAttributes setObject:layoutAttributes forKey:indexPath];
    }
    
}

- (UIEdgeInsets)contentInsets {
    UIEdgeInsets insets = kContentInsets;
    CGFloat requiredHeight = [self requiredHeight];
    CGRect bounds = self.collectionView.bounds;
    CGFloat yOffset = floorf((bounds.size.height - requiredHeight) / 2.0);
    if (yOffset > kMaxYOffset) {
        insets.top = kMaxYOffset;
    } else if (yOffset > insets.top) {
        insets.top = yOffset;
    }
    return insets;
}

- (CGFloat)requiredHeight {
    CGFloat height = 0.0;
    
    NSArray *categories = [self.dataSource bookIndexListLayoutCategories];
    height += [categories count] * [BookIndexCell cellSize].height;
    height += ([categories count] - 1) * kRowGap;
    
    return height;
}

@end
