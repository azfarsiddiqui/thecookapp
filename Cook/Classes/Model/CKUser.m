//
//  CKUser.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKUser.h"

@interface CKUser ()

@property (nonatomic, copy) LoginSuccessBlock loginSuccessfulBlock;
@property (nonatomic, copy) ObjectFailureBlock loginFailureBlock;

- (void)populateUserDetailsFromFacebookData:(NSDictionary<PF_FBGraphUser>*)facebookUser;

@end

@implementation CKUser

+ (CKUser *)currentUser {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        return [[CKUser alloc] initWithParseUser:currentUser];
    } else {
        return nil;
    }
}

- (BOOL)isSignedIn {
    return [PFFacebookUtils isLinkedWithUser:(PFUser *)self.parseObject];
}

- (id)initWithParseUser:(PFUser *)parseUser {
    if (self = [super initWithParseObject:parseUser]) {
    }
    return self;
}

- (void)loginWithFacebookCompletion:(LoginSuccessBlock)success failure:(ObjectSuccessBlock)failure {
    NSAssert([self isSignedIn], @"User already linked with Facebook.");
    
    [PFFacebookUtils linkUser:(PFUser *)self.parseObject
                  permissions:nil
                        block:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                
                                // Update user details and friends.
                                [[PF_FBRequest requestForMe] startWithCompletionHandler:
                                 ^(PF_FBRequestConnection *connection,
                                   NSDictionary<PF_FBGraphUser> *user,
                                   NSError *error) {
                                     if (error) {
                                         self.loginFailureBlock(error);
                                         self.loginFailureBlock = nil;
                                         self.loginSuccessfulBlock = nil;
                                     } else {
                                         [self populateUserDetailsFromFacebookData:user];
                                     }
                                 }];

                            } else {
                                failure(error);
                            }
    }];
    
}

- (void)setFacebookId:(NSString *)facebookId {
    [self.parseObject setObject:facebookId forKey:kCKUserFacebookIdKey];
}

- (NSString *)facebookId {
    return [self.parseObject objectForKey:kCKUserFacebookIdKey];
}

#pragma mark - Private methods

- (void)populateUserDetailsFromFacebookData:(NSDictionary<PF_FBGraphUser>*)facebookUser {
    CKUser *currentUser = [CKUser currentUser];
    
    // Find the user's friends, and see if any of them are Cook users
    [[PF_FBRequest requestForMyFriends] startWithCompletionHandler:
     ^(PF_FBRequestConnection *connection,
       NSDictionary *jsonDictionary, NSError *error){
         DLog(@"friend count: %i", [[jsonDictionary objectForKey:@"data"] count]);
         for (NSDictionary<PF_FBGraphUser> *friend in [jsonDictionary objectForKey:@"data"]) {
             DLog(@"%@", friend);
         }
     }];
    
    // Save facebook profile details.
    self.name = facebookUser.name;
    self.facebookId = facebookUser.id;
    
    [self saveEventually];
    
    self.loginSuccessfulBlock(currentUser);
    self.loginSuccessfulBlock = nil;
    self.loginFailureBlock = nil;
}

@end
