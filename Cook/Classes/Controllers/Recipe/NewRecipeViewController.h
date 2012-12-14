//
//  NewRecipeViewController.h
//  recipe
//
//  Created by Jonny Sagorin on 10/2/12.
//  Copyright (c) 2012 Cook Pty Ltd. All rights reserved.
//
//TODO: this class to be removed and replaced by RecipeViewController in a new state

#import <UIKit/UIKit.h>

#import "CKBook.h"
#import "PageViewController.h"

@protocol NewRecipeViewDelegate
-(void)closeRequested;
-(void)recipeCreated;
@end

@interface NewRecipeViewController : UIViewController
@property(nonatomic,assign) id<NewRecipeViewDelegate> recipeViewDelegate;
@property(nonatomic,strong) CKBook *book;
@end
