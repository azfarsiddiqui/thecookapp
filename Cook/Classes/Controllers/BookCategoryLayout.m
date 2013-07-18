//
//  BookCategoryLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryLayout.h"
#import "ViewHelper.h"

@implementation BookCategoryLayout

#define kHeaderTotalDistanceFade    300.0

+ (CGSize)unitSize {
    return CGSizeMake(320.0, 642.0);
}

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        // Fade the header.
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
            CGRect headerFrame = attributes.frame;
            CGFloat distance = visibleFrame.origin.y - headerFrame.origin.y;
            CGFloat alpha = 1.0;
            if (distance <= kHeaderTotalDistanceFade) {
                CGFloat alphaRatio = distance / kHeaderTotalDistanceFade;
                alpha = 1.0 - alphaRatio;
            } else if (distance > kHeaderTotalDistanceFade) {
                alpha = 0.0;
            }
            
            attributes.alpha = MIN(alpha, 0.9);
            
            if (visibleFrame.origin.y < 0.0) {
                
                headerFrame.origin.y = visibleFrame.origin.y * 0.7;
                
            } else {
                
                // For some reason, only after setting frame will it fade??
                headerFrame.origin.y = visibleFrame.origin.y * 0.1;
            }
            
            attributes.frame = headerFrame;
        }
        
    }
    
    return layoutAttributes;
}

@end
