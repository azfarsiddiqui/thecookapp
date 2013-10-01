//
//  RecipeSocialLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 24/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSocialLayout.h"
#import "ModalOverlayHeaderView.h"
#import "RecipeCommentBoxFooterView.h"
#import "RecipeCommentCell.h"
#import "ViewHelper.h"
#import "CKUserProfilePhotoView.h"

@interface RecipeSocialLayout ()

@property (nonatomic, weak) id<RecipeSocialLayoutDelegate> delegate;

@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, assign) BOOL allowCommenting;
@property (nonatomic, assign) CGSize cachedContentSize;

@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;

@property (nonatomic, strong) UICollectionViewLayoutAttributes *commentsHeaderAttributes;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *commentsFooterAttributes;

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@property (nonatomic, strong) NSMutableDictionary *commentsSize;

@end

@implementation RecipeSocialLayout

#define kContentInsets      (UIEdgeInsets){ 0.0, 15.0, 50.0, 25.0 }
#define kLikeInsets         (UIEdgeInsets){ 90.0, 0.0, 10.0, 25.0 }
#define kRowGap             0.0
#define kCommentWidth       600.0

- (id)initWithDelegate:(id<RecipeSocialLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setNeedsRelayout:(BOOL)relayout {
    self.cachedContentSize = CGSizeZero;
    self.layoutCompleted = !relayout;
}

#pragma mark - UICollectionViewLayout methods

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return YES;
}

- (CGSize)collectionViewContentSize {
    if (!CGSizeEqualToSize(self.cachedContentSize, CGSizeZero)) {
        return self.cachedContentSize;
    }
    
    DLog();
    CGFloat requiredHeight = 0.0;
    
    // Top inset.
    requiredHeight += kContentInsets.top;
    
    // Header.
    requiredHeight += [ModalOverlayHeaderView unitSize].height;
    
    // Comment items.
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    if (numItems > 0) {
        
        for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
            
            // Calculate the height of the comment if not cached.
            CKRecipeComment *comment = [self.delegate recipeSocialLayoutCommentAtIndex:itemIndex];
            CGSize size =  [self sizeForComment:comment commentIndex:itemIndex];
            requiredHeight += size.height;
            
            // Add the gap if in between.
            if (itemIndex < numItems - 1) {
                requiredHeight += kRowGap;
            }
        }
    }
    
    // Comment box footer.
    if (self.allowCommenting) {
        requiredHeight += [RecipeCommentBoxFooterView unitSize].height;
    }
    
    // Bottom inset.
    requiredHeight += kContentInsets.bottom;
    
    self.cachedContentSize = (CGSize){
        self.collectionView.bounds.size.width,
        MAX(requiredHeight, self.collectionView.bounds.size.height)
    };
    return self.cachedContentSize;
}

- (void)prepareLayout {
    
    // Skip if layout does not need to be regenerated.
    if (self.layoutCompleted) {
        return;
    }
    DLog();
    
    [self buildLayout];
    
    // Mark layout as generated.
    self.layoutCompleted = YES;
    
    // Inform end of layout prep.
    [self.delegate recipeSocialLayoutDidFinish];
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

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGRect bounds = self.collectionView.bounds;
    
    // Always contain all supplementary views and effects.
    
    NSMutableArray* layoutAttributes = [NSMutableArray arrayWithObject:self.commentsHeaderAttributes];
    if (self.allowCommenting) {
        [layoutAttributes addObject:self.commentsFooterAttributes];
    }
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        [self applyStickyHeaderFooter:attributes contentOffset:contentOffset bounds:bounds];
    }
    
    // Item cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        
        // Comments.
        if (CGRectIntersectsRect(visibleFrame, attributes.frame)) {
            [self applyCommentsFading:attributes contentOffset:contentOffset bounds:bounds];
            [layoutAttributes addObject:attributes];
        }
        
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.commentsHeaderAttributes;
    } else {
        return self.commentsFooterAttributes;
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    // Comments slide down and fades in.
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        attributes.transform3D = CATransform3DMakeTranslation(0.0, -20.0, 0.0);
        attributes.alpha = 0.0;
    } else {
        attributes.alpha = 1.0;
    }
    
    return attributes;
}

#pragma mark - Private methods

- (void)buildLayout {
    self.allowCommenting = [self.delegate recipeSocialLayoutAllowCommenting];
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.commentsHeaderAttributes = nil;
    self.commentsFooterAttributes = nil;
    
    CGRect bounds = self.collectionView.bounds;
    [self buildCommentsLayoutWithBounds:bounds];
}

