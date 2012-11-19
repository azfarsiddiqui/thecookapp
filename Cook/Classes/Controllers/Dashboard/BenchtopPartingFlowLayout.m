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
            
            NSIndexPath *selectedIndexPath = [self.benchtopDelegate benchtopOpenedIndexPath];
            
            // Move it apart if book selected.
            NSInteger distance = attributes.indexPath.row - selectedIndexPath.row;
            if (distance != 0) {
                CGFloat sign = distance / ABS(distance);
                if (ABS(distance) == 1) {
                    // CGFloat offset = 421.0; // Offscreen
                    CGFloat offset = 400.0;
                    attributes.transform3D = CATransform3DTranslate(attributes.transform3D, offset * sign, 0.0, 0.0);
                } else if (ABS(distance) == 2) {
                    // CGFloat offset = 37.0; // Offscreen
                    CGFloat offset = 27.0;
                    attributes.transform3D = CATransform3DTranslate(attributes.transform3D, offset * sign, 0.0, 0.0);
                }
                
                // Make sure they are tucked under.
                if (distance > 0) {
                    attributes.zIndex = distance;
                } else {
                    attributes.zIndex = -distance;
                }
            }
            
        }
    }
    
    return layoutAttributes;
}

#pragma mark - Private

@end
