//
//  RecipeIngredientsView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeIngredientsView : UIView

- (id)initWithIngredients:(NSArray *)ingredients maxWidth:(CGFloat)maxWidth;
- (void)updateIngredients:(NSArray *)ingredients;

@end
