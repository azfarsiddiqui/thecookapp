//
//  StoreFlowLayout.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreFlowLayout.h"
#import "MRCEnumerable.h"

@interface StoreFlowLayout ()

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;
@property (nonatomic, assign) BOOL springEnabled;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@end

@implementation StoreFlowLayout

#define kStoreBookInsertScale   0.5

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        // Enable Spring?
        self.springEnabled = NO;
        if (self.springEnabled) {
            self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        }
        
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    // Reset all behaviours.
    if (self.springEnabled) {
        [self.dynamicAnimator removeAllBehaviors];
        
        CGSize contentSize = self.collectionView.contentSize;
        NSArray *items = [super layoutAttributesForElementsInRect:
                          CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height)];
        
//        CGRect originalFrame = (CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size};
//        CGRect visibleFrame = CGRectInset(originalFrame, -100, -100);   // To take into account fast scrolling on either side.
//        
//        NSArray *items = [self layoutAttributesForElementsInRect:visibleFrame];
        
        [items each:^(UICollectionViewLayoutAttributes *attributes) {
            [self applyAttachmentBehaviourToAttributes:attributes];
        }];
    }
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    BOOL shouldInvalidate = NO;
    
    if (self.springEnabled) {
        
        shouldInvalidate = NO;
        
        CGFloat scrollDelta = newBounds.origin.x - self.collectionView.bounds.origin.x;
        CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
        
        // Loop through each attachment behaviour and amend the spring.
        for (UIAttachmentBehavior *attachment in [self currentAttachmentBehaviours]) {
            
            CGPoint anchorPoint = attachment.anchorPoint;
            CGFloat distanceFromTouch = fabsf(touchLocation.x - anchorPoint.x);
            CGFloat scrollResistance = distanceFromTouch / 1500.0;
            
            UICollectionViewLayoutAttributes *attributes = [attachment.items firstObject];
            CGPoint center = attributes.center;
            
            // Cap scrollDelta.
            if (scrollDelta > 0.0) {
                scrollDelta = MIN(scrollDelta, 20.0);
            } else {
                scrollDelta = MAX(scrollDelta, -20.0);
            }
            
            // Move the center so the spring can move it back.
            CGFloat centerOffset = scrollDelta * scrollResistance;
            NSLog(@"CENTER OFFSET %f", centerOffset);
            center.x += centerOffset;
            
            attributes.center = center;
            
            [self.dynamicAnimator updateItemUsingCurrentState:attributes];
        }
        
    } else {
        shouldInvalidate = YES;
    }
    
    return shouldInvalidate;
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
    if (self.springEnabled) {
        return [self.dynamicAnimator itemsInRect:rect];
    } else {
        return [super layoutAttributesForElementsInRect:rect];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.springEnabled) {
        return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
    } else {
        return [super layoutAttributesForItemAtIndexPath:indexPath];
    }
}

#pragma mark - Private methods

- (NSArray *)currentAttachmentBehaviours {
    return [self.dynamicAnimator.behaviors select:^BOOL(UIDynamicBehavior *dynamicBehaviour) {
        return [dynamicBehaviour isKindOfClass:[UIAttachmentBehavior class]];
    }];
}

- (void)applyAttachmentBehaviourToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    
    CGPoint center = attributes.center;
    
    // Main interaction spring.
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:center];
    spring.length = 0.0;
    spring.damping = 0.95;
    spring.frequency = 1.0;
    [self.dynamicAnimator addBehavior:spring];
    
    // Spring that doesn't let it fidget with residual springing.
    UIAttachmentBehavior *restSpring = [[UIAttachmentBehavior alloc] initWithItem:attributes
                                                                 attachedToAnchor:(CGPoint){ center.x, center.y }];
    restSpring.length = 1.0;
    restSpring.damping = 0.95;
    restSpring.frequency = 1.0;
    [self.dynamicAnimator addBehavior:restSpring];
}

@end
