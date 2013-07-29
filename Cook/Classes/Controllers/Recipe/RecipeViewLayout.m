//
//  RecipeViewLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeViewLayout.h"
#import "RecipeShadowView.h"
#import "ViewHelper.h"

@interface RecipeViewLayout ()

@property (nonatomic, weak) id<RecipeViewLayoutDelegate> delegate;
@property (nonatomic, assign) BOOL layoutCompleted;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;
@property (nonatomic, strong) NSMutableArray *decorationLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathDecorationAttributes;

@end

@implementation RecipeViewLayout

#define kDetailInsets               (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define kHeaderDetailGap            0.0
#define kDetailLeftColumnDividerGap 40.0
#define kDetailLeftColumnWidth      255.0
#define kDetailColumnsSeparator     10.0
#define kDetailRightColumnWidth     420.0
#define kServesZIndex               1
#define kLeftColumnSepZIndex        2
#define kIngredientsZIndex          3
#define kMethodZIndex               4
#define kTopShadowZIndex            5
#define kHeaderZIndex               6

- (id)initWithDelegate:(id<RecipeViewLayoutDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        
        // Register shadow.
        [self registerClass:[RecipeShadowView class] forDecorationViewOfKind:[RecipeShadowView decorationKind]];
    }
    return self;
}

#pragma mark - UICollectionViewLayout methods

- (CGSize)collectionViewContentSize {
    CGSize contentSize = (CGSize){ self.collectionView.bounds.size.width, 0.0 };
    
    // Detail column sizes.
    CGSize servesSize = [self.delegate recipeViewServesTimeViewSize];
    CGSize ingredientsSize = [self.delegate recipeViewIngredientsViewSize];
    CGSize methodSize = [self.delegate recipeViewMethodSize];
    
    // Compute the required height.
    contentSize.height += [self.delegate recipeViewHeaderSize].height;
    contentSize.height += kHeaderDetailGap;
    contentSize.height += kDetailInsets.top;
    contentSize.height += MAX((servesSize.height + kDetailLeftColumnDividerGap + ingredientsSize.height), methodSize.height);
    contentSize.height += kDetailInsets.bottom;
    
    return contentSize;
}

- (void)prepareLayout {
    
    // Skip if layout does not need to be regenerated.
    if (self.layoutCompleted) {
        return;
    }
    
    self.itemsLayoutAttributes = [NSMutableArray array];
    self.supplementaryLayoutAttributes = [NSMutableArray array];
    self.decorationLayoutAttributes = [NSMutableArray array];
    self.indexPathItemAttributes = [NSMutableDictionary dictionary];
    self.indexPathSupplementaryAttributes = [NSMutableDictionary dictionary];
    self.indexPathDecorationAttributes = [NSMutableDictionary dictionary];
    
    [self buildHeaderLayout];
    [self buildDetailItemsLayout];
    [self buildDecorationsLayout];
    
    // Mark layout as generated.
    self.layoutCompleted = YES;
    
    // Inform end of layout prep.
    [self.delegate recipeViewLayoutDidFinish];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* layoutAttributes = [NSMutableArray array];
    
    // Header.
    for (UICollectionViewLayoutAttributes *attributes in self.supplementaryLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    // Detail cells.
    for (UICollectionViewLayoutAttributes *attributes in self.itemsLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    // Decoration cells.
    for (UICollectionViewLayoutAttributes *attributes in self.decorationLayoutAttributes) {
        [layoutAttributes addObject:attributes];
    }
    
    // Apply transform for paging.
    [self applyPagingEffects:layoutAttributes];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathItemAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind
                                                                  atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathDecorationAttributes objectForKey:indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath {
    return [self.indexPathSupplementaryAttributes objectForKey:indexPath];
}

#pragma mark - Private methods

- (void)buildHeaderLayout {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    
    CGSize headerSize = [self.delegate recipeViewHeaderSize];
    attributes.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - headerSize.width) / 2.0),
        self.collectionView.bounds.origin.y,
        headerSize.width,
        headerSize.height
    };
    attributes.zIndex = kHeaderZIndex;
    
    [self.itemsLayoutAttributes addObject:attributes];
    [self.indexPathItemAttributes setObject:attributes forKey:indexPath];
}

