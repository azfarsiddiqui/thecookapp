//
//  SearchRecipeGridLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 31/03/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "SearchRecipeGridLayout.h"
#import "ViewHelper.h"

@interface SearchRecipeGridLayout ()

@end

@implementation SearchRecipeGridLayout

#define kDividerMinAlpha            0.2
#define kDividerMaxAlpha            0.5

#pragma mark - UICollectionViewLayout methods

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Header/footer cells.
    for (UICollectionViewLayoutAttributes *attributes in self.supplementaryLayoutAttributes) {
        [layoutAttributes addObject:attributes];
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


#pragma mark - RecipeGridLayout methods

- (UICollectionViewLayoutAttributes *)headerLayoutAttributesForIndexPath:(NSIndexPath *)headerIndexPath {
    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
    headerAttributes.frame = (CGRect){
        self.collectionView.bounds.origin.x,
        self.collectionView.bounds.origin.y,
        self.collectionView.bounds.size.width,
        1.0
    };
    headerAttributes.zIndex = 1000;
    return headerAttributes;
}

- (void)applyHeaderPagingEffects:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGFloat cellOffset = [self.delegate recipeGridCellsOffset];
    
    // Sticky header.
    CGRect frame = attributes.frame;
    frame.origin.y = visibleFrame.origin.y;
    attributes.frame = frame;
    
    // Alpha
    if (visibleFrame.origin.y > 0.0) {
        attributes.alpha = MIN((visibleFrame.origin.y / cellOffset), kDividerMaxAlpha);
    } else {
        attributes.alpha = 0.0;
    }
}

@end
