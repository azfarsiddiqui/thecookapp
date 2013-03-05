//
//  BookContentsViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;
@class CKRecipe;

@protocol BookContentsViewControllerDelegate

- (void)bookContentsSelectedCategory:(NSString *)category;
- (void)bookContentsAddRecipeRequested;

@end

@interface BookContentsViewController : UIViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookContentsViewControllerDelegate>)delegate;
- (void)configureCategories:(NSArray *)categories;
- (void)configureHeroRecipe:(CKRecipe *)recipe;

@end
