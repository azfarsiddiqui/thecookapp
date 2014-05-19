//
//  CKUserNotification.h
//  Cook
//
//  Created by Jeff Tan-Ang on 14/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@class CKUser;
@class CKRecipe;

@interface CKUserNotification : CKModel

@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) BOOL friendRequestAccepted;
@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, strong) NSString *comment;

+ (void)hasNotificationsForUser:(CKUser *)user completion:(BoolObjectSuccessBlock)completion
                        failure:(ObjectFailureBlock)failure;
+ (void)notificationsFromItemIndex:(NSUInteger)itemIndex completion:(PaginatedListSuccessBlock)completion
                           failure:(ObjectFailureBlock)failure;
+ (void)notificationsCountCompletion:(NumObjectSuccessBlock)completion failure:(ObjectFailureBlock)failure;

- (CKUser *)user;
- (CKUser *)actionUser;
- (CKRecipe *)recipe;
- (NSString *)actionName;

@end
