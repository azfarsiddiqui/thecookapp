//
//  BookTitleCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@interface BookTitleCell : UICollectionViewCell

+ (CGSize)cellSize;

- (void)configurePage:(NSString *)page numRecipes:(NSInteger)numRecipes containNewRecipes:(BOOL)newRecipes book:(CKBook *)book;
- (void)configureImage:(UIImage *)image;
- (void)configureAsAddCellForBook:(CKBook *)book;

@end
