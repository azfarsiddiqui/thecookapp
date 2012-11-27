//
//  CKBenchtopLayout.m
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopLayout.h"

@interface BenchtopLayout ()

@end

@implementation BenchtopLayout

#define kLibraryHeader  @"LibraryHeader"

- (id)initWithBenchtopDelegate:(id<BenchtopDelegate>)benchtopDelegate {
    if ([super init]) {
        self.benchtopDelegate = benchtopDelegate;
    }
    return self;
}

#pragma mark - UICollectionViewLayout methods

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
    
    
    UICollectionViewLayoutAttributes *firstOtherAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    layoutAttributes.size = itemSize;
    layoutAttributes.alpha = [self.benchtopDelegate onMyBenchtop] ? 0.0 : 1.0;
    layoutAttributes.center = CGPointMake(firstOtherAttributes.center.x - itemSize.width, firstOtherAttributes.center.y);
    return layoutAttributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    NSInteger numSections = [self.collectionView numberOfSections];
    
    // TODO potential optimisation here to include only first few books instead of all.
    for (NSInteger section = 0; section < numSections; section++) {
        NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:
                                                            [NSIndexPath indexPathForItem:itemIndex inSection:section]];
            [layoutAttributes addObject:attributes];
        }
    }
    
    // Library header.
    if (![self.benchtopDelegate benchtopStoreMode] && numSections > 1) {
    
        // TODO potential optimisation here to exclude header if not in view.
        [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:kLibraryHeader
                                                                         atIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]]];
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes
                                                    layoutAttributesForCellWithIndexPath:indexPath];
    CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
    CGFloat sideGap = [self.benchtopDelegate benchtopSideGap];
    CGFloat itemOffset = [self.benchtopDelegate benchtopItemOffset];
    attributes.size = itemSize;
    
    if (indexPath.section == 0) {
        
        // |62| + 300 + 150
        attributes.center = CGPointMake(sideGap + itemSize.width + (itemSize.width / 2.0) + itemOffset, self.collectionView.center.y);
        
    } else {
        
        // Starts at |62| + 300 + 300 + 300 + (300n + 150)
        CGFloat offset = sideGap + itemSize.width * 3.0 + (itemSize.width * indexPath.row + (itemSize.width / 2.0)) + itemOffset;
        attributes.center = CGPointMake(offset, self.collectionView.center.y);
        
    }
    
    return attributes;
}

// Insertion start point.
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    if (![self.benchtopDelegate benchtopMyBookLoaded] && itemIndexPath.section == 0) {
        
        // Fade and scale in my book.
        CGFloat scaleFactor = [self.benchtopDelegate benchtopBookMinScaleFactor];
        initialAttributes.alpha = 0.0;
        initialAttributes.transform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 0.0);
        
    } else if (itemIndexPath.section == 1) {
        
        // Insert friends book from right.
        initialAttributes.transform3D = CATransform3DMakeTranslation([self.benchtopDelegate benchtopSideGap], 0.0, 0.0);
    }
    
    return initialAttributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *finalAttributes = nil;
    
//    if (itemIndexPath.section == 1) {
//        finalAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        CGFloat distance = self.collectionView.bounds.size.width * (itemIndexPath.item + 1);
//        finalAttributes.alpha = 0.0;
//        finalAttributes.transform3D = CATransform3DMakeTranslation(distance, 0.0, 0.0);
//    }
    
    return finalAttributes;
}


@end
