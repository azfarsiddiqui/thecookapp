//
//  RecipeLikeCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 28/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipeLike;

@interface RecipeLikeCell : UICollectionViewCell

- (void)configureLike:(CKRecipeLike *)like;

@end
