//
//  BookSocialViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 16/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookSocialViewControllerDelegate <NSObject>

- (void)bookSocialViewControllerCloseRequested;

@end

@interface BookSocialViewController : UIViewController

- (id)initWithDelegate:(id<BookSocialViewControllerDelegate>)delegate;

@end
