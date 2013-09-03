//
//  NotificationsViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationsViewControllerDelegate <NSObject>

- (void)notificationsViewControllerDataLoaded;
- (void)notificationsViewControllerDismissRequested;
- (UIImage *)notificationsViewControllerSnapshotImageRequested;

@end

@interface NotificationsViewController : UICollectionViewController

- (id)initWithDelegate:(id<NotificationsViewControllerDelegate>)delegate;

@end
