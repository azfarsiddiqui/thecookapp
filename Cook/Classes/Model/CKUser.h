//
//  CKUser.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CKModel.h"

@class CKUser;

typedef void(^LoginSuccessBlock)(CKUser *user);

@interface CKUser : CKModel

@property (nonatomic, strong) PFUser *parseUser;
@property (nonatomic, copy) NSString *facebookId;

+ (CKUser *)currentUser;
+ (void)loginWithFacebookCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

- (id)initWithParseUser:(PFUser *)parseUser;
- (BOOL)isSignedIn;
- (NSArray *)followIds;
- (NSUInteger)numFollows;
- (BOOL)isAdmin;
- (void)autoFollowCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

@end
