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

@protocol BookIndexViewControllerDelegate

- (void)bookIndexSelectedCategory:(NSString *)category;
- (void)bookIndexAddRecipeRequested;
- (NSArray *)bookIndexRecipesForCategory:(NSString *)category;

@end

@interface BookIndexViewController : UICollectionViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookIndexViewControllerDelegate>)delegate;
- (void)configureCategories:(NSArray *)categories;

@end
