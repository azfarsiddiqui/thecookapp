//
//  BookViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"
#import "CKRecipe.h"

@class BookViewController;

@protocol BookViewControllerDelegate

- (void)bookViewControllerCloseRequested;

@end

@protocol BookViewDelegate

- (void)bookViewCloseRequested;
- (void)contentViewRequested;
- (CGRect)bookViewBounds;
- (UIEdgeInsets)bookViewInsets;
- (BookViewController *)bookViewController;
- (void)bookViewReloadRequested;

@end

@protocol BookViewDataSource

- (CKBook *)currentBook;
- (CKRecipe *)currentRecipe;
- (NSInteger)numberOfPages;
- (UIView*)viewForPageAtIndex:(NSInteger) pageIndex;
- (NSArray *)bookRecipes;
- (NSArray *)bookCategories;
- (NSArray *)recipesForCategory:(NSString *)category;
- (NSInteger)currentPageNumber;
- (NSString *)bookViewCurrentCategory;
- (NSInteger)numRecipesInCategory:(NSString *)category;

@end

@interface BookViewController : UIViewController

- (id)initWithBook:(CKBook*)book delegate:(id<BookViewControllerDelegate>)delegate;

@end
