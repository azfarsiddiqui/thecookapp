//
//  CKServerManager.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKServerManager.h"
#import "CKUser.h"
#import "EventHelper.h"
#import "ImageHelper.h"
#import "CKRecipeImage.h"
#import "CKPhotoManager.h"
#import "AppHelper.h"
#import <Parse/Parse.h>
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import "Flurry.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface CKServerManager ()

@end

@implementation CKServerManager

+ (CKServerManager *)sharedInstance {
    static dispatch_once_t pred;
    static CKServerManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKServerManager alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
}

- (id)init {
    if (self = [super init]) {
        [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
        [EventHelper registerLogout:self selector:@selector(loggedOut:)];
    }
    return self;
}

- (void)startWithLaunchOptions:(NSDictionary *)launchOptions {
    
    // Set up Parse
    [Parse setApplicationId:[AppHelper configValueForKey:@"PARSE_APP_ID"] clientKey:[AppHelper configValueForKey:@"PARSE_CLIENT_KEY"]];
    
    // Set up Parse analytics.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Clean up cached user.
    [CKUser forceLogoutUserIfRequired];
    
    // Register/refresh device tokens if logged in.
    if ([CKUser isLoggedIn]) {
        
        // Register for push.
        [self registerForPush];
        
        // Refresh user.
        [CKUser refreshCurrentUser];
    }
    
    // Set up Facebook
    [PFFacebookUtils initializeFacebook];
    
    // Crashlytics.
    [Fabric with:@[CrashlyticsKit]];
    
    // Flurry.
    [Flurry setCrashReportingEnabled:NO];
    [Flurry startSession:@"WDJK6ZN6RJH9MV54CVY8"];
    
    // Start up setup.
    [[CKPhotoManager sharedInstance] generateImageAssets];
    
    DLog(@"Started ServerManager iOS[%@]", [[AppHelper sharedInstance] systemVersion]);
}

- (void)handleActive {
    
    BOOL saveInstallation = NO;
    
    // Resets the badge.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    CKUser *currentUser = [CKUser currentUser];
    
    // Set the owner for this installation by associating with the currently logged on user if not set.
    if ([currentUser isSignedIn] && ![currentInstallation objectForKey:kUserModelForeignKeyName]) {
        [currentInstallation setObject:currentUser.parseUser forKey:kUserModelForeignKeyName];
        saveInstallation = YES;
    }
    
    // Update with app language code.
    [[AppHelper sharedInstance] handleActive];
    NSString *appLanguageCode = [AppHelper sharedInstance].languageCode;
    if ([appLanguageCode length] > 0) {
        [currentInstallation setObject:appLanguageCode forKey:kCookAppLanguageCode];
        saveInstallation = YES;
    }
    
    // Update with app country code.
    NSString *appCountryCode = [[AppHelper sharedInstance] localeCountryCode];
    if ([appCountryCode length] > 0) {
        [currentInstallation setObject:appCountryCode forKey:kCookAppCountryCode];
        saveInstallation = YES;
    }
    
    // Update badge if non-zero.
    if (currentInstallation.badge != 0) {
        
        currentInstallation.badge = 0;
        saveInstallation = YES;
    }
    
    // Save if required.
    if (saveInstallation) {
        [currentInstallation saveEventually];
    }
    
    // Re-activate FB.
    if ([currentUser isFacebookUser]) {
        [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    }
    
    // Post app active
    [EventHelper postAppActive:YES];
}

- (void)stop {
    DLog(@"Stopped ServerManager");
}

- (BOOL)handleFacebookCallback:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

#pragma mark - Push notifications

- (void)registerForPush {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
}

- (void)handleDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    // Set the owner for this installation by associating with the currently logged on user.
    CKUser *currentUser = [CKUser currentUser];
    if ([currentUser isSignedIn]) {
        [currentInstallation setObject:currentUser.parseUser forKey:kUserModelForeignKeyName];
    }
    
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveEventually];
}

- (void)handleDeviceTokenError:(NSError *)error {
    if ([error code] == 3010) {
        DLog(@"Push notifications don't work in the simulator!");
    } else {
        DLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)handlePushWithUserInfo:(NSDictionary *)userInfo {
    [EventHelper postUserNotifications];
}

#pragma mark - Private methods

- (void)loggedIn:(NSNotification *)notification {
    BOOL isSuccess = [EventHelper loginSuccessfulForNotification:notification];
    
    if (isSuccess) {
        
        // Set owner owner from the current installation.
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        CKUser *currentUser = [CKUser currentUser];
        if ([currentUser isSignedIn]) {
            [currentInstallation setObject:currentUser.parseUser forKey:kUserModelForeignKeyName];
        }
        [currentInstallation saveEventually];
        
        // Register for push.
        [self registerForPush];
        
        // Identifier the user.
        [Crashlytics setUserIdentifier:currentUser.parseUser.objectId];
    }
}

- (void)loggedOut:(NSNotification *)notification {
    
    // Remove owner from the current installation.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObjectForKey:kUserModelForeignKeyName];
    [currentInstallation saveEventually];
    
    // Remove crash identification.
    [Crashlytics setUserIdentifier:nil];
}

@end
