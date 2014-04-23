//
//  CKPagingCollectionViewLayout.m
//  CKPagingBenchtopDemo
//
//  Created by Jeff Tan-Ang on 8/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PagingCollectionViewLayout.h"
#import "BenchtopBookCoverViewCell.h"
#import "MRCEnumerable.h"
#import "ViewHelper.h"

@interface PagingCollectionViewLayout ()

@property (nonatomic, weak) id<PagingCollectionViewLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL followMode;

@property (nonatomic, strong) NSMutableArray *anchorPoints;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@property (nonatomic, assign) BOOL springEnabled;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@end

@implementation PagingCollectionViewLayout

#define kContentInsets                  UIEdgeInsetsMake(175.0, 362.0, 155.0, 362.0)
#define kSideMargin                     62.0
#define kMyBookSection                  0
#define kFollowSection                  1
#define kBookScaleFactor                1.1
#define kBookDeleteScaleFactor          0.9

+ (CGSize)bookSize {
    return [BenchtopBookCoverViewCell cellSize];
}

- (id)initWithDelegate:(id<PagingCollectionViewLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        
        // Enable Spring?
        self.springEnabled = YES;
        if (self.springEnabled) {
            self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        }
    }
    return self;
}

- (void)markLayoutDirty {
    self.layoutCompleted = NO;
}

- (void)enableEditMode:(BOOL)editMode {
    self.editMode = editMode;
    [self markLayoutDirty];
}

- (void)enableFollowMode:(BOOL)followMode {
    self.followMode = followMode;
}

- (CGRect)frameForGap {
    CGSize bookSize = [BenchtopBookCoverViewCell cellSize];
    return (CGRect){
        (kSideMargin + bookSize.width) + bookSize.width,
        kContentInsets.top,
        bookSize.width,
        bookSize.height
    };
}

- (NSArray *)bookAnchorPoints {
    NSMutableArray *bookAnchorPoints = [NSMutableArray arrayWithArray:self.anchorPoints];
    [bookAnchorPoints removeObjectAtIndex:1];
    return bookAnchorPoints;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForMyBook {
    CGSize bookSize = [BenchtopBookCoverViewCell cellSize];
    NSIndexPath *myBookIndexPath = [NSIndexPath indexPathForItem:0 inSection:kMyBookSection];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:myBookIndexPath];
    attributes.frame = (CGRect) {
        kContentInsets.left,
        kContentInsets.top,
        bookSize.width,
        bookSize.height
    };
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForFollowBookAtIndex:(NSInteger)bookIndex {
    CGSize bookSize = [BenchtopBookCoverViewCell cellSize];
    CGPoint cellOffset = [self offsetForFollowBookAtIndex:bookIndex];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:bookIndex inSection:kFollowSection];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = (CGRect) { cellOffset.x, cellOffset.y, bookSize.width, bookSize.height };
    return attributes;
}

- (CGPoint)offsetForFollowBookAtIndex:(NSInteger)bookIndex {
    CGSize bookSize = [BenchtopBookCoverViewCell cellSize];
    
    // Compulsory gap: my book + empty book
    CGPoint cellOffset = (CGPoint) {
        kContentInsets.left + bookSize.width + bookSize.width,
        kContentInsets.top
    };
    
    return (CGPoint){
        cellOffset.x + (bookIndex * bookSize.width),
        kContentInsets.top
    };
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    CGSize bookSize = [BenchtopBookCoverViewCell cellSize];
    
    NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
    CGFloat emptyBookGap = bookSize.width;

    CGSize minSize = (CGSize){
        kContentInsets.left + bookSize.width + emptyBookGap + bookSize.width + kContentInsets.right,
        self.collectionView.bounds.size.height
    };
    CGSize requiredSize = (CGSize){
        kContentInsets.left + bookSize.width + emptyBookGap + (numFollowBooks * bookSize.width) + kContentInsets.right,
        self.collectionView.bounds.size.height
    };
    
    return requiredSize.width > minSize.width ? requiredSize : minSize;
}

