//
//  StoreBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchtopBookCoverViewCell.h"
#import "CKBook.h"

@protocol StoreBookCoverViewCellDelegate <BenchtopBookCoverViewCellDelegate>

- (void)storeBookFollowTappedForCell:(UICollectionViewCell *)cell;

@end

@interface StoreBookCoverViewCell : BenchtopBookCoverViewCell

@property (nonatomic, weak) id<StoreBookCoverViewCellDelegate> delegate;

+ (CGSize)cellSize;
- (void)loadBookCoverImage:(UIImage *)bookCoverImage status:(BookStatus)bookStatus;
- (void)updateBookStatus:(BookStatus)bookStatus;

@end
