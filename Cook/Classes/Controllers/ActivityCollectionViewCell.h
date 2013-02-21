//
//  ActivityCollectionViewCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKActivity;

@interface ActivityCollectionViewCell : UICollectionViewCell

+ (CGSize)cellSize;
+ (CGSize)imageSize;

- (void)configureActivity:(CKActivity *)activity;
- (void)configureImage:(UIImage *)image;

@end
