//
//  BenchtopPartingFlowLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 16/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopPartingFlowLayout.h"

@implementation BenchtopPartingFlowLayout

#pragma mark - CKBenchtopLayout methods

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    for (UICollectionViewLayoutAttributes* attributes in layoutAttributes) {
        
        if (attributes.indexPath.section == 1) {
            
            CGSize itemSize = [self.benchtopDelegate benchtopItemSize];
            CGFloat sideGap = [self.benchtopDelegate benchtopSideGap];
            CGFloat offset = itemSize.width + [self.benchtopDelegate benchtopSideGap];
            NSIndexPath *indexPath = attributes.indexPath;
            NSIndexPath *selectedIndexPath = [self.benchtopDelegate benchtopOpenedIndexPath];
            
            // Only part those books immediately before/after the selected one.
            NSInteger distance = indexPath.row - selectedIndexPath.row;
            if (ABS(distance) == 1) {
                attributes.transform3D = CATransform3DTranslate(attributes.transform3D, offset * distance, 0.0, 0.0);
            }
            
        }
    }
    
    return layoutAttributes;
}

#pragma mark - Private

@end
