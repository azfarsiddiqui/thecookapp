//
//  BookCategoryViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookPageViewController.h"

@class CKBook;
@class CKCategory;
@class CKRecipe;

@protocol BookCategoryViewControllerDelegate <NSObject>

- (NSArray *)recipesForBookCategoryViewControllerForCategory:(CKCategory *)category;
- (CKRecipe *)featuredRecipeForBookCategoryViewControllerForCategory:(CKCategory *)category;

@end

@interface BookCategoryViewController : BookPageViewController

- (id)initWithBook:(CKBook *)book category:(CKCategory *)category delegate:(id<BookCategoryViewControllerDelegate>)delegate;
- (void)loadData;

@end
