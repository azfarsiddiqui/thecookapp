//
//  CKNotificationView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 22/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKNotificationViewDelegate <NSObject>

- (void)notificationViewTapped;

@end

@interface CKNotificationView : UIView

- (id)initWithDelegate:(id<CKNotificationViewDelegate>)delegate;
- (void)clearBadge;

@end
