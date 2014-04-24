//
//  CKCollectionViewSpringsHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 24/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKCollectionViewSpringsHelper.h"

@interface CKCollectionViewSpringsHelper ()

@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@end

@implementation CKCollectionViewSpringsHelper

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout {
    
    if (self = [super init]) {
        self.collectionViewLayout = collectionViewLayout;
        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:collectionViewLayout];
        
        // Default spring values.
        self.springDamping = 0.65;
        self.springMaxOffset = 15.0;
        self.springResistance = 4000.0;
    }
    return self;
}

- (void)reset {
    [self.dynamicAnimator removeAllBehaviors];
}

- (BOOL)shouldInvalidateAfterApplyingOffsetsForNewBounds:(CGRect)newBounds collectionView:(UICollectionView *)collectionView {
    
    CGFloat scrollDelta = newBounds.origin.x - collectionView.bounds.origin.x;
    CGPoint touchLocation = [collectionView.panGestureRecognizer locationInView:collectionView];
    
    // Loop through each attachment behaviour and amend the spring.
    for (UIAttachmentBehavior *attachment in [self currentAttachmentBehaviours]) {
        
        CGPoint anchorPoint = attachment.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.x - anchorPoint.x);
        
        UICollectionViewLayoutAttributes *attributes = [attachment.items firstObject];
        CGPoint center = attributes.center;
        
        // Required resistance.
        CGFloat scrollResistance = distanceFromTouch / self.springResistance;
        
        // Required delta offset.
        CGFloat maxShift = self.springMaxOffset;
        if (scrollDelta < 0) {
            scrollDelta = MAX(scrollDelta, -maxShift);
        } else {
            scrollDelta = MIN(scrollDelta, maxShift);
        }
        
        // Shift the attribute center.
        center.x += scrollDelta * scrollResistance;
        attributes.center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:attributes];
    }
    
    return NO;
}

- (NSArray *)layoutAttributesInFrame:(CGRect)frame {
    return [self.dynamicAnimator itemsInRect:frame];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (void)applyAttachmentBehaviourToAttributes:(UICollectionViewLayoutAttributes *)attributes {
    
    CGPoint center = attributes.center;
    
    // Spring properties.
    CGFloat damping = 0.7;
    CGFloat frequency = 1.0;
    
    // Main interaction spring.
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:center];
    spring.length = 0.0;
    spring.damping = damping;
    spring.frequency = frequency;
    [self.dynamicAnimator addBehavior:spring];
    
    // Spring that doesn't let it fidget with residual springing.
    UIAttachmentBehavior *restSpring = [[UIAttachmentBehavior alloc] initWithItem:attributes
                                                                 attachedToAnchor:(CGPoint){ center.x, center.y }];
    restSpring.length = 1.0;
    restSpring.damping = damping;
    restSpring.frequency = frequency;
    [self.dynamicAnimator addBehavior:restSpring];
}

#pragma mark - Private methods

- (NSArray *)currentAttachmentBehaviours {
    
    // return behaviour that are
    return [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:
            [NSPredicate predicateWithBlock:^BOOL(UIDynamicBehavior *dynamicBehaviour, NSDictionary *bindings) {
        return [dynamicBehaviour isKindOfClass:[UIAttachmentBehavior class]];
    }]];
}
@end
