//
//  NotificationTableViewCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 28/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKUserNotification;

@interface NotificationTableViewCell : UITableViewCell

+ (CGFloat)heightForNotification:(CKUserNotification *)notification;

@end
