//
//  StoreBookCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchtopBookCoverViewCell.h"

@protocol StoreBookCoverViewCellDelegate <BenchtopBookCoverViewCellDelegate>

- (void)storeBookFollowTappedForCell:(UICollectionViewCell *)cell;

@end

@interface StoreBookCoverViewCell : BenchtopBookCoverViewCell

@property (nonatomic, assign) id<StoreBookCoverViewCellDelegate> delegate;

+ (CGSize)cellSize;
- (void)loadBookCoverImage:(UIImage *)bookCoverImage followed:(BOOL)followed;

@end
