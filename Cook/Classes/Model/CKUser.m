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
#import "CKServerManager.h"
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

+ (void)registerWithEmail:(NSString *)email name:(NSString *)name password:(NSString *)password
             completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    DLog(@"Register with Email[%@] Name[%@]", email, name);
    
    // New user with email/password.
    PFUser *parseUser = [PFUser user];
    parseUser.username = email; // Email as username.
    parseUser.email = email;
    parseUser.password = password;
    [parseUser setObject:name forKey:kModelAttrName];
    
    // Register.
    [parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Update push tokens.
            [[CKServerManager sharedInstance] registerForPush];
            
            success();
        } else {
            failure(error);
        }
    }];
}

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(ObjectSuccessBlock)success
                failure:(ObjectFailureBlock)failure {
    
    DLog(@"Login with Email[%@]", email);
    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
        if (!error) {
            
            // Update push tokens.
            [[CKServerManager sharedInstance] registerForPush];
            
            success();
            
        } else {
            failure(error);
        }
    }];
    
}

+ (CKUser *)userWithParseUser:(PFUser *)parseUser {
    return [[CKUser alloc] initWithParseUser:parseUser];
}

+ (PFObject *)createUserFriendObjectForUser:(PFUser *)parseUser friend:(PFUser *)parseFriend
                                  requestor:(PFUser *)parseRequestor {
    
    // Read-write for both parties only.
    PFACL *acl = [PFACL ACL];
    [acl setReadAccess:YES forUser:parseUser];
    [acl setReadAccess:YES forUser:parseFriend];
    [acl setWriteAccess:YES forUser:parseUser];
    [acl setWriteAccess:YES forUser:parseFriend];
    
    PFObject *userFriend = [PFObject objectWithClassName:kUserFriendModelName];
    [userFriend setObject:parseUser forKey:kUserModelForeignKeyName];
    [userFriend setObject:parseFriend forKey:kUserFriendFriend];
    [userFriend setObject:parseRequestor forKey:kUserFriendAttrRequestor];
    [userFriend setObject:@NO forKey:kUserFriendAttrConnected];
    [userFriend setACL:acl];
    
    return userFriend;
}

+ (BOOL)usernameExistsForSignUpError:(NSError *)error {
    return ([error code] == kPFErrorUsernameTaken);
}

#pragma mark - CKModel 

- (NSString *)objectId {
    return self.parseUser.objectId;
}

#pragma mark - CKUser