- (void)prepareLayout {
    [self buildLayout:NO];
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
    DLog();
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

- (void)finalizeCollectionViewUpdates {
    DLog();
    [super finalizeCollectionViewUpdates];
    
    [self.insertedIndexPaths removeAllObjects];
    [self.deletedIndexPaths removeAllObjects];
    self.insertedIndexPaths = nil;
    self.deletedIndexPaths = nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    if (self.springEnabled) {
        [layoutAttributes addObjectsFromArray:[self.dynamicAnimator itemsInRect:rect]];
    } else {
        
        // Item cells.
        [layoutAttributes addObjectsFromArray:self.itemsLayoutAttributes];
    }
    
    // Cell returns kind of nil.
    NSArray *cellLayoutAttributes = [layoutAttributes select:^BOOL(UICollectionViewLayoutAttributes *attributes) {
        return (attributes.representedElementKind == nil);
    }];
    
    [self applyPagingEffects:cellLayoutAttributes];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.springEnabled) {
        return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
    } else {
        return [self.indexPathItemAttributes objectForKey:indexPath];
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *initialAttributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    initialAttributes.alpha = 1.0;
    
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        
        if (itemIndexPath.section == kMyBookSection) {
            
            // Inserted my book plops down.
            CATransform3D scaleTransform = CATransform3DScale(initialAttributes.transform3D, kBookScaleFactor, kBookScaleFactor, 0.0);
            initialAttributes.transform3D = scaleTransform;
            
        } else if (itemIndexPath.section == kFollowSection) {
            
            if (self.followMode) {
                
                // Followed book slides down.
                CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, 0.0, -100.0, 0.0);
                initialAttributes.transform3D = translateTransform;
                
            } else {
                
                // Inserted followed book slides in.
                CATransform3D translateTransform = CATransform3DTranslate(initialAttributes.transform3D, 62.0, 0.0, 0.0);
                initialAttributes.transform3D = translateTransform;
            }
        }
        
    }
    
    return initialAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
                                 withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    for (NSValue *anchorValue in self.anchorPoints) {
        CGPoint anchorPoint = [anchorValue CGPointValue];
        CGFloat itemHorizontalCenter = anchorPoint.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    CGPoint targetContentOffset = CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
    return targetContentOffset;
}

#pragma mark - Private methods

- (void)buildLayout:(BOOL)force {
    
    // If layout has already completed and not forced, then return immediately.
    if (!force && self.layoutCompleted) {
        return;
    }
    
    DLog(@"Building layout");
    
    CGSize bookSize = [BenchtopBookCoverViewCell cellSize];
    self.anchorPoints = [NSMutableArray array];
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    
    // Reset all behaviours.
    if (self.springEnabled) {
        [self.dynamicAnimator removeAllBehaviors];
    }
    
    // Do we have my book?
    if ([self.collectionView numberOfItemsInSection:kMyBookSection] != 0) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForMyBook];
        
        [self.anchorPoints addObject:[NSValue valueWithCGPoint:attributes.center]];
        [self.itemsLayoutAttributes addObject:attributes];
        [self.indexPathItemAttributes setObject:attributes forKey:attributes.indexPath];
        
        if (self.springEnabled) {
            [self applyAttachmentBehaviourToAttributes:attributes];
        }
    }
    
    // Do we have followed books?
    if ([self.delegate pagingLayoutFollowsDidLoad]) {
        
        NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
        if (numFollowBooks > 0) {
            
            // Middle gap/anchor.
            UICollectionViewLayoutAttributes *myBookAttributes = [self.itemsLayoutAttributes firstObject];
            CGPoint gapAnchor = (CGPoint){ myBookAttributes.center.x + bookSize.width, myBookAttributes.center.y };
            [self.anchorPoints addObject:[NSValue valueWithCGPoint:gapAnchor]];
            
            // Build the other books.
            for (NSInteger bookIndex = 0; bookIndex < numFollowBooks; bookIndex++) {
                
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForFollowBookAtIndex:bookIndex];
                [self.anchorPoints addObject:[NSValue valueWithCGPoint:attributes.center]];
                [self.itemsLayoutAttributes addObject:attributes];
                [self.indexPathItemAttributes setObject:attributes forKey:attributes.indexPath];
                
                if (self.springEnabled) {
                    [self applyAttachmentBehaviourToAttributes:attributes];
                }
            }
            
        } else {
            
            // Empty follow books should have an anchor.
            UICollectionViewLayoutAttributes *firstFollowBookAttributes = [self layoutAttributesForFollowBookAtIndex:0];
            [self.anchorPoints addObject:[NSValue valueWithCGPoint:firstFollowBookAttributes.center]];
            
        }
        
    } else {
        
        // Spinner anchor.
        UICollectionViewLayoutAttributes *firstFollowBookAttributes = [self layoutAttributesForFollowBookAtIndex:0];
        [self.anchorPoints addObject:[NSValue valueWithCGPoint:firstFollowBookAttributes.center]];
        
    }
    
    // Mark layout as completed.
    self.layoutCompleted = YES;
    
    // Inform delegate of updated layout.
    [self.delegate pagingLayoutDidUpdate];
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    [self applyScaling:layoutAttributes];
    [self applyPartingEffects:layoutAttributes];
    [self applyEditModeEffects:layoutAttributes];
}

