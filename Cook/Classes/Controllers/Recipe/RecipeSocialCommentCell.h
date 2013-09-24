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

@interface RecipeSocialCommentCell : UICollectionViewCell

+ (CGSize)sizeForComment:(CKRecipeComment *)comment;
+ (CGSize)unitSize;

- (void)configureWithComment:(CKRecipeComment *)comment commentIndex:(NSUInteger)commentIndex
                 numComments:(NSUInteger)numComments;
- (void)configureAsPostCommentCellForUser:(CKUser *)user loading:(BOOL)loading;

@end
