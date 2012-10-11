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

- (NSArray *)friendIds {
    return [self.parseUser objectForKey:kUserAttrFriends];
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.facebookId] forKey:@"facebookId"];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self isSignedIn]] forKey:@"signedIn"];
    return descriptionProperties;
}

#pragma mark - Private methods

+ (void)populateUserDetailsFromFacebookData:(NSDictionary<PF_FBGraphUser> *)userData {
    
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
            
            // Now grab and add friends to the current user.
            PFQuery *query = [PFUser query];
            [query whereKey:kUserAttrFacebookId containedIn:friendIds];
            [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
                if (error) {
                    loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                                     message:[NSString stringWithFormat:@"Unable to retrieve friends for %@", currentUser]]);
                    loginFailureBlock = nil;
                    loginSuccessfulBlock = nil;
                } else {
                    
                    // Add friends
                    NSArray *cookFriends = [friends collect:^id(PFUser *parseUser) {
                        return parseUser.objectId;
                    }];
                    DLog(@"Adding friends in Cook: %@", cookFriends);
                    [currentUser.parseUser addUniqueObjectsFromArray:cookFriends forKey:kUserAttrFriends];
                    
                    // Save facebook profile details.
                    currentUser.name = userData.name;
                    currentUser.facebookId = userData.id;
                    [currentUser saveEventually];
                    
                    // Call success completion.
                    loginSuccessfulBlock();
                    loginSuccessfulBlock = nil;
                    loginFailureBlock = nil;
                    
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

+ (CKUser *)initialiseUserWithParseUser:(PFUser *)parseUser {
    DLog(@"initialiseUserWithParseUser:%@", parseUser);
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

@end
