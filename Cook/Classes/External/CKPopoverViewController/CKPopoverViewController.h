//
//  CKPopoverViewController.h
//  CKPopoverViewController
//
//  Created by Jeff Tan-Ang on 28/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKPopoverViewController;

typedef enum {
	CKPopoverViewControllerTop,
	CKPopoverViewControllerLeft,
	CKPopoverViewControllerBottom,
	CKPopoverViewControllerRight,
} CKPopoverViewControllerDirection;

@protocol CKPopoverViewControllerDelegate

- (void)popoverViewController:(CKPopoverViewController *)popoverViewController willAppear:(BOOL)appear;
- (void)popoverViewController:(CKPopoverViewController *)popoverViewController didAppear:(BOOL)appear;

@end

@interface CKPopoverViewController : UIViewController

- (id)initWithContentViewController:(UIViewController *)contentViewController
                           delegate:(id<CKPopoverViewControllerDelegate>)delegate;
- (id)initWithContentViewController:(UIViewController *)contentViewController anchorOffset:(CGPoint)anchorOffset
                           delegate:(id<CKPopoverViewControllerDelegate>)delegate;
- (void)showInView:(UIView *)view direction:(CKPopoverViewControllerDirection)direction atPoint:(CGPoint)point;
- (void)hide;

@end
