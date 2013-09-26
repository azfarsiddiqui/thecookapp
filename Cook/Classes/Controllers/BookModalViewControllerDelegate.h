//
//  BookModalViewControllerDelegate.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BookModalViewControllerDelegate <NSObject>

- (void)closeRequestedForBookModalViewController:(UIViewController *)viewController;
- (void)fullScreenLoadedForBookModalViewController:(UIViewController *)viewController;

@end
