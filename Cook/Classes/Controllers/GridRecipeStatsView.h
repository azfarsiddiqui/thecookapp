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

- (void)reset;
- (void)configureRecipe:(CKRecipe *)recipe;
- (void)configureIcon:(NSString *)iconName value:(NSString *)value;
- (UIColor *)textColour;
- (UIColor *)shadowColour;
- (CGSize)shadowOffset;

@end
