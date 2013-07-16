//
//  CKRecipeSocialView.h
//  CKRecipeSocialViewDemo
//
//  Created by Jeff Tan-Ang on 10/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;
@class CKRecipeSocialView;

@protocol CKRecipeSocialViewDelegate

- (void)recipeSocialViewTapped;
- (void)recipeSocialViewUpdated:(CKRecipeSocialView *)socialView;

@end

@interface CKRecipeSocialView : UIView

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<CKRecipeSocialViewDelegate>)delegate;
- (void)incrementLike:(BOOL)increment;

@end
