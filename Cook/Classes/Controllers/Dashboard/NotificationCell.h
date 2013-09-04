//
//  NotificationCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKUserNotification;
@class NotificationCell;

@protocol NotificationCellDelegate <NSObject>

- (void)notificationCell:(NotificationCell *)notificationCell acceptFriendRequest:(BOOL)accept;
- (BOOL)notificationCellInProgress:(NotificationCell *)notificationCell;

@end

@interface NotificationCell : UICollectionViewCell

@property (nonatomic, weak) id<NotificationCellDelegate> delegate;
@property (nonatomic, strong) CKUserNotification *notification;

+ (CGSize)unitSize;

- (void)configureNotification:(CKUserNotification *)notification;

@end
