//
//  CKUserNotification.m
//  Cook
//
//  Created by Jeff Tan-Ang on 14/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKUserNotification.h"
#import "CKUser.h"
#import "CKRecipe.h"
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
    
    [PFCloud callFunctionInBackground:@"notifications"
                       withParameters:@{}
                                block:^(NSArray *notificationObjects, NSError *error) {
                                    if (!error) {
                                        NSArray *notifications = [notificationObjects collect:^id(PFObject *parseNotification) {
                                            return [[CKUserNotification alloc] initWithParseObject:parseNotification];
                                        }];
                                        completion(notifications);
                                        
                                    } else {
                                        DLog(@"Error loading notifications: %@", [error localizedDescription]);
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

- (CKUser *)actionUser {
    return [CKUser userWithParseUser:[self.parseObject objectForKey:kUserNotificationAttrActionUser]];
}

- (CKRecipe *)recipe {
    return [CKRecipe recipeForParseRecipe:[self.parseObject objectForKey:kRecipeModelForeignKeyName] user:[self user]];
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
