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
@property (nonatomic, strong) NSArray *supportedBehaviours;

@end

@implementation CKCollectionViewSpringsHelper

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout {
    
    if (self = [super init]) {
        self.collectionViewLayout = collectionViewLayout;
        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:collectionViewLayout];
        
        // Default spring values.
        self.springDamping = 0.7;
        self.springMaxOffset = self.collisionEnabled ? MAXFLOAT : 20.0;
        self.springResistance = 4000.0;
        
        // Supported behaviours.
        self.supportedBehaviours = @[[UIAttachmentBehavior class], [UICollisionBehavior class]];
    }
    return self;
}

- (void)reset {
    [self.dynamicAnimator removeAllBehaviors];
}

- (BOOL)shouldInvalidateAfterApplyingOffsetsForNewBounds:(CGRect)newBounds collectionView:(UICollectionView *)collectionView {
    CGFloat scrollDelta = newBounds.origin.x - collectionView.bounds.origin.x;
    CGPoint touchLocation = [collectionView.panGestureRecognizer locationInView:collectionView];
    
    DLog();
    
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

- (void)applyAttachmentBehaviourToAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    // Spring anchor point has to be rounded (not fractional which pulsates it).
    CGPoint anchorPoint = (CGPoint) {
        round(layoutAttributes.center.x),
        round(layoutAttributes.center.y)
    };
    
//    DLog(@"Anchor Point: %@", NSStringFromCGPoint(anchorPoint));
    
    // Spring properties.
    CGFloat frequency = 1.0;
    
    // Main interaction spring.
    UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:layoutAttributes attachedToAnchor:anchorPoint];
    spring.length = 0.0;
    spring.damping = self.springDamping;
    spring.frequency = frequency;
    [self.dynamicAnimator addBehavior:spring];
    
    // Spring that doesn't let it fidget with residual springing.
    UIAttachmentBehavior *restSpring = [[UIAttachmentBehavior alloc] initWithItem:layoutAttributes
                                                                 attachedToAnchor:(CGPoint){ anchorPoint.x, anchorPoint.y }];
    restSpring.length = 1.0;
    restSpring.damping = self.springDamping;
    restSpring.frequency = frequency;
    [self.dynamicAnimator addBehavior:restSpring];
}

- (void)applyCollisionBehaviourToAttributeItems:(NSArray *)attributes {
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:attributes];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    
    UICollectionViewLayoutAttributes *firstLayoutAttributes = [attributes firstObject];
    CGFloat availableVerticalSpace = self.collectionViewLayout.collectionView.bounds.size.height - firstLayoutAttributes.frame.size.height;
    CGFloat availableHorizontalSpace = -196.0;
//    CGFloat availableHorizontalSpace = 30.0;
    
    // Left/Right edges needs to be inset to take into account the shadow.
    // Top/Bottom edges to be extend above/below book to prevent pulsing/rotation when they collide.
//    [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:(UIEdgeInsets){ 100.0, -48.0, 100.0, -48.0 }];
    
    [collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:(UIEdgeInsets){
        floorf(availableVerticalSpace / 2.0),
        floorf(availableHorizontalSpace / 2.0),
        floorf(availableVerticalSpace / 2.0),
        floorf(availableHorizontalSpace / 2.0),
    }];
    [self.dynamicAnimator addBehavior:collisionBehavior];
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
