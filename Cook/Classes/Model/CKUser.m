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

@interface CKUser ()

@property (nonatomic, copy) LoginSuccessBlock loginSuccessfulBlock;
@property (nonatomic, copy) ObjectFailureBlock loginFailureBlock;

- (void)populateUserDetailsFromFacebookData:(NSDictionary<PF_FBGraphUser>*)facebookUser;
+ (CKUser *)initialiseUserWithParseUser:(PFUser *)parseUser;

@end

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
    [self.parseObject setObject:facebookId forKey:kUserAttrFacebookId];
}

- (NSString *)facebookId {
    return [self.parseObject objectForKey:kUserAttrFacebookId];
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.facebookId] forKey:@"facebookId"];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:[self isSignedIn]] forKey:@"signedIn"];
    return descriptionProperties;
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
