//
//  BookSocialLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookSocialLayout.h"
#import "BookSocialHeaderView.h"
#import "CKSupplementaryContainerView.h"
#import "CKLikeView.h"
#import "ViewHelper.h"

@interface BookSocialLayout ()

@property (nonatomic, weak) id<BookSocialLayoutDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;

@end

@implementation BookSocialLayout

#define kContentInsets              (UIEdgeInsets){ 15.0, 20.0, 15.0, 20.0 }
#define kCommentHeaderHeight        100.0
#define kCommentFooterHeight        100.0
#define kCommentSideOffset          200.0
#define kCommentHeaderGap           0.0
#define kCommentGap                 0.0
#define kHeaderTotalDistanceFade    30.0

+ (NSInteger)commentsSection {
    return 0;
}

+ (NSInteger)likesSection {
    return 1;
}

- (id)initWithDelegate:(id<BookSocialLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    NSInteger numComments = [self.collectionView numberOfItemsInSection:[BookSocialLayout commentsSection]];
    CGFloat requiredHeight = kContentInsets.top;
    requiredHeight += kCommentHeaderHeight;
    requiredHeight += kCommentHeaderGap;
    
    // Loop through and figure out the height for each comment.
    for (NSInteger commentIndex = 0; commentIndex < numComments; commentIndex++) {
        requiredHeight += [self heightForCommentAtIndex:commentIndex];
        if (commentIndex != numComments - 1) {
            requiredHeight += kCommentGap;
        }
    }
    
    requiredHeight += kContentInsets.bottom;
    
    return (CGSize){
        self.collectionView.bounds.size.width,
        MAX(requiredHeight, self.collectionView.bounds.size.height)
    };
}

- (void)prepareLayout {
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    
    [self buildCommentsLayout];
    [self buildLikesLayout];
    
    // Inform end of layout prep.
    [self.delegate bookSocialLayoutDidFinish];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Header cells.
    for (UICollectionViewLayoutAttributes *attributes in self.supplementaryLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    // Item cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    [self applyPagingEffects:layoutAttributes];
    
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

- (void)buildCommentsLayout {
    
    // Comments title header.
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:[BookSocialLayout commentsSection]];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:[BookSocialHeaderView bookSocialHeaderKind] withIndexPath:headerIndexPath];
    attributes.frame = (CGRect){
        kCommentSideOffset,
        kContentInsets.top,
        self.collectionView.bounds.size.width - (kCommentSideOffset * 2),
        kCommentHeaderHeight
    };
    [self.supplementaryLayoutAttributes addObject:attributes];
    [self.indexPathSupplementaryAttributes setObject:attributes forKey:headerIndexPath];
    
    // Comments footer header.
    NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:1 inSection:[BookSocialLayout commentsSection]];
    UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:[CKSupplementaryContainerView bookSocialCommentBoxKind] withIndexPath:footerIndexPath];
    footerAttributes.frame = (CGRect){
        kCommentSideOffset,
        self.collectionView.bounds.size.height - kContentInsets.bottom - kCommentFooterHeight,
        self.collectionView.bounds.size.width - (kCommentSideOffset * 2),
        kCommentFooterHeight
    };
    [self.supplementaryLayoutAttributes addObject:footerAttributes];
    [self.indexPathSupplementaryAttributes setObject:footerAttributes forKey:headerIndexPath];
}

- (void)buildLikesLayout {
 
    // Likes header.
    CGSize headerSize = [CKLikeView likeSize];
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:[BookSocialLayout likesSection]];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:[CKSupplementaryContainerView bookSocialLikeKind] withIndexPath:headerIndexPath];
    attributes.frame = (CGRect){
        self.collectionView.bounds.size.width - kContentInsets.right - headerSize.width,
        kContentInsets.top,
        headerSize.width,
        headerSize.height
    };
    [self.supplementaryLayoutAttributes addObject:attributes];
    [self.indexPathSupplementaryAttributes setObject:attributes forKey:headerIndexPath];
    
}

- (CGFloat)heightForCommentAtIndex:(NSInteger)commentIndex {
    return 200.0;
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    
    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        
        // Fade the title header.
        if ([attributes.representedElementKind isEqualToString:[BookSocialHeaderView bookSocialHeaderKind]]) {
            [self applyScrollingEffects:attributes];
        } else if ([attributes.representedElementKind isEqualToString:[CKSupplementaryContainerView bookSocialCommentBoxKind]]) {
            [self applyStaticEffects:attributes offset:self.collectionView.bounds.size.height - kContentInsets.bottom - kCommentFooterHeight];
        } else if ([attributes.representedElementKind isEqualToString:[CKSupplementaryContainerView bookSocialLikeKind]]) {
            [self applyStaticEffects:attributes offset:kContentInsets.top];
        }
        
    }

}

- (void)applyScrollingEffects:(UICollectionViewLayoutAttributes *)attributes {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGRect headerFrame = attributes.frame;
    CGFloat distance = visibleFrame.origin.y - headerFrame.origin.y;
    CGFloat alpha = 1.0;
    if (distance <= kHeaderTotalDistanceFade) {
        CGFloat alphaRatio = distance / kHeaderTotalDistanceFade;
        alpha = 1.0 - alphaRatio;
    } else if (distance > kHeaderTotalDistanceFade) {
        alpha = 0.0;
    }
    
    attributes.alpha = MIN(alpha, 1.0);
    if (visibleFrame.origin.y < 0.0) {
        headerFrame.origin.y = visibleFrame.origin.y * 0.9;
    } else {
        // For some reason, only after setting frame will it fade??
        headerFrame.origin.y = visibleFrame.origin.y * 0.1;
    }
    
    attributes.frame = headerFrame;
}

- (void)applyStaticEffects:(UICollectionViewLayoutAttributes *)attributes offset:(CGFloat)offset {
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGRect headerFrame = attributes.frame;
    headerFrame.origin.y = visibleFrame.origin.y + offset;
    attributes.frame = headerFrame;
}

@end
