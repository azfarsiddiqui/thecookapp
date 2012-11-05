//
//  BenchtopEditLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopEditLayout.h"

@implementation BenchtopEditLayout

- (CGSize)collectionViewContentSize {
    return self.collectionView.bounds.size;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        // Move my book up.
        attributes.center = CGPointMake(attributes.center.x, attributes.center.y - 50.0);
        
    } else if (indexPath.section == 1) {
        
        // Move the other books to the right.
        CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
        attributes.center = CGPointMake(attributes.center.x + itemSize.width, attributes.center.y);
    }
    
    return attributes;
}

@end
