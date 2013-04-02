//
//  CKUserNotification.h
//  Cook
//
//  Created by Jeff Tan-Ang on 14/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@class CKUser;

@interface CKUserNotification : CKModel

@property (nonatomic, assign) BOOL unread;

+ (void)hasNotificationsForUser:(CKUser *)user completion:(BoolObjectSuccessBlock)completion
                        failure:(ObjectFailureBlock)failure;
+ (void)notificationsForUser:(CKUser *)user completion:(ListObjectsSuccessBlock)completion
                     failure:(ObjectFailureBlock)failure;
+ (PFObject *)createNotificationForParseUser:(PFUser *)parseUser parseFriendRequest:(PFObject *)parseFriendRequest;

- (CKUser *)user;
- (NSString *)actionName;

@end
