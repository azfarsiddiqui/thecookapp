//
//  RecipeCommentBoxFooterView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 24/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKUser;

@protocol RecipeCommentBoxFooterViewDelegate <NSObject>

- (void)recipeCommentBoxFooterViewCommentRequested;

@end

@interface RecipeCommentBoxFooterView : UICollectionReusableView

@property (nonatomic, weak) id<RecipeCommentBoxFooterViewDelegate> delegate;

+ (CGSize)unitSize;
- (void)configureUser:(CKUser *)user;

@end
