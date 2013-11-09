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
typedef void(^UserFriendSuccessBlock)(BOOL alreadySent, BOOL alreadyConnected, BOOL pendingAcceptance);
typedef void(^UserInfoSuccessBlock)(NSUInteger friendCount, NSUInteger followCount, NSUInteger recipeCount, BOOL areFriends);

typedef NS_ENUM(NSUInteger, DashTheme) {
    DashThemeReflect,
    DashThemeOppose,
    DashThemeVivid,
    DashThemeBalance
};

@interface CKUser : CKModel

@property (nonatomic, strong) PFUser *parseUser;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, strong) NSString *facebookEmail;
@property (nonatomic, readonly) BOOL admin;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) DashTheme theme;
@property (nonatomic, readonly) NSArray *facebookFriends;

// Cover photos.
@property (nonatomic, strong) PFFile *profilePhoto;

+ (CKUser *)currentUser;
+ (BOOL)isLoggedIn;
+ (void)loginWithFacebookCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)attachFacebookToCurrentUserWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)logoutWithCompletion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)registerWithEmail:(NSString *)email name:(NSString *)name password:(NSString *)password
               completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)loginWithEmail:(NSString *)email password:(NSString *)password completion:(ObjectSuccessBlock)success
               failure:(ObjectFailureBlock)failure;
+ (void)requestPasswordResetForEmail:(NSString *)email completion:(ObjectSuccessBlock)success
                             failure:(ObjectFailureBlock)failure;
+ (CKUser *)userWithParseUser:(PFUser *)parseUser;
+ (PFObject *)createUserFriendObjectForUser:(PFUser *)parseUser friend:(PFUser *)parseFriend requestor:(PFUser *)parseRequestor;
+ (BOOL)usernameExistsForSignUpError:(NSError *)error;
+ (BOOL)invalidCredentialsForSignInError:(NSError *)error;
+ (BOOL)isFacebookPermissionsError:(NSError *)error;
+ (BOOL)facebookAlreadyUsedInAnotherAccountError:(NSError *)error;
+ (void)setGuestTheme:(DashTheme)theme;
+ (DashTheme)currentTheme;
+ (NSURL *)defaultBlankProfileUrl;

- (id)initWithParseUser:(PFUser *)parseUser;
- (BOOL)isSignedIn;
- (BOOL)isFacebookUser;
- (NSArray *)bookSuggestionIds;
- (NSUInteger)numFollows;
- (NSURL *)profilePhotoUrl;
- (void)checkIsFriendsWithUser:(CKUser *)friendUser completion:(UserFriendSuccessBlock)completion failure:(ObjectFailureBlock)failure;
- (void)numFriendsCompletion:(NumObjectSuccessBlock)completion failure:(ObjectFailureBlock)failure;
- (void)requestFriend:(CKUser *)friendUser completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)ignoreRemoveFriendRequestFrom:(CKUser *)friendUser completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)saveCoverPhoto:(UIImage *)coverPhoto completion:(ObjectSuccessBlock)completion;
- (void)userInfoCompletion:(UserInfoSuccessBlock)completion failure:(ObjectFailureBlock)failure;
- (PFFile *)parseCoverPhotoFile;
- (BOOL)hasProfilePhoto;
- (NSString *)friendlyName;

// Notifications
- (void)numUnreadNotificationsCompletion:(NumObjectSuccessBlock)completion failure:(ObjectFailureBlock)failure;

@end
