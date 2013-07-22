//
//  BookTitleViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookPageViewController.h"

@class CKBook;
@class CKCategory;
@class CKRecipe;

@protocol BookTitleViewControllerDelegate <NSObject>

- (CKRecipe *)bookTitleFeaturedRecipeForCategory:(CKCategory *)category;
- (void)bookTitleSelectedCategory:(CKCategory *)category;

@end


@interface BookTitleViewController : BookPageViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookTitleViewControllerDelegate>)delegate;
- (void)configureCategories:(NSArray *)categories;
- (void)configureHeroRecipe:(CKRecipe *)recipe;

@end
