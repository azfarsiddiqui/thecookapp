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

- (void)recipeSocialCommentCellCacheNameFrame:(CGRect)nameFrame commentIndex:(NSUInteger)commentIndex;
- (void)recipeSocialCommentCellCacheTimeFrame:(CGRect)timeFrame commentIndex:(NSUInteger)commentIndex;
- (void)recipeSocialCommentCellCacheCommentFrame:(CGRect)commentFrame commentIndex:(NSUInteger)commentIndex;
- (CGRect)recipeSocialCommentCellCachedNameFrameForCommentIndex:(NSUInteger)commentIndex;
- (CGRect)recipeSocialCommentCellCachedTimeFrameForCommentIndex:(NSUInteger)commentIndex;
- (CGRect)recipeSocialCommentCellCachedCommentFrameForCommentIndex:(NSUInteger)commentIndex;

@end

@interface RecipeSocialCommentCell : UICollectionViewCell

@property (nonatomic, weak) id<RecipeSocialCommentCellDelegate> delegate;

+ (CGSize)sizeForComment:(CKRecipeComment *)comment;
+ (CGSize)unitSize;

- (void)configureWithComment:(CKRecipeComment *)comment commentIndex:(NSUInteger)commentIndex
                 numComments:(NSUInteger)numComments;
- (void)configureAsPostCommentCellForUser:(CKUser *)user loading:(BOOL)loading;

@end
