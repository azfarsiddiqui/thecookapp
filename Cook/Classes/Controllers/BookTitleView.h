//
//  BookTitleView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@interface BookTitleView : UICollectionReusableView

+ (CGSize)headerSize;
+ (CGSize)heroImageSize;
- (void)configureBook:(CKBook *)book;
- (void)configureImage:(UIImage *)image;

@end
