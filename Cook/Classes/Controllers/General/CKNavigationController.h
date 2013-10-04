//
//  CKNavigationController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKNavigationController;

@protocol CKNavigationControllerSupport

@optional
- (void)setCookNavigationController:(CKNavigationController *)cookNavigationController;

@end

@interface CKNavigationController : UIViewController

- (id)initWithRootViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;

@end
