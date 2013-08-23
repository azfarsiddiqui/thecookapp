//
//  CKUserNotification.m
//  Cook
//
//  Created by Jeff Tan-Ang on 14/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKUserNotification.h"
#import "CKUser.h"
#import "MRCEnumerable.h"

@implementation CKUserNotification

+ (void)hasNotificationsForUser:(CKUser *)user completion:(BoolObjectSuccessBlock)completion
                        failure:(ObjectFailureBlock)failure {
    
    PFQuery *query = [PFQuery queryWithClassName:kUserNotificationModelName];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [query whereKey:kUserNotificationAttrRead equalTo:@YES];
    [query countObjectsInBackgroundWithBlock:^(int numRows, NSError *error) {
        if (!error) {
            completion(numRows > 0);
        } else {
            failure(error);
        }
    }];
}

+ (void)notificationsCompletion:(ListObjectsSuccessBlock)completion failure:(ObjectFailureBlock)failure {
    
    CKUser *user = [CKUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:kUserNotificationModelName];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [query includeKey:kUserModelForeignKeyName];
    [query orderByDescending:kModelAttrCreatedAt];
    [query findObjectsInBackgroundWithBlock:^(NSArray *notificationObjects, NSError *error) {
        if (!error) {
            NSArray *notifications = [notificationObjects collect:^id(PFObject *parseNotification) {
                return [[CKUserNotification alloc] initWithParseObject:parseNotification];
            }];
            
            // Mark them as read and save in the background.
            [notificationObjects each:^(PFObject *parseNotification) {
                [parseNotification setObject:@YES forKey:kUserNotificationAttrRead];
            }];
            [PFObject saveAllInBackground:notificationObjects];
            
            completion(notifications);
            
        } else {
            failure(error);
        }
    }];
}

+ (void)notificationsCountCompletion:(NumObjectSuccessBlock)completion failure:(ObjectFailureBlock)failure {
    CKUser *user = [CKUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:kUserNotificationModelName];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [query includeKey:kUserModelForeignKeyName];
    [query orderByDescending:kModelAttrCreatedAt];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            completion(count);
        } else {
            failure(error);
        }
    }];
}

- (CKUser *)user {
    return [CKUser userWithParseUser:[self.parseObject objectForKey:kUserModelForeignKeyName]];
}

- (void)setRead:(BOOL)read {
    [self.parseObject setObject:[NSNumber numberWithBool:read] forKey:kUserNotificationAttrRead];
}

- (BOOL)read {
    return [[self.parseObject objectForKey:kUserNotificationAttrRead] boolValue];
}

- (NSString *)actionName {
    return [self.parseObject objectForKey:kModelAttrName];
}

@end
