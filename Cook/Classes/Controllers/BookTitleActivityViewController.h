//
//  BookTitleViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 19/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;
@class CKRecipe;

@protocol BookTitleActivityViewControllerDelegate <NSObject>

- (void)bookTitleViewControllerSelectedRecipe:(CKRecipe *)recipe;

@end

@interface BookTitleActivityViewController : UIViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookTitleActivityViewControllerDelegate>)delegate;
- (void)configureHeroRecipe:(CKRecipe *)recipe;

@end
