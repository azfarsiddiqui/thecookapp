//
//  AppModalViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppModalViewControllerDelegate.h"

@protocol AppModalViewController <NSObject>

- (void)setModalViewControllerDelegate:(id<AppModalViewControllerDelegate>)modalViewControllerDelegate;
- (void)appModalViewControllerWillAppear:(NSNumber *)appearNumber;
- (void)appModalViewControllerDidAppear:(NSNumber *)appearNumber;

@optional
- (void)appModalViewControllerAppearing:(NSNumber *)appearingNumber;

@end
