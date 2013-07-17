//
//  BookAddViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 17/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookAddViewControllerDelegate <NSObject>

- (void)bookAddViewControllerCloseRequested;

@end

@interface BookAddViewController : UIViewController

- (id)initWithDelegate:(id<BookAddViewControllerDelegate>)delegate;
- (void)enable:(BOOL)enable;

@end
