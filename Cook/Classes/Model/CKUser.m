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
#import "CKUserNotification.h"
#import "CKUserFriend.h"
#import <FacebookSDK/FacebookSDK.h>

@interface CKUser ()

@end

static ObjectSuccessBlock loginSuccessfulBlock = nil;
static ObjectFailureBlock loginFailureBlock = nil;

@implementation CKUser

+ (CKUser *)currentUser {
    PFUser *parseUser = [PFUser currentUser];
    if (parseUser) {
        return [[CKUser alloc] initWithParseUser:[PFUser currentUser]];
    } else {
        return nil;
    }
}

+ (BOOL)isLoggedIn {
    return ([CKUser currentUser] != nil);
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
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *userData,
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

+ (void)logoutWithCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    [PFUser logOut];
    success();
}

+ (CKUser *)userWithParseUser:(PFUser *)parseUser {
    return [[CKUser alloc] initWithParseUser:parseUser];
}

+ (PFObject *)createUserFriendObjectForUser:(PFUser *)parseUser friend:(PFUser *)parseFriend {
    
    // Read-write for both parties only.
    PFACL *acl = [PFACL ACL];
    [acl setReadAccess:YES forUser:parseUser];
    [acl setReadAccess:YES forUser:parseFriend];
    [acl setWriteAccess:YES forUser:parseUser];
    [acl setWriteAccess:YES forUser:parseFriend];
    
    PFObject *userFriend = [PFObject objectWithClassName:kUserFriendModelName];
    [userFriend setObject:parseUser forKey:kUserModelForeignKeyName];
    [userFriend setObject:parseFriend forKey:kUserFriendFriend];
    [userFriend setObject:@NO forKey:kUserFriendAttrConnected];
    [userFriend setACL:acl];
    
    return userFriend;
}

#pragma mark - CKModel 

- (NSString *)objectId {
    return self.parseUser.objectId;
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

- (NSArray *)bookSuggestionIds {
    return [self.parseUser objectForKey:kUserAttrBookSuggestions];
}

- (NSUInteger)numFollows {
    return 0;
}

- (BOOL)admin {
    return [[self.parseUser objectForKey:kUserAttrAdmin] boolValue];
}

- (NSURL *)pictureUrl {
    NSURL *pictureUrl = nil;
    if ([PFFacebookUtils isLinkedWithUser:self.parseUser]) {
        pictureUrl = [NSURL URLWithString:
                      [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.facebookId]];
    }
    return pictureUrl;
}

- (void)setFirstName:(NSString *)firstName {
    [self.parseObject setObject:firstName forKey:kUserAttrFirstName];
}

- (NSString *)firstName {
    return [self.parseObject objectForKey:kUserAttrFirstName];
}

- (void)setLastName:(NSString *)lastName {
    [self.parseObject setObject:lastName forKey:kUserAttrLastName];
}

- (NSString *)lastName {
    return [self.parseObject objectForKey:kUserAttrLastName];
}

- (void)checkIsFriendsWithUser:(CKUser *)friendUser completion:(UserFriendSuccessBlock)completion failure:(ObjectFailureBlock)failure {
    PFQuery *friendsQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [friendsQuery whereKey:kUserModelForeignKeyName equalTo:self.parseUser];
    [friendsQuery whereKey:kUserFriendFriend equalTo:friendUser.parseUser];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *friendRequests, NSError *error) {
        if (!error) {
            
            BOOL alreadySent = NO;
            BOOL alreadyConnected = [friendRequests detect:^BOOL(PFObject *friendRequest) {
                return [[friendRequest objectForKey:kUserFriendAttrConnected] boolValue];
            }];
            
            if (!alreadyConnected) {
                alreadySent = ([friendRequests count] > 0);
            }
            completion(alreadySent, alreadyConnected);
        } else {
            failure(error);
        }
    }];
}

