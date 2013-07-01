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

@implementation BenchtopCollectionFlowLayout {    
    UIDynamicAnimator *_dynamicAnimator;
}

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

- (void)prepareLayout {
    [super prepareLayout];
    DLog();
    
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    
    if (_dynamicAnimator.running) {
        return;
    }
    [_dynamicAnimator removeAllBehaviors];
    
    CGSize contentSize = [self collectionViewContentSize];
//    CGSize contentSize = (CGSize){6000.0, self.collectionView.bounds.size.height};
    NSArray *items = [super layoutAttributesForElementsInRect:(CGRect){ 0, 0, contentSize.width, contentSize.height }];
    for (UICollectionViewLayoutAttributes *attributes in items) {
        [self applyAttachmentBehaviourToAttributes:attributes];
    }
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGFloat scrollDelta = newBounds.origin.x - self.collectionView.bounds.origin.x;
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    // Loop through each attachment behaviour and amend the spring.
    for (UIAttachmentBehavior *attachment in _dynamicAnimator.behaviors) {
        
        CGPoint anchorPoint = attachment.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.x - anchorPoint.x);
        CGFloat scrollResistance = distanceFromTouch / 500.0;
        
        UICollectionViewLayoutAttributes *attributes = [attachment.items firstObject];
        
//        if (CGRectContainsPoint(attributes.frame,
//                                (CGPoint){ newBounds.origin.x + (newBounds.size.width / 2.0), newBounds.size.height / 2.0 })) {
//            
//        } else {
        
            CGPoint center = attributes.center;
//            center.x += scrollDelta * scrollResistance;
            DLog(@"Offset from: %f to %f", center.x, center.x + scrollDelta);
            center.x += scrollDelta;
            attributes.center = center;
            
//            [_dynamicAnimator updateItemFromCurrentState:attributes];
//        }
        
    }
    
    return NO;
    
//    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *layoutAttributes = [_dynamicAnimator itemsInRect:rect];
//    NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
//    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
//        
//        if ([self scalingRequiredForAttributes:attributes]) {
//            CGFloat scaleFactor = [self scaleFactorForCenter:attributes.center];
//            attributes.transform3D = CATransform3DScale(attributes.transform3D, scaleFactor, scaleFactor, 1.0);
//            
//        }
//    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
//                                 withScrollingVelocity:(CGPoint)velocity {
//    CGFloat offsetAdjustment = MAXFLOAT;
//    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
//    
//    CGRect targetRect = CGRectMake(proposedContentOffset.x,
//                                   0.0,
//                                   self.collectionView.bounds.size.width,
//                                   self.collectionView.bounds.size.height);
//    
//    NSArray* array = [self layoutAttributesForElementsInRect:targetRect];
//    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
//        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
//        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
//            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
//        }
//    }
//    
//    CGPoint targetContentOffset = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
//    return targetContentOffset;
//}

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
    
    // Drop my book onto the benchtop.
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        
        if (initialAttributes == nil) {
            initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        if (itemIndexPath.section == 0) {
            CATransform3D scaleTransform = CATransform3DScale(initialAttributes.transform3D, kBookScaleFactor, kBookScaleFactor, 0.0);
            initialAttributes.transform3D = scaleTransform;
        } else if (itemIndexPath.section == 1) {
            CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, 62.0, 0.0, 0.0);
            initialAttributes.transform3D = translateTransform;
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

//#pragma mark - Properties
//
//- (UIDynamicAnimator *)dynamicAnimator {
//    if (!_dynamicAnimator) {
//        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
//    }
//    return _dynamicAnimator;
//}

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

- (void)applyAttachmentBehaviourToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:attributes.center];
    spring.length = 0;
    spring.damping = 0.5;
    spring.frequency = 0.8;
    
//    NSLog(@"Added behaviour %@ to %@", spring, attributes);
    [_dynamicAnimator addBehavior:spring];
}

@end
