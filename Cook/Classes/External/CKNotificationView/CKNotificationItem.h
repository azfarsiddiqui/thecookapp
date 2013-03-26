//
//  CKNotificationItem.h
//  CKNotificationViewDemo
//
//  Created by Jeff Tan-Ang on 26/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKNotificationItem : NSObject

@property (nonatomic, strong) NSURL *profileUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@end
