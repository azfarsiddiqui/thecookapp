//
//  WelcomeViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 25/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WelcomeViewControllerDelegate <NSObject>

- (void)welcomeViewControllerGetStartedReached;

@end

@interface WelcomeViewController : UICollectionViewController

- (id)initWithDelegate:(id<WelcomeViewControllerDelegate>)delegate;
- (void)enable:(BOOL)enable;

@end
