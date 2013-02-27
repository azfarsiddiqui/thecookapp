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

@interface BookContentsViewController : UIViewController

- (id)initWithBook:(CKBook *)book;
- (void)configureCategories:(NSArray *)categories;
- (void)configureRecipe:(CKRecipe *)recipe;

@end
