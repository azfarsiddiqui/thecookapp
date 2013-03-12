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
@property (nonatomic, readonly) BOOL admin;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

+ (CKUser *)currentUser;
+ (BOOL)isLoggedIn;
+ (void)loginWithFacebookCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)logoutWithCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (CKUser *)userWithParseUser:(PFUser *)parseUser;

- (id)initWithParseUser:(PFUser *)parseUser;
- (BOOL)isSignedIn;
- (NSArray *)bookSuggestionIds;
- (NSUInteger)numFollows;
- (NSURL *)pictureUrl;

@end
