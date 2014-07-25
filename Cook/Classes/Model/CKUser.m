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
#import "EventHelper.h"
#import "AppHelper.h"
#import "CloudCodeHelper.h"

@interface CKUser ()

@end

static ObjectSuccessBlock loginSuccessfulBlock = nil;
static ObjectSuccessBlock facebookLoginSuccessfulBlock = nil;
static ObjectFailureBlock loginFailureBlock = nil;

@implementation CKUser

#define kCookGuestTheme         @"kCookGuestTheme"
#define kCookGuestMeasure       @"kCookGuestMeasure"
#define kCookForceLogout        @"CookForceLogout"

+ (CKUser *)currentUser {
//    DLog(@"%@", [NSThread callStackSymbols]);
    PFUser *parseUser = [PFUser currentUser];
    if (parseUser) {
        return [[CKUser alloc] initWithParseUser:parseUser];
    } else {
        return nil;
    }
}

+ (void)refreshCurrentUser {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [[PFUser currentUser] refresh];
    });
}

+ (BOOL)isLoggedIn {
    return ([CKUser currentUser] != nil);
}

+ (void)forceLogoutUserIfRequired {
    
    // If force logout was indicated, then do it.
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:kCookForceLogout] boolValue]) {
        DLog(@"Forced logout");
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCookForceLogout];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [PFUser logOut];
    }
}

+ (void)forceLogout {
    DLog();
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCookForceLogout];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)loginWithFacebookCompletion:(FacebookSuccessBlock)success failure:(ObjectFailureBlock)failure {
    CKUser *currentUser = [CKUser currentUser];
    
    // Make sure user is not signed on already.
    if ([currentUser isSignedIn]) {
        failure([CKModel errorWithMessage:[NSString stringWithFormat:@"User %@ already signed in", currentUser]]);
        return;
    }
    
    // Copies and saves the completion blocks.
    facebookLoginSuccessfulBlock = [success copy];
    loginFailureBlock = [failure copy];
    
    // Go ahead and link this user via Facebook.
    DLog(@"Linking user with facebook %@", self);
    [PFFacebookUtils logInWithPermissions:@[@"email"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                loginFailureBlock([CKModel errorWithCode:kCKLoginCancelledErrorCode
                                                 message:[NSString stringWithFormat:@"User %@ cancelled signin", currentUser]]);
            } else {
                loginFailureBlock(error);
            }
            loginFailureBlock = nil;
            facebookLoginSuccessfulBlock = nil;
            
        } else {
            
            // Logged in, now update user details and friends.
            [self updateFacebookLoginDataIsNewUser:user.isNew];
        }
    }];
}

+ (void)updateFacebookLoginData {
    [self updateFacebookLoginDataIsNewUser:NO];
}

+ (void)updateFacebookLoginDataIsNewUser:(BOOL)isNewUser {
    
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary<FBGraphUser> *userData,
       NSError *error) {
         if (error) {
             loginFailureBlock(error);
             loginFailureBlock = nil;
             facebookLoginSuccessfulBlock = nil;
         } else {
             [CKUser populateUserDetailsFromFacebookData:userData isNewUser:isNewUser];
         }
     }];
}

+ (void)attachFacebookToCurrentUserWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure
{
    CKUser *currentUser = [CKUser currentUser];
    if (![currentUser isSignedIn]) {
        failure([CKModel errorWithMessage:[NSString stringWithFormat:@"User %@ not signed in", currentUser]]);
        return;
    }
    
    // Copies and saves the completion blocks.
    loginSuccessfulBlock = [success copy];
    loginFailureBlock = [failure copy];
    
    // Go ahead and link this user via Facebook.
    DLog(@"Linking user with facebook %@", self);
    [PFFacebookUtils linkUser:currentUser.parseUser permissions:@[@"user_friends"] block:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
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
                     [CKUser populateUserDetailsFromFacebookData:userData isNewUser:NO];
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
            success();
        } else {
            failure(error);
        }
    }];
    
}

+ (void)requestPasswordResetForEmail:(NSString *)email completion:(ObjectSuccessBlock)success
                             failure:(ObjectFailureBlock)failure {
    
    DLog(@"Requesting password reset for Email[%@]", email);
    [PFUser requestPasswordResetForEmailInBackground:email
                                               block:^(BOOL succeeded, NSError *error) {
                                                   if (!error) {
                                                       DLog(@"Requested email");
                                                       success();
                                                   } else {
                                                       DLog(@"Error: %@", [error localizedDescription]);
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

+ (BOOL)invalidCredentialsForSignInError:(NSError *)error {
    return ([error code] == kPFErrorObjectNotFound);
}

+ (BOOL)isFacebookPermissionsError:(NSError *)error {
    return ([error.domain isEqualToString:@"com.facebook.sdk"] && [error code] == FBErrorLoginFailedOrCancelled);
}

+ (BOOL)facebookAlreadyUsedInAnotherAccountError:(NSError *)error {
    return ([error.domain isEqualToString:@"Parse"] && [error code] == kPFErrorFacebookAccountAlreadyLinked);
}

+ (void)setGuestTheme:(DashTheme)theme {
    [[NSUserDefaults standardUserDefaults] setObject:@(theme) forKey:kCookGuestTheme];
}

+ (DashTheme)currentTheme {
    return DashThemeReflect;
}

+ (void)setGuestMeasure:(CKMeasurementType)measureType {
    [[NSUserDefaults standardUserDefaults] setObject:@(measureType) forKey:kCookGuestMeasure];
}

+ (CKMeasurementType)currentMeasureType {
    CKUser *currentUser = [CKUser currentUser];
    if (currentUser) {
        return currentUser.measurementType;
    } else if ([[NSUserDefaults standardUserDefaults] objectForKey:kCookGuestMeasure]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kCookGuestMeasure] integerValue];
    } else {
        return CKMeasureTypeMetric;
    }
}

+ (CKMeasurementType)currentMeasureTypeForUser:(CKUser *)user {
    if (user) {
        return user.measurementType;
    } else if ([[NSUserDefaults standardUserDefaults] objectForKey:kCookGuestMeasure]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:kCookGuestMeasure] integerValue];
    } else {
        return CKMeasureTypeMetric;
    }
}

