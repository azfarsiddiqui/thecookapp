//
//  BookCategoryImageView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookCategoryImageView : UICollectionReusableView

- (void)configureImage:(UIImage *)image;
- (void)configureImage:(UIImage *)image placeholder:(BOOL)placeholder;
- (void)applyOffset:(CGFloat)offset;

@end
