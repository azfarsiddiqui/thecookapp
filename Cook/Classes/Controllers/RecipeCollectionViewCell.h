//
//  RecipeCollectionViewCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@interface RecipeCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) CKRecipe *recipe;

- (void)configureRecipe:(CKRecipe *)recipe;
- (void)updateImage;

@end
