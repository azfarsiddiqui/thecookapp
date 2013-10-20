//
//  AddRecipeViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"

@class CKBook;
@class CKRecipe;
@class CKRecipePin;

@protocol PinRecipeViewControllerDelegate <NSObject>

- (void)pinRecipeViewControllerCloseRequested;
- (void)pinRecipeViewControllerPinnedWithRecipePin:(CKRecipePin *)recipePin;

@end

@interface PinRecipeViewController : OverlayViewController

- (id)initWithRecipe:(CKRecipe *)recipe book:(CKBook *)book delegate:(id<PinRecipeViewControllerDelegate>)delegate;

@end
