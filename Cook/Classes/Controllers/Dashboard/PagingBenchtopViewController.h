//
//  PagingBenchtopViewController.h
//  CKPagingBenchtopDemo
//
//  Created by Jeff Tan-Ang on 8/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchtopViewControllerDelegate.h"

@interface PagingBenchtopViewController : UIViewController

@property (nonatomic, assign) id<BenchtopViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL allowDelete;

- (void)loadBenchtop:(BOOL)load;
- (void)enable:(BOOL)enable;
- (void)bookWillOpen:(BOOL)open;
- (void)bookDidOpen:(BOOL)open;
- (void)showLoginViewSignUp:(BOOL)signUp;
- (void)hideLoginViewCompletion:(void (^)())completion;

@end
