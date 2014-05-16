//
//  BookRecipeGridCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;
@class CKRecipePin;
@class CKBook;
@class GridRecipeStatsView;
@class RecipeIngredientsView;
@class CKActivityIndicatorView;
@class CKUserProfilePhotoView;

@interface BookRecipeGridCell : UICollectionViewCell

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, strong) CKRecipePin *recipePin;

@property (nonatomic, strong) UIImageView *cellBackgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CKUserProfilePhotoView *profilePhotoView;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) UIImageView *topRoundedMaskImageView;
@property (nonatomic, strong) UIImageView *bottomShadowImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeIntervalLabel;
@property (nonatomic, strong) UIImageView *privacyIconView;
@property (nonatomic, strong) UILabel *storyLabel;
@property (nonatomic, strong) UILabel *methodLabel;
@property (nonatomic, strong) RecipeIngredientsView *ingredientsView;
@property (nonatomic, strong) GridRecipeStatsView *statsView;

+ (CGSize)imageSize;
- (void)configureRecipe:(CKRecipe *)recipe book:(CKBook *)book;
- (void)configureRecipe:(CKRecipe *)recipe book:(CKBook *)book own:(BOOL)own;
- (void)configureRecipe:(CKRecipe *)recipe book:(CKBook *)book own:(BOOL)own displayDate:(NSDate *)displayDate;
- (void)configureRecipePin:(CKRecipePin *)recipePin book:(CKBook *)book;
- (void)configureRecipePin:(CKRecipePin *)recipePin book:(CKBook *)book own:(BOOL)own;


- (void)updateImageView;
- (void)updateProfilePhoto;
- (void)updateStats;
- (void)updateTitle;
- (void)updateTimeInterval;
- (void)updateStory;
- (void)updateMethod;
- (void)updateIngredients;
- (void)updatePrivacyIcon;

- (UIEdgeInsets)contentInsets;
- (CGSize)availableSize;
- (CGSize)availableBlockSize;

- (BOOL)hasPhotos;
- (BOOL)hasTitle;
- (BOOL)hasStory;
- (BOOL)hasMethod;
- (BOOL)hasIngredients;
- (BOOL)multilineTitle;

- (NSInteger)maxStoryLines;
- (NSInteger)maxMethodLines;

- (CGRect)centeredFrameBetweenView:(UIView *)fromView andView:(UIView *)toView forView:(UIView *)forView;

@end
