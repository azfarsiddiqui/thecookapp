//
//  RecipeLikeCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 28/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipeLike;
@class CKUser;

@protocol RecipeSocialLikeCellDelegate <NSObject>

- (void)recipeSocialLikeCellProfileRequestedForUser:(CKUser *)user;

@end

@interface RecipeLikeCell : UICollectionViewCell

@property (nonatomic, weak) id<RecipeSocialLikeCellDelegate> delegate;

- (void)configureLike:(CKRecipeLike *)like;

@end