- (void)requestFriend:(CKUser *)friendUser completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    // Is there an existing friend request in flight?
    PFQuery *requestorFriendRequestQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [requestorFriendRequestQuery whereKey:kUserModelForeignKeyName equalTo:self.parseUser];
    [requestorFriendRequestQuery whereKey:kUserFriendFriend equalTo:friendUser.parseUser];
    
    // Is there an existing friend request from the requestee?
    PFQuery *requesteeFriendRequestQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [requesteeFriendRequestQuery whereKey:kUserModelForeignKeyName equalTo:friendUser.parseUser];
    [requesteeFriendRequestQuery whereKey:kUserFriendFriend equalTo:self.parseUser];
    
    // Compound both to determine if any of the above is true?
    PFQuery *existingFriendRequestQuery = [PFQuery orQueryWithSubqueries:
                                           [NSArray arrayWithObjects:requestorFriendRequestQuery, requesteeFriendRequestQuery, nil]];
    [existingFriendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *friendRequests, NSError *error) {
        if (!error) {
            
            BOOL newRequest = NO;
            
            NSInteger existingRequestorFriendRequestId = [friendRequests findIndexWithBlock:^BOOL(PFObject *parseFriendRequest) {
                return [[parseFriendRequest objectForKey:kUserModelForeignKeyName] isEqual:self.parseUser];
            }];
            NSInteger existingRequesteeFriendRequestId = [friendRequests findIndexWithBlock:^BOOL(PFObject *parseFriendRequest) {
                return [[parseFriendRequest objectForKey:kUserFriendFriend] isEqual:self.parseUser];
            }];
            
            // Existing requestor request?
            PFObject *requestorFriendRequest = nil;
            if (existingRequestorFriendRequestId != -1) {
                requestorFriendRequest = [friendRequests objectAtIndex:existingRequestorFriendRequestId];
            } else {
                requestorFriendRequest = [CKUser createUserFriendObjectForUser:self.parseUser friend:friendUser.parseUser];
            }
            
            // Existing requestee request?
            PFObject *requesteeFriendRequest = nil;
            if (existingRequesteeFriendRequestId != -1) {
                requesteeFriendRequest = [friendRequests objectAtIndex:existingRequesteeFriendRequestId];
                BOOL connected = [[requesteeFriendRequest objectForKey:kUserFriendAttrConnected] boolValue];
                
                // If requestee is connected but requestor is not, connect requestor.
                if (connected && ![[requestorFriendRequest objectForKey:kUserFriendAttrConnected] boolValue]) {
                    [requestorFriendRequest setObject:@YES forKey:kUserFriendAttrConnected];
                }
                
            } else {
                requesteeFriendRequest = [CKUser createUserFriendObjectForUser:friendUser.parseUser friend:self.parseUser];
                newRequest = YES;
            }
            
            // Save requests.
            NSMutableArray *batchSaves = [NSMutableArray arrayWithArray:@[requestorFriendRequest, requesteeFriendRequest]];
            
            // Do we need a user notification?
            if (newRequest) {
                PFObject *parseNotification = [CKUserNotification createNotificationForParseUser:friendUser.parseUser
                                                                              parseFriendRequest:requesteeFriendRequest];
                [batchSaves addObject:parseNotification];
            }
            
            [PFObject saveAllInBackground:batchSaves block:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    success();
                } else {
                    failure(error);
                }
            }];
            
        } else {
            failure(error);
        }
    }];
    
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.facebookId] forKey:kUserAttrFacebookId];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self isSignedIn]] forKey:@"signedIn"];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:self.admin] forKey:kUserAttrAdmin];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%d", [[self.parseUser objectForKey:kUserAttrFacebookFriends] count]]
                             forKey:@"facebookFriends"];
    return descriptionProperties;
}

#pragma mark - Private methods

+ (void)populateUserDetailsFromFacebookData:(NSDictionary<FBGraphUser> *)userData {
    CKUser *currentUser = [CKUser currentUser];
    DLog(@"Logged in user %@", currentUser);
    if (currentUser.admin) {
        [CKUser handleAdminLoginFromFacebookData:userData];
    } else {
        [CKUser handleUserLoginFromFacebookData:userData];
    }
}

