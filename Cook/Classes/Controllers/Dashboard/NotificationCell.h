//
//  NotificationCell.h
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKUserNotification;

@interface NotificationCell : UICollectionViewCell

+ (CGSize)unitSize;

- (void)configureNotification:(CKUserNotification *)notification;

@end
