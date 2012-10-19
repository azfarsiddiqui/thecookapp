//
//  CKUser.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKUser.h"
#import "NSString+Utilities.h"
#import "CKBook.h"
#import "MRCEnumerable.h"

@interface CKUser ()

@end

static ObjectSuccessBlock loginSuccessfulBlock = nil;
static ObjectFailureBlock loginFailureBlock = nil;

@implementation CKUser

+ (CKUser *)currentUser {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        return [self initialiseUserWithParseUser:currentUser];
    } else {
        // Should always return non-nil because enableAutomaticUser is set.
        return nil;
    }
}

+ (void)loginWithFacebookCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    CKUser *currentUser = [CKUser currentUser];
    
    // Make sure user is not signed on already.
    if ([currentUser isSignedIn]) {
        failure([CKModel errorWithMessage:[NSString stringWithFormat:@"User %@ already signed in", currentUser]]);
        return;
    }
    
    // Copies and saves the completion blocks.
    loginSuccessfulBlock = [success copy];
    loginFailureBlock = [failure copy];
    
    // Go ahead and link this user via Facebook.
    DLog(@"Linking user with facebook %@", self);
    [PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                loginFailureBlock([CKModel errorWithCode:kCKLoginCancelledErrorCode
                                                 message:[NSString stringWithFormat:@"User %@ cancelled signin", currentUser]]);
            } else {
                loginFailureBlock(error);
            }
            loginFailureBlock = nil;
            loginSuccessfulBlock = nil;
            
        } else {
            
            // Update user details and friends.
            [[PF_FBRequest requestForMe] startWithCompletionHandler:
             ^(PF_FBRequestConnection *connection,
               NSDictionary<PF_FBGraphUser> *userData,
               NSError *error) {
                 if (error) {
                     loginFailureBlock(error);
                     loginFailureBlock = nil;
                     loginSuccessfulBlock = nil;
                 } else {
                     [CKUser populateUserDetailsFromFacebookData:userData];
                 }
             }];
        }
    }];
    
}

#pragma mark - CKUser

- (BOOL)isSignedIn {
    return [PFFacebookUtils isLinkedWithUser:self.parseUser];
}

- (id)initWithParseUser:(PFUser *)parseUser {
    if (self = [super initWithParseObject:parseUser]) {
        self.parseUser = parseUser;
    }
    return self;
}

- (void)setFacebookId:(NSString *)facebookId {
    [self.parseUser setObject:facebookId forKey:kUserAttrFacebookId];
}

- (NSString *)facebookId {
    return [self.parseUser objectForKey:kUserAttrFacebookId];
}

- (NSArray *)followIds {
    return [self.parseUser objectForKey:kUserAttrFollows];
}

- (NSUInteger)numFollows {
    return [[self followIds] count];
}

- (BOOL)isAdmin {
    return [[self.parseUser objectForKey:kUserAttrAdmin] boolValue];
}

- (void)autoFollowCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    // First check if we have any auto-follow.
    PFQuery *followRequestQuery = [PFQuery queryWithClassName:kFollowRequestModelName];
    [followRequestQuery whereKey:kUserModelForeignKeyName equalTo:self.parseUser];
    [followRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *followRequests, NSError *error) {
        if (!error) {
            
            // Auto-follow the requested user ids.
            NSArray *requestedUserIds = [followRequests collect:^id(PFObject *followRequest) {
                return [followRequest objectForKey:kFollowRequestAttrRequestedUser];
            }];
            [self.parseUser addUniqueObjectsFromArray:requestedUserIds forKey:kUserAttrFollows];
            DLog(@"Auto followed %d friends", [requestedUserIds count]);
            
            // Delete the auto follow requests.
            [followRequests makeObjectsPerformSelector:@selector(deleteEventually)];
            DLog(@"Deleted follow requests.");
            
            success();
        } else {
            failure(error);
        }
    }];
    
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.facebookId] forKey:@"facebookId"];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self isSignedIn]] forKey:@"signedIn"];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [self numFollows]] forKey:@"numFollows"];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self isAdmin]] forKey:@"admin"];
    return descriptionProperties;
}

#pragma mark - Private methods

+ (void)populateUserDetailsFromFacebookData:(NSDictionary<PF_FBGraphUser> *)userData {
    CKUser *currentUser = [CKUser currentUser];
    DLog(@"Logged in user %@", currentUser);
    if ([currentUser isAdmin]) {
        [CKUser handleAdminLoginFromFacebookData:userData];
    } else {
        [CKUser handleUserLoginFromFacebookData:userData];
    }
}

