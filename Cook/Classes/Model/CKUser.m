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
    return [[CKUser alloc] initWithParseUser:[PFUser currentUser]];
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

+ (void)logoutWithCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    [PFUser logOut];
    CKUser *loggedOutUser = [CKUser currentUser];
    [CKBook saveBookForUser:loggedOutUser
                   succeess:^{
                       DLog(@"Logged out and created new book for anonymous user.");
                       success();
                   } failure:^(NSError *error) {
                       DLog(@"Unable to create new book for anonymous user.");
                       failure(error);
                   }];
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

+ (void)populateUserDetailsFromFacebookData:(NSDictionary<PF_FBGraphUser> *)userData {
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

+ (void)handleAdminLoginFromFacebookData:(NSDictionary<PF_FBGraphUser> *)userData {
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
            
            // Save the username
            currentUser.name = [NSString CK_safeString:userData.name defaultString:kUserAttrDefaultNameValue];
            currentUser.facebookId = userData.id;
            
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
