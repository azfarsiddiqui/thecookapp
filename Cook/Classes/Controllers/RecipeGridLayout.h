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

@end

@interface RecipeGridLayout : UICollectionViewLayout

+ (CGSize)sizeForBookContentGridType:(RecipeGridType)gridType;
+ (RecipeGridType)gridTypeForRecipe:(CKRecipe *)recipe;
- (id)initWithDelegate:(id<RecipeGridLayoutDelegate>)delegate;
- (void)setNeedsRelayout:(BOOL)relayout;

@end
