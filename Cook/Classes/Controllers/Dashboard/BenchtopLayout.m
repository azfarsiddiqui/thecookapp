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

- (id)initWithBenchtopDelegate:(id<BenchtopDelegate>)benchtopDelegate {
    if ([super init]) {
        self.benchtopDelegate = benchtopDelegate;
    }
    return self;
}

// Subclasses to implement what to do after layout has completed after animation.
- (void)layoutCompleted {
}

#pragma mark - UICollectionViewLayout methods

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

@end
