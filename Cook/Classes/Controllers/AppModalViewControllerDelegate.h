//
//  AppModalViewControllerDelegate.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppModalViewControllerDelegate <NSObject>

- (void)closeRequestedForAppModalViewController:(UIViewController *)viewController;

@optional
- (void)fullScreenLoadedForAppModalViewController:(UIViewController *)viewController;

@end
