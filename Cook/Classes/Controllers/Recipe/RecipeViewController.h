//
//  RecipeViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 10/12/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"
#import "PageViewController.h"
#import "CKRecipe.h"
#import "CKBook.h"
@interface RecipeViewController : PageViewController
@property(nonatomic,strong) CKRecipe *recipe;
@property(nonatomic,strong) CKBook *book;
          
@end