- (BOOL)isSignedIn {
    return [self.parseUser isAuthenticated];
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

- (NSURL *)profilePhotoUrl {
    NSURL *pictureUrl = nil;
    
    // CHeck profilePhoto first before falling back to FB photo.
    PFFile *profilePhoto = [self.parseUser objectForKey:kUserAttrProfilePhoto];
    if (profilePhoto != nil) {
        pictureUrl = [NSURL URLWithString:profilePhoto.url];
    } else if ([self.facebookId length] > 0) {
        pictureUrl = [NSURL URLWithString:
                      [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.facebookId]];
    } else {
        pictureUrl = [[NSBundle mainBundle] URLForResource:@"cook_default_profile" withExtension:@"png"];
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

- (void)checkIsFriendsWithUser:(CKUser *)friendUser completion:(UserFriendSuccessBlock)completion
                       failure:(ObjectFailureBlock)failure {
    
    PFQuery *requestorQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [requestorQuery whereKey:kUserModelForeignKeyName equalTo:self.parseUser];
    [requestorQuery whereKey:kUserFriendFriend equalTo:friendUser.parseUser];
    
    PFQuery *requesteeQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [requesteeQuery whereKey:kUserModelForeignKeyName equalTo:friendUser.parseUser];
    [requesteeQuery whereKey:kUserFriendFriend equalTo:self.parseUser];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[requestorQuery, requesteeQuery]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *friendRequests, NSError *error) {
        if (!error) {
            BOOL alreadySent = NO;
            
            // Are we already connected?
            BOOL alreadyConnected = [friendRequests detect:^BOOL(PFObject *friendRequest) {
                PFUser *user = [friendRequest objectForKey:kUserModelForeignKeyName];
                return ([user.objectId isEqualToString:self.parseUser.objectId]
                        && [[friendRequest objectForKey:kUserFriendAttrConnected] boolValue]);
            }];
            
            // If we are not connected, are there an existing request already?
            if (!alreadyConnected) {
                alreadySent = [friendRequests detect:^BOOL(PFObject *friendRequest) {
                    PFUser *user = [friendRequest objectForKey:kUserModelForeignKeyName];
                    PFUser *requestor = [friendRequest objectForKey:kUserFriendAttrRequestor];
                    return ([user.objectId isEqualToString:self.parseUser.objectId]
                            && [requestor.objectId isEqualToString:self.parseUser.objectId]
                            && ![[friendRequest objectForKey:kUserFriendAttrConnected] boolValue]);
                }];
            }
            
            // Is there a pending acceptance from the other party?
            BOOL pendingAcceptance = [friendRequests detect:^BOOL(PFObject *friendRequest) {
                PFUser *user = [friendRequest objectForKey:kUserFriendFriend];
                PFUser *requestor = [friendRequest objectForKey:kUserFriendAttrRequestor];
                return ([user.objectId isEqualToString:self.parseUser.objectId]
                        && ![requestor.objectId isEqualToString:self.parseUser.objectId]
                        && ![[friendRequest objectForKey:kUserFriendAttrConnected] boolValue]);
            }];
            
            completion(alreadySent, alreadyConnected, pendingAcceptance);
            
        } else {
            failure(error);
        }
    }];
}

- (void)numFriendsCompletion:(NumObjectSuccessBlock)completion failure:(ObjectFailureBlock)failure {
    PFQuery *friendsQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [friendsQuery whereKey:kUserModelForeignKeyName equalTo:self.parseUser];
    [friendsQuery whereKey:kUserFriendAttrConnected equalTo:[NSNumber numberWithBool:YES]];
    [friendsQuery countObjectsInBackgroundWithBlock:^(int num, NSError *error) {
        if (!error) {
            completion(num);
        } else {
            failure(error);
        }
    }];

}

- (void)requestFriend:(CKUser *)friendUser completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    // Existing request for me?
    PFQuery *requestorFriendRequestQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [requestorFriendRequestQuery whereKey:kUserModelForeignKeyName equalTo:self.parseUser];
    [requestorFriendRequestQuery whereKey:kUserFriendFriend equalTo:friendUser.parseUser];
    
    // Existing request from requestee?
    PFQuery *requesteeFriendRequestQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [requesteeFriendRequestQuery whereKey:kUserModelForeignKeyName equalTo:friendUser.parseUser];
    [requesteeFriendRequestQuery whereKey:kUserFriendFriend equalTo:self.parseUser];
    
    // Compound both to determine if any of the above is true?
    PFQuery *existingFriendRequestQuery = [PFQuery orQueryWithSubqueries:
                                           [NSArray arrayWithObjects:requestorFriendRequestQuery, requesteeFriendRequestQuery, nil]];
    [existingFriendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *friendRequests, NSError *error) {
        if (!error) {
            
            PFObject *requestorFriendRequest = nil;
            PFObject *requesteeFriendRequest = nil;
            BOOL newRequest = NO;
            
            if ([friendRequests count] > 0) {
                
                // Requestor request.
                NSInteger existingRequestorFriendRequestId = [friendRequests findIndexWithBlock:^BOOL(PFObject *parseFriendRequest) {
                    PFUser *parseUser = [parseFriendRequest objectForKey:kUserModelForeignKeyName];
                    return [parseUser.objectId isEqual:self.parseUser.objectId];
                }];
                if (existingRequestorFriendRequestId != -1) {
                    requestorFriendRequest = [friendRequests objectAtIndex:existingRequestorFriendRequestId];
                }
                
                // Requestee request.
                NSInteger existingRequesteeFriendRequestId = [friendRequests findIndexWithBlock:^BOOL(PFObject *parseFriendRequest) {
                    PFUser *parseUser = [parseFriendRequest objectForKey:kUserModelForeignKeyName];
                    return [parseUser.objectId isEqual:friendUser.parseUser.objectId];
                }];
                if (existingRequestorFriendRequestId != -1) {
                    requesteeFriendRequest = [friendRequests objectAtIndex:existingRequesteeFriendRequestId];
                }
                
                // If both were requestee's request, then we can connect them straight away.
                PFUser *requestorOriginUser = [requestorFriendRequest objectForKey:kUserFriendAttrRequestor];
                PFUser *requesteeOriginUser = [requesteeFriendRequest objectForKey:kUserFriendAttrRequestor];
                if ([requestorOriginUser.objectId isEqualToString:friendUser.parseUser.objectId]
                    && [requesteeOriginUser.objectId isEqualToString:friendUser.parseUser.objectId]) {
                    [requestorFriendRequest setObject:@YES forKey:kUserFriendAttrConnected];
                    [requesteeFriendRequest setObject:@YES forKey:kUserFriendAttrConnected];
                }
                
            } else {
                newRequest = YES;
                requestorFriendRequest = [CKUser createUserFriendObjectForUser:self.parseUser friend:friendUser.parseUser requestor:self.parseUser];
                requesteeFriendRequest = [CKUser createUserFriendObjectForUser:friendUser.parseUser friend:self.parseUser requestor:self.parseUser];
            }
            
            // Save requests.
            NSMutableArray *batchSaves = [NSMutableArray arrayWithArray:@[requestorFriendRequest, requesteeFriendRequest]];
            
            // Do we need a user notification?
            if (newRequest) {
                PFObject *parseNotification = [PFObject objectWithClassName:kUserNotificationModelName];
                [parseNotification setObject:friendUser.parseUser forKey:kUserModelForeignKeyName];
                [parseNotification setObject:kUserNotificationNameFriendRequest forKey:kModelAttrName];
                [parseNotification setObject:requesteeFriendRequest forKey:kUserNotificationUserFriend];
                [parseNotification setObject:@NO forKey:kUserNotificationUnread];
                [parseNotification setACL:[PFACL ACLWithUser:friendUser.parseUser]];
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

- (void)saveCoverPhoto:(UIImage *)coverPhoto completion:(ObjectSuccessBlock)completion {
    PFFile *coverPhotoFile = [PFFile fileWithName:@"cover.jpg" data:UIImageJPEGRepresentation(coverPhoto, 1.0)];
    [coverPhotoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.parseUser setObject:coverPhotoFile forKey:kUserAttrCoverPhoto];
        [self.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            completion();
        }];
    }];
}

- (PFFile *)parseCoverPhotoFile {
    return [self.parseUser objectForKey:kUserAttrCoverPhoto];
}

- (BOOL)hasCoverPhoto {
    return ([self parseCoverPhotoFile] != nil);
}

#pragma mark - Properties

- (void)setPassword:(NSString *)password {
    [self.parseObject setObject:password forKey:kUserAttrPassword];
}

- (NSString *)password {
    return [self.parseObject objectForKey:kUserAttrPassword];
}

- (void)setEmail:(NSString *)email {
    [self.parseObject setObject:email forKey:kUserAttrEmail];
}

- (NSString *)email {
    return [self.parseObject objectForKey:kUserAttrEmail];
}

- (void)setTheme:(DashTheme)theme {
    [self.parseObject setObject:@(theme) forKey:kUserAttrTheme];
}

- (DashTheme)theme {
    NSNumber *themeNumber = [self.parseObject objectForKey:kUserAttrTheme];
    if (themeNumber) {
        return [themeNumber integerValue];
    } else {
        return DashThemeReflect;
    }
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
                    
                    // Update push tokens.
                    [[CKServerManager sharedInstance] registerForPush];
                    
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
    
    return [self.objectId isEqualToString:user.objectId];
}

@end
