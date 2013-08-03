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

@end


@interface BookTitleViewController : BookPageViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookTitleViewControllerDelegate>)delegate;
- (void)configurePages:(NSArray *)pages;
- (void)configureHeroRecipe:(CKRecipe *)recipe;

@end
