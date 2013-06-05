//
//  RecipeCollectionViewCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;
@class CKBook;

@interface BookRecipeCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) CKRecipe *recipe;

- (CGSize)imageSize;
- (void)configureRecipe:(CKRecipe *)recipe book:(CKBook *)book;
- (void)configureImage:(UIImage *)image;

@end
