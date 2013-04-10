//
//  RecipeViewController.h
//  RecipeViewPrototype
//
//  Created by Jeff Tan-Ang on 9/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@interface RecipeViewController : UIViewController

- (id)initWithRecipe:(CKRecipe *)recipe;

@end
