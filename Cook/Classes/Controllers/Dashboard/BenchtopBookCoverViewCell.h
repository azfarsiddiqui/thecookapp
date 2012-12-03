//
//  BenchtopCell.h
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"
#import "CKBookCoverView.h"

@interface BenchtopBookCoverViewCell : UICollectionViewCell

@property (nonatomic, strong) CKBookCoverView *bookCoverView;

+ (CGSize)cellSize;

- (void)loadBook:(CKBook *)book;

@end
