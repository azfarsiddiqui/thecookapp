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

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertedIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
    }
}

//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
//    UICollectionViewLayoutAttributes *initialAttributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//    
//    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
//        
//        if (initialAttributes == nil) {
//            initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
//        }
//        
//        // Normal cells slide up.
//        if (!initialAttributes.representedElementKind) {
//            CATransform3D translateTransform = CATransform3DMakeTranslation(0.0, 50.0, 0.0);
//            initialAttributes.transform3D = translateTransform;
//        }
//        
//        // Always opaque.
//        initialAttributes.alpha = 1.0;
//    }
//    
//    return initialAttributes;
//}


@end
