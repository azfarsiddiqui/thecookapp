//
//  ContentsPhotoCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKRecipe.h"

@interface ContentsPhotoCell : UICollectionViewCell

- (void)loadRecipe:(CKRecipe *)recipe;

+ (CGSize)cellSize;
+ (CGSize)minSize;
+ (CGSize)midSize;
+ (CGSize)maxSize;

@end
