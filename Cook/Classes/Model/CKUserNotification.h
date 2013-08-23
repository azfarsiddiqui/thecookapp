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

@property (nonatomic, assign) BOOL read;

+ (void)hasNotificationsForUser:(CKUser *)user completion:(BoolObjectSuccessBlock)completion
                        failure:(ObjectFailureBlock)failure;
+ (void)notificationsCompletion:(ListObjectsSuccessBlock)completion failure:(ObjectFailureBlock)failure;
+ (void)notificationsCountCompletion:(NumObjectSuccessBlock)completion failure:(ObjectFailureBlock)failure;

- (CKUser *)user;
- (NSString *)actionName;

@end
