//
//  BookContentGridLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CKRecipe;

typedef NS_ENUM(NSUInteger, RecipeGridType) {
    RecipeGridTypeExtraSmall,
    RecipeGridTypeSmall,
    RecipeGridTypeMedium,
    RecipeGridTypeLarge
};

@protocol RecipeGridLayoutDelegate <NSObject>

- (void)recipeGridLayoutDidFinish;
- (NSInteger)recipeGridLayoutNumItems;
- (RecipeGridType)recipeGridTypeForItemAtIndex:(NSInteger)itemIndex;
- (CGSize)recipeGridLayoutHeaderSize;
- (CGSize)recipeGridLayoutFooterSize;
- (CGFloat)recipeGridCellsOffset;
- (BOOL)recipeGridLayoutHeaderEnabled;
- (BOOL)recipeGridLayoutLoadMoreEnabled;
- (BOOL)recipeGridLayoutDisabled;

@optional
- (CGFloat)recipeGridInitialOffset;
- (CGFloat)recipeGridFinalOffset;

@end

@interface RecipeGridLayout : UICollectionViewLayout

@property (nonatomic, weak) id<RecipeGridLayoutDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *itemsLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathItemAttributes;
@property (nonatomic, strong) NSMutableArray *supplementaryLayoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *indexPathSupplementaryAttributes;

+ (CGSize)sizeForBookContentGridType:(RecipeGridType)gridType;
+ (RecipeGridType)gridTypeForRecipe:(CKRecipe *)recipe;
+ (NSString *)cellIdentifierForGridType:(RecipeGridType)gridType;
- (id)initWithDelegate:(id<RecipeGridLayoutDelegate>)delegate;
- (void)setNeedsRelayout:(BOOL)relayout;
- (UICollectionViewLayoutAttributes *)headerLayoutAttributesForIndexPath:(NSIndexPath *)headerIndexPath;
- (void)applyPagingEffects:(NSArray *)layoutAttributes;
- (void)applyHeaderPagingEffects:(UICollectionViewLayoutAttributes *)attributes;

@end
