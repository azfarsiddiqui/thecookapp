//
//  RecipeListViewController.h
//  recipe
//
//  Created by Jonny Sagorin on 9/25/12.
//  Copyright (c) 2012 Cook Pty Ltd. All rights reserved.
//  A list of the current logged-in user's recipes

#import <Foundation/Foundation.h>
#import "CKBook.h"
#import "BookViewController.h"
@interface RecipeListViewController : UIViewController
@property(nonatomic,strong) CKBook *book;
@property(nonatomic,assign) id<BookViewDelegate> bookViewDelegate;
@end
