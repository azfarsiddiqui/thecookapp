//
//  CKLikeView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 16/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@interface CKLikeView : UIView

@property (nonatomic, assign) BOOL liked;
@property (nonatomic, assign) BOOL enabled;

+ (CGSize)likeSize;

- (id)initWithRecipe:(CKRecipe *)recipe;
- (id)initWithRecipe:(CKRecipe *)recipe darkMode:(BOOL)dark;
- (void)markAsLiked:(BOOL)liked;

@end