+ (CKUser *)initialiseUserWithParseUser:(PFUser *)parseUser {

    if (parseUser.objectId == nil) {
        
        DLog(@"initialiseUserWithParseUser:creating book");
        
        // Create a book for the new user and save it in the background.
        PFObject *parseBook = [CKBook parseBookForParseUser:parseUser];
        [parseBook saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                DLog(@"initialiseUserWithParseUser:created book");
            } else {
                DLog(@"initialiseUserWithParseUser:Error initialising user: %@",
                     [error localizedDescription]);
            }
        }];
        
    }
    return [[CKUser alloc] initWithParseUser:parseUser];
}

+ (void)handleAdminLoginFromFacebookData:(NSDictionary<PF_FBGraphUser> *)userData {
    DLog(@"Logged in as admin");
    
    // Call success completion.
    loginSuccessfulBlock();
    loginSuccessfulBlock = nil;
    loginFailureBlock = nil;
}

+ (void)handleUserLoginFromFacebookData:(NSDictionary<PF_FBGraphUser> *)userData {
    
    // Find the user's friends, and see if any of them are Cook users
    [[PF_FBRequest requestForMyFriends] startWithCompletionHandler:^(PF_FBRequestConnection *connection,
                                                                     NSDictionary *jsonDictionary, NSError *error) {
        
        CKUser *currentUser = [CKUser currentUser];
        
        if (!error) {
            
            // Grab the facebook ids of friends.
            NSArray *friendIds = [[jsonDictionary objectForKey:@"data"] collect:^id(NSDictionary<PF_FBGraphUser> *friendData) {
                return friendData.id;
            }];
            DLog(@"Friend ids: %@", friendIds);
            
            // Friends query.
            PFQuery *friendsQuery = [PFUser query];
            [friendsQuery whereKey:kUserAttrFacebookId containedIn:friendIds];
            
            // Add admin user as auto-follow.
            PFQuery *adminQuery = [PFUser query];
            [adminQuery whereKey:kUserAttrAdmin equalTo:[NSNumber numberWithBool:YES]];
            
            PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:friendsQuery, adminQuery, nil]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
                if (error) {
                    loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                                     message:[NSString stringWithFormat:@"Unable to retrieve friends for %@", currentUser]]);
                    loginFailureBlock = nil;
                    loginSuccessfulBlock = nil;
                } else {
                    
                    // Save facebook profile details.
                    currentUser.name = userData.name;
                    currentUser.facebookId = userData.id;
                    
                    // Auto-follow my friends.
                    NSArray *cookFriends = [friends collect:^id(PFUser *parseUser) {
                        return parseUser.objectId;
                    }];
                    [currentUser.parseUser addUniqueObjectsFromArray:cookFriends forKey:kUserAttrFollows];
                    
                    // Prepare objects to update in bulk: follow requests and my profile.
                    NSMutableArray *objectsToUpdate = [NSMutableArray arrayWithCapacity:[friends count] + 1];
                    
                    // Loop through and add myself as follow request for my friends.
                    for (PFUser *parseFriend in friends) {
                        
                        // Create a follow request for the friend for myself.
                        PFObject *userFollowRequest = [PFObject objectWithClassName:kFollowRequestModelName];
                        [userFollowRequest setObject:parseFriend forKey:kUserModelForeignKeyName];
                        [userFollowRequest setObject:currentUser.parseUser forKey:kFollowRequestAttrRequestedUser];
                        
                        // Only myself and my friend can read and write the request.
                        PFACL *followRequestACL = [PFACL ACLWithUser:currentUser.parseUser];
                        [followRequestACL setWriteAccess:YES forUser:parseFriend];
                        [followRequestACL setReadAccess:YES forUser:parseFriend];
                        userFollowRequest.ACL = followRequestACL;
                        
                        // Add follow request to be saved in bulk.
                        [objectsToUpdate addObject:userFollowRequest];
                    }
                    
                    // Now add myself to be saved in bulk.
                    [objectsToUpdate addObject:currentUser.parseUser];
                    
                    // Now kick off the save and wait as we need operation to succeed before deeming it successful.
                    [PFObject saveAllInBackground:objectsToUpdate block:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            loginSuccessfulBlock();
                            loginSuccessfulBlock = nil;
                            loginFailureBlock = nil;
                        } else {
                            loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                                             message:[NSString stringWithFormat:@"Unable to save friends for %@", currentUser]]);
                            loginFailureBlock = nil;
                            loginSuccessfulBlock = nil;
                        }
                    }];
                }
            }];
            
        } else {
            
            loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                             message:[NSString stringWithFormat:@"Unable to retrieve friends for %@", currentUser]]);
            loginFailureBlock = nil;
            loginSuccessfulBlock = nil;
        }
        
    }];
}

@end
