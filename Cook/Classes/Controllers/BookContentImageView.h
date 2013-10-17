//
//  BookCategoryImageView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;
@class CKRecipe;

@interface BookContentImageView : UICollectionReusableView

@property BOOL isFullLoad;

- (void)configureImage:(UIImage *)image placeholder:(BOOL)placeholder book:(CKBook *)book;
- (void)configureFeaturedRecipe:(CKRecipe *)recipe book:(CKBook *)book;
- (void)applyOffset:(CGFloat)offset;
- (CGSize)imageSizeWithMotionOffset;
- (void)reloadWithBook:(CKBook *)book;

@end
