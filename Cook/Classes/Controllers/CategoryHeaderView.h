//
//  CategoryHeaderView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@interface CategoryHeaderView : UICollectionReusableView

@property (nonatomic, strong) NSString *categoryName;

- (void)configureCategoryName:(NSString *)categoryName;
- (void)configureImage:(UIImage *)image;
- (void)configureImageForRecipe:(CKRecipe *)recipe;
- (CGSize)imageSize;

@end