+ (NSURL *)defaultBlankProfileUrl {
    static dispatch_once_t pred;
    static NSURL *sharedProfileUrl = nil;
    dispatch_once(&pred, ^{
        sharedProfileUrl = [[NSBundle mainBundle] URLForResource:@"cook_default_profile" withExtension:@"png"];
    });
    return sharedProfileUrl;
}

#pragma mark - CKModel 

- (NSString *)objectId {
    return self.parseUser.objectId;
}

#pragma mark - CKUser

- (BOOL)isSignedIn {
    return (self.parseUser != nil);
}

- (BOOL)isFacebookUser {
    return [self isSignedIn] && [PFFacebookUtils isLinkedWithUser:self.parseUser];
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
    return [self constructProfilePhotoUrl];
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
    
    DLog(@"Process friend connections between [%@] and [%@].", self.objectId, friendUser.objectId);
    
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

- (void)ignoreRemoveFriendRequestFrom:(CKUser *)friendUser completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
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
            
            // Delete all friend requests and UserNotification.
            if ([friendRequests count] > 0) {
                
                // Delete the friend requests.
                DLog(@"Deleting friend connections between [%@] and [%@].", self.objectId, friendUser.objectId);
                [PFObject deleteAllInBackground:friendRequests block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        
                        // Delete notification.
                        PFQuery *notificationQuery = [PFQuery queryWithClassName:kUserNotificationModelName];
                        [notificationQuery whereKey:kModelAttrName equalTo:kUserNotificationTypeFriendRequest];
                        [notificationQuery whereKey:kUserModelForeignKeyName equalTo:self.parseUser];
                        [notificationQuery whereKey:kUserNotificationAttrActionUser equalTo:friendUser.parseUser];
                        [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *notifications, NSError *error) {
                            [PFObject deleteAllInBackground:notifications block:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    success();
                                } else {
                                    failure(error);
                                }
                            }];
                        }];
                        
                        
                    } else {
                        failure(error);
                    }
                }];
                
            }
            
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

- (void)userInfoCompletion:(UserInfoSuccessBlock)completion failure:(ObjectFailureBlock)failure {
    [PFCloud callFunctionInBackground:@"userInfo"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{ @"userId" : self.objectId }]
                                block:^(NSDictionary *results, NSError *error) {
                                    
                                    NSUInteger friendCount = [[results objectForKey:@"friendCount"] unsignedIntegerValue];
                                    NSUInteger followCount = [[results objectForKey:@"followCount"] unsignedIntegerValue];
                                    NSUInteger recipeCount = [[results objectForKey:@"recipeCount"] unsignedIntegerValue];
                                    BOOL areFriends = [[results objectForKey:@"areFriends"] boolValue];
                                    
                                    if (!error) {
                                        completion(friendCount, followCount, recipeCount, areFriends);
                                    } else {
                                        DLog(@"Error loading user info: %@", [error localizedDescription]);
                                    }
                                }];

}

- (PFFile *)parseCoverPhotoFile {
    return [self.parseUser objectForKey:kUserAttrCoverPhoto];
}

- (BOOL)hasProfilePhoto {
    PFFile *profilePhoto = [self.parseUser objectForKey:kUserAttrProfilePhoto];
    return ((profilePhoto != nil) || [self.facebookId length] > 0);
}

- (NSString *)friendlyName {
    NSString *friendlyName = self.firstName;
    if (![friendlyName CK_containsText]) {
        friendlyName = [[self.name componentsSeparatedByString:@" "] firstObject];
    }
    return friendlyName;
}

