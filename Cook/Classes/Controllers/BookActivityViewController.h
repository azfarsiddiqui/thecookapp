//
//  BookActivityViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 28/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;
@class CKRecipe;

@protocol BookActivityViewControllerDelegate

- (void)bookActivityViewControllerSelectedRecipe:(CKRecipe *)recipe;

@end

@interface BookActivityViewController : UIViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookActivityViewControllerDelegate>)delegate;

@end
