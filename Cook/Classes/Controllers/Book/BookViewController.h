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
- (void)requestedPageIndex:(NSUInteger)pageIndex;
- (void)contentViewRequested;
- (CGRect)bookViewBounds;
- (UIEdgeInsets)bookViewInsets;
- (BookViewController *)bookViewController;
- (void)bookViewReloadRequested;

@end

@protocol BookViewDataSource

//context-related
- (CKRecipe *)currentRecipe;
- (CKBook *)currentBook;
- (NSInteger)currentPageNumber;

//book or recipe-related
- (NSInteger)numberOfPages;
- (UIView*)viewForPageAtIndex:(NSUInteger) pageIndex;
- (NSArray*)recipesInBook;
- (NSInteger)pageNumForRecipe:(CKRecipe*)recipe;

//page-content
- (NSUInteger)sectionsInPageContent;
- (NSString*)sectionNameForPageContentAtIndex:(NSUInteger)sectionIndex;
- (NSUInteger)pageNumForSectionName:(NSString *)sectionName;

//category-related
- (NSInteger)numRecipesInCategory:(NSString *)category;
- (NSInteger)pageNumForRecipeAtCategoryIndex:(NSInteger)recipeIndex forCategoryName:(NSString *)categoryName;
- (NSArray *)recipesForCategory:(NSString *)categoryName;
- (NSInteger)pageNumForCategoryName:(NSString*)categoryName;

@end

@interface BookViewController : UIViewController

- (id)initWithBook:(CKBook*)book delegate:(id<BookViewControllerDelegate>)delegate;

@end
