//
//  GridRecipeActionsView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@interface GridRecipeStatsView : UIView

- (id)initWithWidth:(CGFloat)width;
- (void)configureRecipe:(CKRecipe *)recipe;

@end