- (void)buildDetailItemsLayout {
    
    // Header as reference.
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *headerAttributes = [self.indexPathSupplementaryAttributes objectForKey:headerIndexPath];
    
    // Details width.
    CGFloat detailsWidth = kDetailLeftColumnWidth + kDetailColumnsSeparator + kDetailRightColumnWidth;
    
    // Serves
    NSIndexPath *servesIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *servesAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:servesIndexPath];
    CGSize servesSize = [self.delegate recipeViewServesTimeViewSize];
    servesAttributes.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - detailsWidth) / 2.0),
        headerAttributes.frame.origin.y + headerAttributes.frame.size.height + kHeaderDetailGap,
        servesSize.width,
        servesSize.height
    };
    servesAttributes.zIndex = kServesZIndex;
    [self.itemsLayoutAttributes addObject:servesAttributes];
    [self.indexPathItemAttributes setObject:servesAttributes forKey:servesIndexPath];
    
    // Ingredients
    NSIndexPath *ingredientsIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    UICollectionViewLayoutAttributes *ingredientsAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:ingredientsIndexPath];
    CGSize ingredientsSize = [self.delegate recipeViewIngredientsViewSize];
    ingredientsAttributes.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - detailsWidth) / 2.0),
        servesAttributes.frame.origin.y + servesAttributes.frame.size.height + kDetailLeftColumnDividerGap,
        ingredientsSize.width,
        ingredientsSize.height
    };
    ingredientsAttributes.zIndex = kIngredientsZIndex;
    [self.itemsLayoutAttributes addObject:ingredientsAttributes];
    [self.indexPathItemAttributes setObject:ingredientsAttributes forKey:ingredientsIndexPath];
    
    // Method
    NSIndexPath *methodIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    UICollectionViewLayoutAttributes *methodAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:methodIndexPath];
    CGSize methodSize = [self.delegate recipeViewMethodSize];
    methodAttributes.frame = (CGRect){
        floorf((self.collectionView.bounds.size.width - detailsWidth) / 2.0) + kDetailLeftColumnWidth + kDetailColumnsSeparator,
        headerAttributes.frame.origin.y + headerAttributes.frame.size.height + kHeaderDetailGap,
        methodSize.width,
        methodSize.height
    };
    methodAttributes.zIndex = kMethodZIndex;
    [self.itemsLayoutAttributes addObject:methodAttributes];
    [self.indexPathItemAttributes setObject:methodAttributes forKey:methodIndexPath];
}

- (void)buildDecorationsLayout {
    
    // Header as reference.
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *headerAttributes = [self.indexPathSupplementaryAttributes objectForKey:headerIndexPath];
    
    // Top shadow.
    NSIndexPath *shadowIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *shadowAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[RecipeShadowView decorationKind] withIndexPath:shadowIndexPath];
    shadowAttributes.frame = (CGRect){
        self.collectionView.bounds.origin.x,
        headerAttributes.frame.origin.y + headerAttributes.frame.size.height + kHeaderDetailGap,
        self.collectionView.bounds.size.width,
        [RecipeShadowView imageSize].height
    };
    shadowAttributes.zIndex = kTopShadowZIndex;
    [self.decorationLayoutAttributes addObject:shadowAttributes];
    [self.indexPathDecorationAttributes setObject:shadowAttributes forKey:shadowIndexPath];
}

- (void)applyPagingEffects:(NSArray *)layoutAttributes {
    
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    
    // Fixed the header.
    NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *headerAttributes = [self.indexPathSupplementaryAttributes objectForKey:headerIndexPath];
    CGRect headerFrame = headerAttributes.frame;
    headerFrame.origin.y = visibleFrame.origin.y;
    headerAttributes.frame = headerFrame;
    
    // Fixed the top shadow.
    NSIndexPath *shadowIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *shadowAttributes = [self.indexPathDecorationAttributes objectForKey:shadowIndexPath];
    CGRect shadowFrame = shadowAttributes.frame;
    shadowFrame.origin.y = visibleFrame.origin.y;
    shadowAttributes.frame = shadowFrame;
    
    // Fade the shadow.
    if (visibleFrame.origin.y < 0) {
        CGFloat fadeDistance = 10.0;
        CGFloat distanceTravelled = MIN(-visibleFrame.origin.y, fadeDistance);
        shadowAttributes.alpha = distanceTravelled / fadeDistance;
    }
    
}

@end