- (void)applyScaling:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        CGFloat scaleFactor = [self scaleFactorForCenter:attributes.center];
        attributes.transform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
    }
}

- (void)applyPartingEffects:(NSArray *)layoutAttributes {
    
    CGFloat partDistance = 20.0;
    CGSize bookSize = [BenchtopBookCoverViewCell cellSize];
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        CGPoint center = attributes.center;
        CGRect visibleRect = [self visibleFrame];
        CGFloat distance = CGRectGetMidX(visibleRect) - center.x;
        
        if (ABS(distance) >= bookSize.width && ABS(distance) < bookSize.width * 2.0) {
            
            // If distance is less than two books away, then start the parting towards the edge.
            CGFloat normalizedDistance = (ABS(distance) - bookSize.width) / bookSize.width;
            CGFloat translateOffset = (1.0 - ABS(normalizedDistance)) * partDistance;
            if (distance > 0) {
                translateOffset *= -1;
            }
            
            attributes.transform3D = CATransform3DTranslate(attributes.transform3D, translateOffset, 0.0, 0.0);
            
        } else if (ABS(distance) < bookSize.width) {
            
            // If distance is less than a book away, then revert the parting towards the center.
            CGFloat normalizedDistance = distance / bookSize.width;
            CGFloat translateOffset = ABS(normalizedDistance) * partDistance;
            if (distance > 0) {
                translateOffset *= -1;
            }
            
            attributes.transform3D = CATransform3DTranslate(attributes.transform3D, translateOffset, 0.0, 0.0);
            
        }
        
    }
}

- (void)applyEditModeEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        if (self.editMode) {
            NSIndexPath *indexPath = attributes.indexPath;
            if (indexPath.section == kMyBookSection) {
                attributes.alpha = 1.0;
            } else if (indexPath.section == kFollowSection) {
                attributes.alpha = 0.0;
            }
        } else {
            attributes.alpha = 1.0;
        }
    }
}

- (CGFloat)scaleFactorForCenter:(CGPoint)center {
    CGSize bookSize = [BenchtopBookCoverViewCell cellSize];
    CGRect visibleRect = [self visibleFrame];
    CGFloat minScaleFactor = 0.78;
    CGFloat distance = CGRectGetMidX(visibleRect) - center.x;
    CGFloat normalizedDistance = distance / bookSize.width;
    CGFloat scaleFactor = 0.0;
    
    if (ABS(distance) <= bookSize.width) {
        scaleFactor = 1.0 - (ABS(normalizedDistance) * (1.0 - minScaleFactor));
    } else {
        scaleFactor = minScaleFactor;
    }
    
    // DLog(@"scaleFactor [%f]", scaleFactor);
    return scaleFactor;
}

- (CGRect)visibleFrame {
    return CGRectMake(self.collectionView.contentOffset.x,
                      self.collectionView.contentOffset.y,
                      self.collectionView.bounds.size.width,
                      self.collectionView.bounds.size.height);
}

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
