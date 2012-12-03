//
//  BenchtopFlowLayout.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "BenchtopCollectionFlowLayout.h"
#import "BenchtopBookCoverViewCell.h"
#import "MRCEnumerable.h"

@interface BenchtopCollectionFlowLayout ()

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@end

@implementation BenchtopCollectionFlowLayout

#define kBookScaleFactor            1.1
#define kBookRotationDegrees        5.0
#define kBookTranslate              20.0
#define DEGREES_TO_RADIANS(angle)   ((angle) / 180.0 * M_PI)

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        if ([self scalingRequiredForAttributes:attributes]) {
            CGFloat scaleFactor = [self scaleFactorForCenter:attributes.center];
            attributes.transform3D = CATransform3DScale(attributes.transform3D, scaleFactor, scaleFactor, 1.0);
            
        }
    }
    return layoutAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x,
                                   0.0,
                                   self.collectionView.bounds.size.width,
                                   self.collectionView.bounds.size.height);
    
    NSArray* array = [self layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    CGPoint targetContentOffset = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
    return targetContentOffset;
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

    DLog(@"INSERTED %@", self.insertedIndexPaths);
    DLog(@"DELETED  %@", self.deletedIndexPaths);

}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    // Custom inserted item.
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == 0) {
            if (initialAttributes == nil) {
                initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
            }
            
            CATransform3D scaleTransform = CATransform3DScale(initialAttributes.transform3D, kBookScaleFactor, kBookScaleFactor, 0.0);
            initialAttributes.transform3D = scaleTransform;
        }
        
    }
    
    return initialAttributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *finalAttributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    // Custom deleted item.
    if ([self.deletedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == 0) {
            
            if (finalAttributes == nil) {
//                finalAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemIndexPath];
                finalAttributes = [self findLayoutAttributesForIndexPath:itemIndexPath];
            }
            
            // Deleted my book fades away.
            finalAttributes.alpha = 0.0;
//            finalAttributes.center = CGPointMake(self.collectionView.center.x, self.collectionView.center.y + 600.0);
            finalAttributes.transform3D = CATransform3DMakeTranslation(0.0, self.collectionView.bounds.size.height - finalAttributes.frame.origin.y, 0.0);
            
        }
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

#pragma mark - Private methods

- (CGRect)visibleFrame {
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      self.collectionView.bounds.size.width,
                      self.collectionView.bounds.size.height);
}

- (CGFloat)scaleFactorForCenter:(CGPoint)center {
    CGRect visibleRect = [self visibleFrame];
    CGSize itemSize = [BenchtopBookCoverViewCell cellSize];
    CGFloat minScaleFactor = 0.78;
    CGFloat distance = CGRectGetMidX(visibleRect) - center.x;
    CGFloat normalizedDistance = distance / itemSize.width;
    
    if (ABS(distance) <= itemSize.width) {
        CGFloat scaleFactor = 1.0 - (ABS(normalizedDistance) * (1.0 - minScaleFactor));
        return scaleFactor;
    } else {
        return minScaleFactor;
    }
}

- (BOOL)scalingRequiredForAttributes:(UICollectionViewLayoutAttributes *)attributes {
    return YES;     
    // return (attributes.indexPath.section == 1);
}

- (UICollectionViewLayoutAttributes *)findLayoutAttributesForIndexPath:(NSIndexPath *)indexPath {
    NSArray *layoutAttributes = [self layoutAttributesForElementsInRect:[self visibleFrame]];
    UICollectionViewLayoutAttributes *attributes = [layoutAttributes detect:^BOOL(UICollectionViewLayoutAttributes *layoutAttribute) {
        return (layoutAttribute.indexPath.section == indexPath.section && layoutAttribute.indexPath.item == indexPath.item);
    }];
    return attributes;
}

@end
