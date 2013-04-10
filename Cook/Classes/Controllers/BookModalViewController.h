//
//  BookModalViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookModalViewControllerDelegate.h"

@protocol BookModalViewController <NSObject>

- (void)setModalViewControllerDelegate:(id<BookModalViewControllerDelegate>)modalViewControllerDelegate;
- (void)bookModalViewControllerWillAppear:(NSNumber *)appearNumber;
- (void)bookModalViewControllerDidAppear:(NSNumber *)appearNumber;

@end
