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

- (void)bookContentsSelectedCategory:(NSString *)category;
- (void)bookContentsAddRecipeRequested;

@end

@interface BookIndexViewController : UIViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookIndexViewControllerDelegate>)delegate;
- (void)configureCategories:(NSArray *)categories;

@end
