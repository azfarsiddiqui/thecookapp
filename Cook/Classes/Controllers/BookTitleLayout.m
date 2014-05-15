//
//  BookTitleLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookTitleLayout.h"

@interface BookTitleLayout ()

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;

@end

@implementation BookTitleLayout

#define kHeaderHeight           475.0
#define kCellOffset             539.0   // 475 headerHeight + 64 gap
#define kHeaderCellMinGap       30.0
#define kStartHeaderMaxOffset   50.0

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    
    [self applyPagingEffects:layoutAttributes];
    
    return layoutAttributes;
}

#pragma mark - Private methods

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        [self applyHeaderEffects:attributes];
    }
}

- (void)applyHeaderEffects:(UICollectionViewLayoutAttributes *)attributes {
    
    CGPoint currentOffset = self.collectionView.contentOffset;
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    if (numItems > 0 && [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        if (currentOffset.y > 0) {
            CGRect frame = attributes.frame;
            CGFloat headerHeight = kHeaderHeight + currentOffset.y;
            headerHeight = MIN(headerHeight, kCellOffset - kHeaderCellMinGap);
            frame.size.height = headerHeight;
            attributes.frame = frame;
        }
    }
}

@end