- (void)numUnreadNotificationsCompletion:(NumObjectSuccessBlock)completion failure:(ObjectFailureBlock)failure {
    [PFCloud callFunctionInBackground:@"unreadNotificationsCount"
                       withParameters:[CloudCodeHelper commonCloudCodeParams]
                                block:^(NSDictionary *results, NSError *error) {
                                    NSInteger unreadCount = [[results objectForKey:@"unread"] integerValue];
                                    if (!error) {
                                        completion(unreadCount);
                                    } else {
                                        failure(error);
                                    }
                                }];
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

- (void)setFacebookEmail:(NSString *)facebookEmail {
    [self.parseObject setObject:facebookEmail forKey:kUserAttrFacebookEmail];
}

- (NSString *)facebookEmail {
    return [self.parseObject objectForKey:kUserAttrFacebookEmail];
}

- (void)setTheme:(DashTheme)theme {
    [self.parseObject setObject:@(theme) forKey:kUserAttrTheme];
}

- (DashTheme)theme {
    return DashThemeReflect;
}

- (void)setMeasurementType:(NSInteger)measurementType {
    
    CKMeasurementType currentMeasurementType = [self measurementType];
    if (currentMeasurementType != measurementType) {
        [self.parseObject setObject:@(measurementType) forKey:kUserAttrMeasureType];
        [self.parseObject saveInBackground];
    }
}

- (NSInteger)measurementType {
    NSNumber *measureNumber = [self.parseObject objectForKey:kUserAttrMeasureType];
    if (measureNumber) {
        return [measureNumber integerValue];
    } else {
        //If not set yet, try to guess preferred measurement type based on locale
        NSInteger measureType = CKMeasureTypeNone;
        NSString *countryCode = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
        if ([countryCode isEqualToString:@"US"]) {
            measureType = CKMeasureTypeImperial;
        } else if (countryCode) {
            measureType = CKMeasureTypeMetric;
        } else {
            measureType = CKMeasureTypeNone;
        }
        return measureType;
    }
}

- (void)setProfilePhoto:(PFFile *)profilePhoto {
    if (!profilePhoto) {
        return;
    }
    [self.parseObject setObject:profilePhoto forKey:kUserAttrProfilePhoto];
    [EventHelper postUserChangeWithUser:self];
}

- (PFFile *)profilePhoto {
    return [self.parseObject objectForKey:kUserAttrProfilePhoto];
}

- (NSArray *)facebookFriends {
    return [self.parseUser objectForKey:kUserAttrFacebookFriends];
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.facebookId] forKey:kUserAttrFacebookId];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self isSignedIn]] forKey:@"signedIn"];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:self.admin] forKey:kUserAttrAdmin];
    [descriptionProperties setValue:[NSString stringWithFormat:@"%i", [[self.parseUser objectForKey:kUserAttrFacebookFriends] count]]
                             forKey:@"facebookFriends"];
    return descriptionProperties;
}

#pragma mark - Private methods

+ (void)populateUserDetailsFromFacebookData:(NSDictionary<FBGraphUser> *)userData isNewUser:(BOOL)isNewUser {
    
    // Find the user's friends and update it.
    [[FBRequest requestForMyFriends] startWithCompletionHandler:^(FBRequestConnection *connection,
                                                                     NSDictionary *jsonDictionary, NSError *error) {
        CKUser *currentUser = [CKUser currentUser];
        
        if (!error) {
            
            // Grab the facebook ids of friends.
            NSArray *friendIds = [[jsonDictionary objectForKey:@"data"] collect:^id(NSDictionary<FBGraphUser> *friendData) {
                return [friendData objectForKey:@"id"];
            }];
            
            // Save the username
            currentUser.name = [NSString CK_safeString:userData.name defaultString:kUserAttrDefaultNameValue];
            currentUser.facebookId = [userData objectForKey:@"id"];
            currentUser.firstName = userData.first_name;
            currentUser.lastName = userData.last_name;
            
            // Facebook email if given.
            NSString *facebookEmail = [userData objectForKey:@"email"];
            if ([facebookEmail length] > 0) {
                currentUser.facebookEmail = facebookEmail;
            }
            
            // Store the facebook friends ids.
            [currentUser.parseUser addUniqueObjectsFromArray:friendIds forKey:kUserAttrFacebookFriends];
            
            // Save it off.
            [currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    facebookLoginSuccessfulBlock(isNewUser);
                    facebookLoginSuccessfulBlock = nil;
                    loginFailureBlock = nil;
                    
                } else {
                    loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                                     message:[NSString stringWithFormat:@"Unable to save friends for %@", currentUser]]);
                    loginFailureBlock = nil;
                    facebookLoginSuccessfulBlock = nil;
                }
            }];
            
        } else {
            
            loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                             message:[NSString stringWithFormat:@"Unable to retrieve friends for %@", currentUser]]);
            loginFailureBlock = nil;
            facebookLoginSuccessfulBlock = nil;
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

- (NSURL *)constructProfilePhotoUrl {
    NSURL *pictureUrl = nil;
    
    // CHeck profilePhoto first before falling back to FB photo.
    PFFile *profilePhoto = [self.parseUser objectForKey:kUserAttrProfilePhoto];
    if (profilePhoto != nil) {
        pictureUrl = [NSURL URLWithString:profilePhoto.url];
    } else if ([self.facebookId length] > 0) {
        pictureUrl = [NSURL URLWithString:
                      [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", self.facebookId]];
    } else {
        pictureUrl = [CKUser defaultBlankProfileUrl];
    }
    return pictureUrl;
}

@end
