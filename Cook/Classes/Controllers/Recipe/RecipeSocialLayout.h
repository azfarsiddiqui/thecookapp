//
//  RecipeSocialLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 24/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipeComment;
@class CKRecipeLike;

@protocol RecipeSocialLayoutDelegate <NSObject>

- (void)recipeSocialLayoutDidFinish;
- (CKRecipeComment *)recipeSocialLayoutCommentAtIndex:(NSUInteger)commentIndex;
- (BOOL)recipeSocialLayoutIsLoading;

@end

@interface RecipeSocialLayout : UICollectionViewLayout

- (id)initWithDelegate:(id<RecipeSocialLayoutDelegate>)delegate;
- (void)setNeedsRelayout:(BOOL)relayout;

@end
