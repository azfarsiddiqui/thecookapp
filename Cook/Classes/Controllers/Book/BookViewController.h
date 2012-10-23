//
//  BookViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKBook.h"

@protocol BookViewControllerDelegate

- (void)bookViewControllerCloseRequested;

@end

@protocol BookViewDelegate

- (void)bookViewCloseRequested;

@end

@protocol BookViewDataSource
-(NSInteger) numberOfPagesInBook;
-(UIView*) viewForPageAtIndex:(NSInteger) pageIndex;

@end

@interface BookViewController : UIViewController

- (id)initWithBook:(CKBook*)book delegate:(id<BookViewControllerDelegate>)delegate;

@end
