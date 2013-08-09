//
//  RecipeIngredientsView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@interface RecipeIngredientsView : UIView

- (id)initWithRecipe:(CKRecipe *)recipe maxWidth:(CGFloat)maxWidth;

@end