+ (CKUser *)initialiseUserWithParseUser:(PFUser *)parseUser {
    if (parseUser.objectId == nil) {
        
        DLog(@"initialiseUserWithParseUser:creating book");
        
        // Initial default name.
        [parseUser setObject:kUserAttrDefaultNameValue forKey:kModelAttrName];
        
        // Create a book for the new user and save it in the background.
        PFObject *parseBook = [CKBook createParseBookForParseUser:parseUser];
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

+ (void)handleAdminLoginFromFacebookData:(NSDictionary<FBGraphUser> *)userData {
    DLog(@"Logged in as admin");
    
    CKUser *currentUser = [CKUser currentUser];
    
    // Admin books query.
    PFQuery *adminBookQuery = [PFQuery queryWithClassName:kBookModelName];
    [adminBookQuery whereKey:kUserModelForeignKeyName equalTo:currentUser.parseUser];
    [adminBookQuery findObjectsInBackgroundWithBlock:^(NSArray *books, NSError *error) {
        if (!error) {
            
            // Admin follow.
            PFQuery *adminFollowQuery = [PFQuery queryWithClassName:kBookFollowModelName];
            [adminFollowQuery whereKey:kUserModelForeignKeyName equalTo:currentUser.parseUser];
            [adminFollowQuery findObjectsInBackgroundWithBlock:^(NSArray *parseFollows, NSError *error) {
                
                // Existing admin follow ids to find which admin books to follow.
                NSArray *adminFollowIds = [parseFollows collect:^id(PFObject *parseFollow) {
                    PFObject *adminFollowBook = [parseFollow objectForKey:kBookModelForeignKeyName];
                    return adminFollowBook.objectId;
                }];
               
                // Figure out new admin books to follow.
                NSArray *adminBooksToFollow = [books select:^BOOL(PFObject *parseBook) {
                    return (![adminFollowIds containsObject:parseBook.objectId]);
                }];
                
                // Prepare admin follows to create.
                NSMutableArray *objectsToUpdate = [NSMutableArray arrayWithCapacity:[adminBooksToFollow count]];
                for (PFObject *adminBook in adminBooksToFollow) {
                    
                    // Create suggested follow of my book for my friends.
                    PFObject *adminBookFollow = [self objectWithDefaultSecurityWithClassName:kBookFollowModelName];
                    [adminBookFollow setObject:currentUser.parseUser forKey:kUserModelForeignKeyName];
                    [adminBookFollow setObject:adminBook forKey:kBookModelForeignKeyName];
                    [adminBookFollow setObject:[NSNumber numberWithBool:YES] forKey:kBookFollowAttrAdmin];
                    [objectsToUpdate addObject:adminBookFollow];
                }
                
                // Save it off.
                [PFObject saveAllInBackground:objectsToUpdate block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        loginSuccessfulBlock();
                        loginSuccessfulBlock = nil;
                        loginFailureBlock = nil;
                    } else {
                        loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                                         message:[NSString stringWithFormat:@"Unable to process admin follow books for %@", currentUser]]);
                        loginFailureBlock = nil;
                        loginSuccessfulBlock = nil;
                    }
                }];
                
            }];
            
        } else {
            loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                             message:[NSString stringWithFormat:@"Unable to process admin follow books for %@", currentUser]]);
            loginFailureBlock = nil;
            loginSuccessfulBlock = nil;
        }
    }];
}

+ (void)handleUserLoginFromFacebookData:(NSDictionary<FBGraphUser> *)userData {
    
    // Find the user's friends, and see if any of them are Cook users
    [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection,
                                                                     NSDictionary *jsonDictionary, NSError *error) {
        CKUser *currentUser = [CKUser currentUser];
        
        if (!error) {
            
            // Grab the facebook ids of friends.
            NSArray *friendIds = [[jsonDictionary objectForKey:@"data"] collect:^id(NSDictionary<FBGraphUser> *friendData) {
                return friendData.id;
            }];
            
            // Save the username
            currentUser.name = [NSString CK_safeString:userData.name defaultString:kUserAttrDefaultNameValue];
            currentUser.facebookId = userData.id;
            currentUser.firstName = userData.first_name;
            currentUser.lastName = userData.last_name;
            
            // Store the facebook friends ids.
            [currentUser.parseUser addUniqueObjectsFromArray:friendIds forKey:kUserAttrFacebookFriends];
            
            // Save it off.
            [currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
            
        } else {
            
            loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                             message:[NSString stringWithFormat:@"Unable to retrieve friends for %@", currentUser]]);
            loginFailureBlock = nil;
            loginSuccessfulBlock = nil;
        }
        
    }];

}


//overridden

-(BOOL)isEqual:(id)other
{
   
   if(other == self)
        return YES;
    
    if(!other || ![other isKindOfClass:[self class]])
        return NO;
    
    return [self isEqualToUser:other];
}

- (BOOL)isEqualToUser:(CKUser *)user {
    
    if (self == user)
        return YES;
    
    if (![self.name isEqualToString:user.name])
        return NO;
    
    if (![self.facebookId isEqualToString:user.facebookId])
        return NO;
    
    return YES;
}
- (unsigned)hash {
    return [self.name hash] ^ [self.facebookId hash];
}

@end
