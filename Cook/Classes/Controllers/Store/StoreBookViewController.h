//
//  StoreBookViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@protocol StoreBookViewControllerDelegate

- (void)storeBookViewControllerCloseRequested;
- (void)storeBookViewControllerUpdatedBook:(CKBook *)book;

@end

@interface StoreBookViewController : UIViewController

- (id)initWithBook:(CKBook *)book addMode:(BOOL)addMode delegate:(id<StoreBookViewControllerDelegate>)delegate;
- (void)transitionFromPoint:(CGPoint)point;

@end
