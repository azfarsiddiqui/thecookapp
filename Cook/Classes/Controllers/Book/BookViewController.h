//
//  BookViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"

@class BookViewController;

@protocol BookViewControllerDelegate

- (void)bookViewControllerCloseRequested;

@end

@protocol BookViewDelegate

- (void)bookViewCloseRequested;
- (CGRect)bookViewBounds;
- (UIEdgeInsets)bookViewInsets;
- (BookViewController *)bookViewController;

@end

@protocol BookViewDataSource

- (CKBook *)currentBook;
- (NSInteger)numberOfPages;
- (UIView*)viewForPageAtIndex:(NSInteger) pageIndex;
- (NSArray *)bookRecipes;
- (NSInteger)currentPageNumber;

@end

@interface BookViewController : UIViewController

- (id)initWithBook:(CKBook*)book delegate:(id<BookViewControllerDelegate>)delegate;

@end
