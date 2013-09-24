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
#import "RecipeSocialCommentCell.h"

@interface RecipeSocialLayout ()

@property (nonatomic, weak) id<RecipeSocialLayoutDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *deletedIndexPaths;

@property (nonatomic, strong) NSMutableDictionary *commentsSize;
@property (nonatomic, strong) NSMutableDictionary *commentsIndexLayout;

@end

@implementation RecipeSocialLayout

#define kContentInsets      (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kRowGap             20.0
#define kFrame              @"frame"
#define kNameFrame          @"nameFrame"
#define kTimeFrame          @"timeFrame"
#define kCommentFrame       @"commentFrame"

- (id)initWithDelegate:(id<RecipeSocialLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - UICollectionViewLayout methods

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds {
    return NO;
}

- (CGSize)collectionViewContentSize {
    CGFloat requiredHeight = 0.0;
    
    // Header.
    requiredHeight += [ModalOverlayHeaderView unitSize].height;
    
    // Comment items.
    NSInteger numItems = [self.collectionView numberOfItemsInSection:0];
    if (numItems > 0) {
        
        for (NSInteger itemIndex = 0; itemIndex < numItems; itemIndex++) {
            
            // Calculate the height of the comment if not cached.
            if (![self.commentsSize objectForKey:@(itemIndex)]) {
                CKRecipeComment *comment = [self.delegate recipeSocialLayoutCommentAtIndex:itemIndex];
                CGSize size = [RecipeSocialCommentCell sizeForComment:comment];
                [self.commentsSize setObject:[NSValue valueWithCGSize:size] forKey:@(itemIndex)];
                
            }
            requiredHeight += [[self.commentsSize objectForKey:@(itemIndex)] CGSizeValue].height;
            
            // Add the gap if in between.
            if (itemIndex < numItems - 1) {
                requiredHeight += kRowGap;
            }
        }
    }
    
    // Footer.
    requiredHeight += [RecipeCommentBoxFooterView unitSize].height;
    
    return (CGSize){
        self.collectionView.bounds.size.width,
        MIN(requiredHeight, self.collectionView.bounds.size.height)
    };
}

- (void)prepareLayout {
    [self buildLayout];
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
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Header cells.
    for (UICollectionViewLayoutAttributes *attributes in self.supplementaryLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    // Item cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    
    return [self.indexPathSupplementaryAttributes objectForKey:indexPath];
}

#pragma mark - Private methods

- (void)buildLayout {
    self.commentsSize = [NSMutableDictionary dictionary];
    self.commentsIndexLayout = [NSMutableDictionary dictionary];
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    
    
    
}

- (CGFloat)verticalOffsetForCommentIndex:(NSUInteger)commentIndex {
    CGFloat offset = [ModalOverlayHeaderView unitSize].height;
    
    for (NSUInteger index = 0; index < commentIndex; index++) {
        CKRecipeComment *comment = [self.delegate recipeSocialLayoutCommentAtIndex:index];
        CGSize size = [RecipeSocialCommentCell sizeForComment:comment];
        offset += size.height + kRowGap;
    }
    
    return offset;
}

@end
