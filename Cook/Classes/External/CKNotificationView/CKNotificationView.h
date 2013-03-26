//
//  CKNotificationView.h
//  CKNotificationViewDemo
//
//  Created by Jeff Tan-Ang on 26/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKNotificationView;

@protocol CKNotificationViewDelegate <NSObject>

- (void)notificationViewTapped:(CKNotificationView *)notifyView;
- (UIView *)notificationItemViewForIndex:(NSInteger)itemIndex;
- (void)notificationView:(CKNotificationView *)notifyView tappedForItemIndex:(NSInteger)itemIndex;

@end

@interface CKNotificationView : UIView

- (id)initWithDelegate:(id<CKNotificationViewDelegate>)delegate;
- (void)clear;
- (void)setNotificationItems:(NSArray *)notificationItems;
- (BOOL)hasNotificationItems;

@end
