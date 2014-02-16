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

- (CKRecipe *)bookTitleFeaturedRecipeForPage:(NSString *)page;
- (NSInteger)bookTitleNumRecipesForPage:(NSString *)page;
- (void)bookTitleSelectedPage:(NSString *)page;
- (void)bookTitleUpdatedOrderOfPages:(NSArray *)pages;
- (void)bookTitleAddedPage:(NSString *)page;
- (BOOL)bookTitleIsNewForPage:(NSString *)page;
- (BOOL)bookTitleHasLikes;
- (void)bookTitleProfileRequested;

@end


@interface BookTitleViewController : BookPageViewController

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, weak) id<BookTitleViewControllerDelegate> delegate;

- (id)initWithBook:(CKBook *)book delegate:(id<BookTitleViewControllerDelegate>)delegate;
- (void)configureLoading:(BOOL)loading;
- (void)configureError:(NSError *)error;
- (void)configurePages:(NSArray *)pages;
- (void)configureHeroRecipe:(CKRecipe *)recipe;
- (void)refresh;
- (void)didScrollToProfile;

@end
