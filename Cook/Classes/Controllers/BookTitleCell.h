//
//  BookTitleCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKCategory;

@interface BookTitleCell : UICollectionViewCell

+ (CGSize)cellSize;

- (void)configureCategory:(CKCategory *)category;
- (void)configureImage:(UIImage *)image;

@end
