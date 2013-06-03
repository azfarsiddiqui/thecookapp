//
//  BookIndexListViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 3/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;
@class CKRecipe;

@protocol BookIndexListViewControllerDelegate

- (void)bookIndexSelectedCategory:(NSString *)category;
- (void)bookIndexAddRecipeRequested;
- (NSArray *)bookIndexRecipesForCategory:(NSString *)category;

@end

@interface BookIndexListViewController : UIViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookIndexListViewControllerDelegate>)delegate;
- (void)configureHeroRecipe:(CKRecipe *)recipe;
- (void)configureCategories:(NSArray *)categories;

@end
