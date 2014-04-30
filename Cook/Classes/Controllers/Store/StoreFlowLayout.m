//
//  StoreFlowLayout.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreFlowLayout.h"
#import "MRCEnumerable.h"
#import "CKCollectionViewSpringsHelper.h"

@interface StoreFlowLayout ()

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@property (nonatomic, assign) BOOL springEnabled;
@property (nonatomic, strong) CKCollectionViewSpringsHelper *springsHelper;

@end

@implementation StoreFlowLayout

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        // Enable Spring?
        self.springEnabled = NO;
        
        if (self.springEnabled) {
            self.springsHelper = [[CKCollectionViewSpringsHelper alloc] initWithCollectionViewLayout:self];
        }
        
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    // Reset all behaviours.
    if (self.springEnabled) {
        [self.springsHelper reset];

        CGSize contentSize = self.collectionView.contentSize;
        NSArray *items = [super layoutAttributesForElementsInRect:
                          CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height)];
        
//        CGRect originalFrame = (CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size};
//        CGRect visibleFrame = CGRectInset(originalFrame, -100, -100);   // To take into account fast scrolling on either side.
//        
//        NSArray *items = [self layoutAttributesForElementsInRect:visibleFrame];
        
//        DLog(@"*** TOTAL ITEMS[%ld]", (long unsigned)[items count]);
        
        [items enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger objectIndex, BOOL *stop) {
//            DLog(@"*** ITEMS[%ld]: %@", (long unsigned)objectIndex, attributes);
            [self.springsHelper applyAttachmentBehaviourToAttributes:attributes];
        }];
        
    }
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (self.springEnabled) {
        return [self.springsHelper shouldInvalidateAfterApplyingOffsetsForNewBounds:newBounds collectionView:self.collectionView];
    } else {
        return YES;
    }
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.insertedIndexPaths = [NSMutableArray array];
    self.deletedIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
        else if (updateItem.updateAction == UICollectionUpdateActionDelete) {
            [self.deletedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
        }
    }
    
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == 0) {
            if (initialAttributes == nil) {
                initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
            }
            
            // Start on the edge of the screen.
            CGFloat translateOffset = self.collectionView.bounds.size.width - 60.0;
            
            // Make books further apart so that they slide in at different distances.
            translateOffset += itemIndexPath.item * (initialAttributes.frame.size.width * 3.0);
            
            CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, translateOffset, 0.0, 0.0);
            initialAttributes.transform3D = translateTransform;
            initialAttributes.alpha = 1.0;
        }
        
    }

    return initialAttributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *finalAttributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    if ([self.deletedIndexPaths containsObject:itemIndexPath]) {
        finalAttributes.alpha = 0.0;
        finalAttributes.transform3D = CATransform3DScale(finalAttributes.transform3D, 0.1, 0.1, 0.0);
    }
    return finalAttributes;
}

- (void)finalizeCollectionViewUpdates {
    DLog();
    [self.insertedIndexPaths removeAllObjects];
    [self.deletedIndexPaths removeAllObjects];
    self.insertedIndexPaths = nil;
    self.deletedIndexPaths = nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributes = nil;
    if (self.springEnabled) {
        layoutAttributes = [self.springsHelper layoutAttributesInFrame:rect];
    } else {
        layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    }
//    DLog(@"********************************************************* %@", layoutAttributes);
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    DLog(@"********************************************************* %@", indexPath);
    if (self.springEnabled) {
        return [self.springsHelper layoutAttributesAtIndexPath:indexPath];
    } else {
        return [super layoutAttributesForItemAtIndexPath:indexPath];
    }
}

#pragma mark - Private methods

@end
