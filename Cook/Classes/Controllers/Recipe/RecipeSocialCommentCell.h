//
//  RecipeSocialCommentsCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKEditingViewHelper.h"

@class CKUser;
@class CKRecipeComment;
@class RecipeSocialCommentCell;

@protocol RecipeSocialCommentCellDelegate <NSObject>

- (void)recipeSocialCommentCellEditForCell:(RecipeSocialCommentCell *)commentCell editingView:(UIView *)editingView;

@end

@interface RecipeSocialCommentCell : UICollectionViewCell

@property (nonatomic, strong) CKEditingViewHelper *editingHelper;
@property (nonatomic, weak) id<RecipeSocialCommentCellDelegate> delegate;

+ (CGSize)sizeForComment:(CKRecipeComment *)comment;
+ (CGSize)unitSize;

- (void)configureWithComment:(CKRecipeComment *)comment;
- (void)configureAsPostCommentCellForUser:(CKUser *)user loading:(BOOL)loading;

@end
