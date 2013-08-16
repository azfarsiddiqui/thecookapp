//
//  DashboardTutorialViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 16/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DashboardTutorialViewControllerDelegate <NSObject>

- (void)dashboardTutorialViewControllerDismissRequested;

@end

@interface DashboardTutorialViewController : UIViewController

- (id)initWithDelegate:(id<DashboardTutorialViewControllerDelegate>)delegate;

@end
