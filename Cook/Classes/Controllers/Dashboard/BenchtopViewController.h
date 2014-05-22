//
//  PagingBenchtopViewController.h
//  CKPagingBenchtopDemo
//
//  Created by Jeff Tan-Ang on 8/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchtopViewControllerDelegate.h"

@class CKBook;

@interface BenchtopViewController : UIViewController

@property (nonatomic, weak) id<BenchtopViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL allowDelete;

- (void)loadBenchtop;
- (void)enable:(BOOL)enable;
- (void)bookAboutToClose;
- (void)showVisibleBooks:(BOOL)show;
- (void)bookWillOpen:(BOOL)open;
- (void)bookDidOpen:(BOOL)open;
- (void)showLoginView;
- (void)showLoginViewSignUp:(BOOL)signUp;
- (void)hideLoginViewCompletion:(void (^)())completion;
- (void)refreshBook:(CKBook *)book;

@end
