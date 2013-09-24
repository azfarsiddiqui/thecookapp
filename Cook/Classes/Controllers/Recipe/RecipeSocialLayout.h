//
//  RecipeSocialLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 24/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipeComment;

@protocol RecipeSocialLayoutDelegate <NSObject>

- (CKRecipeComment *)recipeSocialLayoutCommentAtIndex:(NSUInteger)commentIndex;

@end

@interface RecipeSocialLayout : UICollectionViewLayout

- (id)initWithDelegate:(id<RecipeSocialLayoutDelegate>)delegate;

@end
