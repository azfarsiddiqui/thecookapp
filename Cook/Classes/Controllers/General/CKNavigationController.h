//
//  CKNavigationController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKNavigationController;
@class CKRecipe;
@class CKBook;

@protocol CKNavigationControllerSupport

@optional
- (void)setCookNavigationController:(CKNavigationController *)cookNavigationController;
- (void)cookNavigationControllerViewWillAppear:(NSNumber *)boolNumber;
- (void)cookNavigationControllerViewDidAppear:(NSNumber *)boolNumber;
- (void)cookNavigationControllerViewAppearing:(NSNumber *)boolNumber;

@end

@protocol CKNavigationControllerDelegate <NSObject>

@optional
- (void)cookNavigationControllerCloseRequested;

@end

@interface CKNavigationController : UIViewController

@property (nonatomic, weak) id<CKNavigationControllerDelegate> delegate;

- (id)initWithRootViewController:(UIViewController *)viewController;
- (id)initWithRootViewController:(UIViewController *)viewController delegate:(id<CKNavigationControllerDelegate>)delegate;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)topViewController;
- (BOOL)isTopViewController:(UIViewController *)viewController;
- (BOOL)isTop;

- (void)showContextWithRecipe:(CKRecipe *)recipe;
- (void)showContextWithBook:(CKBook *)book;
- (void)hideContext;

@end
