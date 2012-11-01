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

#pragma mark - CKModel 

- (NSString *)objectId {
    return [self.parseUser objectForKey:kModelAttrId];
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

- (BOOL)isAdmin {
    return [[self.parseUser objectForKey:kUserAttrAdmin] boolValue];
}

// This method gets all the auto-suggests that was created for the current user, then consolidates them as single
// entries for myself.
- (void)autoSuggestCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    // Get all my suggested follow's and consolidate them.
    PFQuery *followRequestQuery = [PFQuery queryWithClassName:kBookFollowModelName];
    [followRequestQuery whereKey:kUserModelForeignKeyName equalTo:self.parseUser];
    [followRequestQuery whereKey:kBookFollowAttrSuggest equalTo:[NSNumber numberWithBool:YES]];
    [followRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *followRequests, NSError *error) {
        if (!error) {
            
            NSMutableArray *objectsToUpdate = [NSMutableArray array];
            
            // Get unique object ids of books.
            NSMutableSet *uniqueFollowRequests = [NSMutableSet set];
            for (PFObject *followRequest in followRequests) {
                PFObject *book = [followRequest objectForKey:kBookModelForeignKeyName];
                [uniqueFollowRequests addObject:book.objectId];
            }
            
            // Create book follow suggests.
            for (NSString *bookObjectId in uniqueFollowRequests) {
                PFObject *friendBookFollow = [PFObject objectWithClassName:kBookFollowModelName];
                [friendBookFollow setObject:self.parseUser forKey:kUserModelForeignKeyName];
                [friendBookFollow setObject:[PFObject objectWithoutDataWithClassName:kBookModelName objectId:bookObjectId]
                                     forKey:kBookModelForeignKeyName];
                [friendBookFollow setObject:[NSNumber numberWithBool:YES] forKey:kBookFollowAttrSuggest];
                [friendBookFollow setObject:[NSNumber numberWithBool:YES] forKey:kBookFollowAttrMerge];
                [objectsToUpdate addObject:friendBookFollow];
            }
            
            // Save all in background.
            [PFObject saveAllInBackground:objectsToUpdate block:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    
                    // Delete the auto follow requests.
                    [followRequests makeObjectsPerformSelector:@selector(deleteInBackground)];
                    DLog(@"Deleted follow requests.");
                    
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
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self isAdmin]] forKey:kUserAttrAdmin];
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
                    PFObject *adminBookFollow = [PFObject objectWithClassName:kBookFollowModelName];
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
            
            // My book query.
            PFQuery *myBookQuery = [PFQuery queryWithClassName:kBookModelName];
            [myBookQuery whereKey:kUserModelForeignKeyName equalTo:currentUser.parseUser];
            
            // Friends query.
            PFQuery *usersQuery = [PFUser query];
            [usersQuery whereKey:kUserAttrFacebookId containedIn:friendIds];
                        
            // Get suggested books and make them as follow requests.
            PFQuery *otherBooksQuery = [PFQuery queryWithClassName:kBookModelName];
            [otherBooksQuery whereKey:kUserModelForeignKeyName matchesQuery:usersQuery];
            
            // Combine both books query.
            PFQuery *booksQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:myBookQuery, otherBooksQuery, nil]];
            [booksQuery includeKey:kUserModelForeignKeyName];  // Load associated user.
            [booksQuery findObjectsInBackgroundWithBlock:^(NSArray *books, NSError *error) {
                
                if (error) {
                    
                    loginFailureBlock([CKModel errorWithCode:kCKLoginFriendsErrorCode
                                                     message:[NSString stringWithFormat:@"Unable to retrieve follow books for %@", currentUser]]);
                    loginFailureBlock = nil;
                    loginSuccessfulBlock = nil;
                    
                } else {
                    
                    // Prepare objects to update in bulk: follow requests and my profile.
                    NSMutableArray *objectsToUpdate = [NSMutableArray array];
                    
                    // Save facebook profile details.
                    currentUser.name = [NSString CK_safeString:userData.name defaultString:kUserAttrDefaultNameValue];
                    currentUser.facebookId = userData.id;
                    [objectsToUpdate addObject:currentUser.parseUser];
                    
                    // My books.
                    NSArray *myBooks = [books select:^BOOL(PFObject *parseBook) {
                        PFUser *parseUser = [parseBook objectForKey:kUserModelForeignKeyName];
                        return [parseUser.objectId isEqualToString:currentUser.parseUser.objectId];
                    }];
                    
                    // Friends' books.
                    NSArray *friendsBooks = [books reject:^BOOL(PFObject *parseBook) {
                        PFUser *parseUser = [parseBook objectForKey:kUserModelForeignKeyName];
                        return [parseUser.objectId isEqualToString:currentUser.parseUser.objectId];
                    }];
                    
                    // Now create interim follow suggestions for myself of my friends' books.
                    for (PFObject *parseBook in friendsBooks) {
                        
                        PFUser *parseFriend = [parseBook objectForKey:kUserModelForeignKeyName];
                        
                        // Loop through my books and add them as follow to my friend.
                        for (PFObject *myBook in myBooks) {
                            
                            // Create suggested follow of my book for my friends.
                            PFObject *friendBookFollow = [PFObject objectWithClassName:kBookFollowModelName];
                            [friendBookFollow setObject:parseFriend forKey:kUserModelForeignKeyName];
                            [friendBookFollow setObject:myBook forKey:kBookModelForeignKeyName];
                            [friendBookFollow setObject:[NSNumber numberWithBool:YES] forKey:kBookFollowAttrSuggest];
                            
                            // Only myself and my friend can read/write the request.
                            PFACL *followACL = [PFACL ACLWithUser:currentUser.parseUser];
                            [followACL setWriteAccess:YES forUser:parseFriend];
                            [followACL setReadAccess:YES forUser:parseFriend];
                            friendBookFollow.ACL = followACL;
                            [objectsToUpdate addObject:friendBookFollow];
                        }
                        
                        // Create suggested follow for myself of my friend's book.
                        PFObject *myBookFollow = [PFObject objectWithClassName:kBookFollowModelName];
                        [myBookFollow setObject:currentUser.parseUser forKey:kUserModelForeignKeyName];
                        [myBookFollow setObject:parseBook forKey:kBookModelForeignKeyName];
                        [myBookFollow setObject:[NSNumber numberWithBool:YES] forKey:kBookFollowAttrSuggest];
                        [objectsToUpdate addObject:myBookFollow];
                    }
                    
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
