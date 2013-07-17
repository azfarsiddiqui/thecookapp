//
//  CKLikeView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 16/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@protocol CKLikeViewDelegate <NSObject>

- (void)likeViewLiked:(BOOL)liked;

@end

@interface CKLikeView : UIView

+ (CGSize)likeSize;

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<CKLikeViewDelegate>)delegate;
- (id)initWithRecipe:(CKRecipe *)recipe darkMode:(BOOL)dark delegate:(id<CKLikeViewDelegate>)delegate;

@end
