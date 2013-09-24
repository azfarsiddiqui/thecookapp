//
//  RecipeSocialViewLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeSocialViewLayout.h"
#import "MRCEnumerable.h"

@interface RecipeSocialViewLayout ()

@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@end

@implementation RecipeSocialViewLayout

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}

#pragma mark - UICollectionViewFlowLayout methods

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    // Make sure the header row is always there as flow layout will discard it after scrolling off bounds.
    if (![layoutAttributes detect:^BOOL(UICollectionViewLayoutAttributes *attributes){
        return [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader];
    }]) {
        [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                         atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    }
    
    // Make sure the footer row is always there as flow layout will discard it after scrolling off bounds.
    if (![layoutAttributes detect:^BOOL(UICollectionViewLayoutAttributes *attributes){
        return [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter];
    }]) {
        [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                         atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    }
    
    [self applyPagingEffects:layoutAttributes];
    
    return layoutAttributes;
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
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertedIndexPaths containsObject:itemIndexPath]) {
        attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        attributes.transform3D = CATransform3DMakeTranslation(0.0, -20.0, 0.0);
        attributes.alpha = 0.0;
    }
    
    return attributes;
}

#pragma mark - Private methods

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        [self applyHeaderEffects:attributes];
        [self applyFadingEffects:attributes];
        [self applyOrdering:attributes];
    }
}

- (void)applyHeaderEffects:(UICollectionViewLayoutAttributes *)attributes {
    if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        attributes.frame = [self adjustedFrameForHeaderFrame:attributes.frame];
    } else if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        attributes.frame = [self adjustedFrameForFooterFrame:attributes.frame];
    }
}

- (void)applyFadingEffects:(UICollectionViewLayoutAttributes *)attributes {
    if (!attributes.representedElementKind) {
        
        // Fade at top of header.
        UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                  atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        CGRect proposedHeaderFrame = [self adjustedFrameForHeaderFrame:headerAttributes.frame];
        CGFloat topFadeOffset = proposedHeaderFrame.origin.y + proposedHeaderFrame.size.height;
        
        // Fade at bottom of footer.
        UICollectionViewLayoutAttributes *footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                                  atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        CGRect proposedFooterFrame = [self adjustedFrameForFooterFrame:footerAttributes.frame];
        CGFloat bottomFadeOffset = proposedFooterFrame.origin.y;
        
        CGRect frame = attributes.frame;
        
        if (frame.origin.y < topFadeOffset) {
            CGFloat effectiveDistance = 100.0;
            CGFloat distance = topFadeOffset - frame.origin.y;
            attributes.alpha = 1.0 - (distance / effectiveDistance);
        } else if (frame.origin.y + frame.size.height > bottomFadeOffset) {
            CGFloat effectiveDistance = 50.0;
            CGFloat distance = (frame.origin.y + frame.size.height) - bottomFadeOffset;
            attributes.alpha = 1.0 - (distance / effectiveDistance);
        }
        
    }

}

- (void)applyOrdering:(UICollectionViewLayoutAttributes *)attributes {
    if (!attributes.representedElementKind) {
        attributes.zIndex = attributes.indexPath.item + 1;
    }
}

- (CGRect)adjustedFrameForHeaderFrame:(CGRect)frame {
    CGRect adjustedFrame = frame;
    CGPoint currentOffset = self.collectionView.contentOffset;
    if (currentOffset.y > 0) {
        adjustedFrame.origin.y = currentOffset.y;
    }
    return adjustedFrame;
}

- (CGRect)adjustedFrameForFooterFrame:(CGRect)frame {
    CGRect adjustedFrame = frame;
    CGPoint currentOffset = self.collectionView.contentOffset;
    adjustedFrame.origin.y = currentOffset.y + self.collectionView.bounds.size.height - frame.size.height;
    return adjustedFrame;
}

@end
