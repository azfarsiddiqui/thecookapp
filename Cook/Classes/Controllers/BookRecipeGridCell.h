//
//  BookRecipeGridCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;
@class CKBook;
@class GridRecipeStatsView;
@class RecipeIngredientsView;

@interface BookRecipeGridCell : UICollectionViewCell

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *recipe;

@property (nonatomic, strong) UIImageView *cellBackgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIImageView *topRoundedMaskImageView;
@property (nonatomic, strong) UIImageView *bottomShadowImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) UILabel *methodLabel;
@property (nonatomic, strong) RecipeIngredientsView *ingredientsView;

@property (nonatomic, strong) UIImageView *dividerImageView;
@property (nonatomic, strong) UIImageView *dividerQuoteImageView;
@property (nonatomic, strong) UILabel *ingredientsEllipsisLabel;
@property (nonatomic, strong) GridRecipeStatsView *statsView;

+ (CGSize)imageSize;
- (void)configureRecipe:(CKRecipe *)recipe book:(CKBook *)book;
- (void)configureImage:(UIImage *)image;

- (void)updateImageView;
- (void)updateStats;
- (void)updateTitle;
- (void)updateStory;
- (void)updateMethod;
- (void)updateIngredients;

- (UIEdgeInsets)contentInsets;
- (CGSize)availableSize;
- (CGSize)availableBlockSize;

- (BOOL)hasTitle;
- (BOOL)hasStory;
- (BOOL)hasMethod;
- (BOOL)hasIngredients;

@end
