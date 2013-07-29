//
//  RecipeViewLayout.h
//  Cook
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecipeViewLayoutDelegate <NSObject>

- (CGSize)recipeViewHeaderSize;
- (CGSize)recipeViewServesTimeViewSize;
- (CGSize)recipeViewIngredientsViewSize;
- (CGSize)recipeViewMethodSize;
- (void)recipeViewLayoutDidFinish;

@end

@interface RecipeViewLayout : UICollectionViewLayout

- (id)initWithDelegate:(id<RecipeViewLayoutDelegate>)delegate;

@end
