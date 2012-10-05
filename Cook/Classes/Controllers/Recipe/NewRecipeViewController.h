//
//  NewRecipeViewController.h
//  recipe
//
//  Created by Jonny Sagorin on 10/2/12.
//  Copyright (c) 2012 Cook Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CKBook.h"

@protocol NewRecipeViewDelegate
-(void)closeRequested;
-(void)recipeCreated;
@end

@interface NewRecipeViewController : UIViewController
@property(nonatomic,assign) id<NewRecipeViewDelegate> delegate;
@property(nonatomic,strong) CKBook *book;
@end
