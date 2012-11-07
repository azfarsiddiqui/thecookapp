//
//  IllustrationFlowLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "IllustrationFlowLayout.h"

@implementation IllustrationFlowLayout

// Insertion start point.
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    CGSize itemSize = self.itemSize;
    initialAttributes.center = CGPointMake(initialAttributes.center.x,
                                           initialAttributes.center.y + ((itemIndexPath.row + 1) * itemSize.height * 2));
    
    return initialAttributes;
}

// Deletion end point.
//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//    CGSize itemSize = self.itemSize;
//    
//    initialAttributes.center = CGPointMake(initialAttributes.center.x,
//                                           initialAttributes.center.y + ((itemIndexPath.row + 1) * itemSize.height));
//    
//    return initialAttributes;
//}

@end