- (void)buildCommentsLayoutWithBounds:(CGRect)bounds {
    self.commentsSize = [NSMutableDictionary dictionary];
    
    // Init the vertical offset.
    CGFloat yOffset = kContentInsets.top;
    
    // Header layout.
    NSIndexPath *commentsHeaderIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *commentsHeaderAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                                withIndexPath:commentsHeaderIndexPath];
    commentsHeaderAttributes.frame = (CGRect){
        bounds.origin.x,
        yOffset,
        bounds.size.width,
        [ModalOverlayHeaderView unitSize].height
    };
    yOffset += commentsHeaderAttributes.frame.size.height;
    self.commentsHeaderAttributes = commentsHeaderAttributes;
    
    if ([self.delegate recipeSocialLayoutIsLoading]) {
        
        // Spinner layout.
        NSIndexPath *activityIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        UICollectionViewLayoutAttributes *activityAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:activityIndexPath];
        activityAttributes.frame = (CGRect){
            floorf((bounds.size.width - kCommentWidth) / 2.0),
            yOffset,
            kCommentWidth,
            bounds.size.height - [ModalOverlayHeaderView unitSize].height - yOffset
        };
        [self.itemsLayoutAttributes addObject:activityAttributes];
        [self.indexPathItemAttributes setObject:activityAttributes forKey:activityIndexPath];
        
        yOffset += activityAttributes.frame.size.height;
        
    } else {
        
        // Comments layout.
        NSInteger numComments = [self.collectionView numberOfItemsInSection:0];
        for (NSInteger commentIndex = 0; commentIndex < numComments; commentIndex++) {
            NSIndexPath *commentIndexPath = [NSIndexPath indexPathForItem:commentIndex inSection:0];
            UICollectionViewLayoutAttributes *commentAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:commentIndexPath];
            
            CKRecipeComment *comment = [self.delegate recipeSocialLayoutCommentAtIndex:commentIndex];
            CGSize size = [self sizeForComment:comment commentIndex:commentIndex];
            commentAttributes.frame = (CGRect){
                floorf((bounds.size.width - kCommentWidth) / 2.0),
                yOffset,
                kCommentWidth,
                size.height
            };
            commentAttributes.zIndex = (commentIndex + 1) * -1;
            
            [self.itemsLayoutAttributes addObject:commentAttributes];
            [self.indexPathItemAttributes setObject:commentAttributes forKey:commentIndexPath];
            
            yOffset += commentAttributes.frame.size.height;
            
            // Row gap.
            if (commentIndex != numComments - 1) {
                yOffset += kRowGap;
            }
        }
    }
    
    // Footer layout.
    if (self.allowCommenting) {
        NSIndexPath *commentsFooterIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        UICollectionViewLayoutAttributes *commentsFooterAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                                                                    withIndexPath:commentsFooterIndexPath];
        commentsFooterAttributes.frame = (CGRect){
            bounds.origin.x,
            yOffset,
            bounds.size.width,
            [ModalOverlayHeaderView unitSize].height
        };
        self.commentsFooterAttributes = commentsFooterAttributes;
    }
}

- (CGSize)sizeForComment:(CKRecipeComment *)comment commentIndex:(NSInteger)commentIndex {
    if (![self.commentsSize objectForKey:@(commentIndex)]) {
        CGSize size = [RecipeCommentCell sizeForComment:comment];
        [self.commentsSize setObject:[NSValue valueWithCGSize:size] forKey:@(commentIndex)];
    }
    return [[self.commentsSize objectForKey:@(commentIndex)] CGSizeValue];
}

- (void)applyStickyHeaderFooter:(UICollectionViewLayoutAttributes *)attributes contentOffset:(CGPoint)contentOffset
                         bounds:(CGRect)bounds {
    if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        attributes.frame = [self adjustedFrameForHeaderFrame:attributes.frame contentOffset:contentOffset bounds:bounds];
    } else if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        attributes.frame = [self adjustedFrameForFooterFrame:attributes.frame contentOffset:contentOffset bounds:bounds];
    }
}

- (void)applyCommentsFading:(UICollectionViewLayoutAttributes *)attributes contentOffset:(CGPoint)contentOffset
                     bounds:(CGRect)bounds {
    
    if (!attributes.representedElementKind) {
        
        CGFloat topFadeOffset = contentOffset.y + 100.0;
        CGFloat bottomFadeOffset = contentOffset.y + bounds.size.height - 100.0;
        CGFloat minAlpha = 0.3;
        
        CGRect frame = attributes.frame;
        
        if (frame.origin.y <= topFadeOffset) {
            CGFloat effectiveDistance = 100.0;
            CGFloat distance = MIN(topFadeOffset - frame.origin.y, effectiveDistance);
            attributes.alpha = MAX(minAlpha, 1.0 - (distance / effectiveDistance));
        } else if (self.allowCommenting && frame.origin.y + frame.size.height >= bottomFadeOffset) {
            CGFloat effectiveDistance = 70.0;
            CGFloat distance = MIN((frame.origin.y + frame.size.height) - bottomFadeOffset, effectiveDistance);
            attributes.alpha = MAX(minAlpha, 1.0 - (distance / effectiveDistance));
        } else {
            attributes.alpha = 1.0;
        }
    }
}

- (CGRect)adjustedFrameForHeaderFrame:(CGRect)frame contentOffset:(CGPoint)contentOffset
                               bounds:(CGRect)bounds {
    CGRect adjustedFrame = frame;
    if (contentOffset.y > 0) {
        adjustedFrame.origin.y = contentOffset.y;
    } else {
        adjustedFrame.origin.y = 0.0;
    }
    return adjustedFrame;
}

- (CGRect)adjustedFrameForFooterFrame:(CGRect)frame contentOffset:(CGPoint)contentOffset
                               bounds:(CGRect)bounds {
    CGRect adjustedFrame = frame;
    adjustedFrame.origin.y = contentOffset.y + bounds.size.height - frame.size.height;
    return adjustedFrame;
}

@end
