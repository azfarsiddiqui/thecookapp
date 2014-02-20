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
#import "Flurry.h"

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
        [self registerForPush];
    }
    
    // Set up Facebook
    [PFFacebookUtils initializeFacebook];
    
    // Crashlytics.
    [Crashlytics startWithAPIKey:@"78b5ee31da5ef077dd802aa93ca267444ea27b07"];
    
    // Flurry.
    [Flurry setCrashReportingEnabled:NO];
    [Flurry startSession:@"WDJK6ZN6RJH9MV54CVY8"];
    
    // Start up setup.
    [[CKPhotoManager sharedInstance] generateImageAssets];
    
    DLog(@"Started ServerManager");
}

- (void)handleActive {
    
    BOOL saveInstallation = NO;
    
    // Resets the badge.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    // Set the owner for this installation by associating with the currently logged on user if not set.
    if ([CKUser isLoggedIn] && ![currentInstallation objectForKey:kUserModelForeignKeyName]) {
        [currentInstallation setObject:[CKUser currentUser].parseUser forKey:kUserModelForeignKeyName];
        saveInstallation = YES;
    }
    
    // Update badge if non-zero.
    if (currentInstallation.badge != 0) {
        
        // Inform received notification.
        [EventHelper postUserNotifications:currentInstallation.badge];
        
        currentInstallation.badge = 0;
        saveInstallation = YES;
    }
    
    // Save if required.
    if (saveInstallation) {
        [currentInstallation saveEventually];
    }
    
    // Post app active
    [EventHelper postAppActive:YES];
}

- (void)stop {
    DLog(@"Stopped ServerManager");
}

- (BOOL)handleFacebookCallback:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

#pragma mark - Push notifications

- (void)registerForPush {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
}

- (void)handleDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    // Set the owner for this installation by associating with the currently logged on user.
    if ([CKUser isLoggedIn]) {
        [currentInstallation setObject:[CKUser currentUser].parseUser forKey:kUserModelForeignKeyName];
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
    [PFPush handlePush:userInfo];
}

#pragma mark - Parse no connection error.

- (BOOL)noConnectionError:(NSError *)error {
    return ([error.domain isEqualToString:@"Parse"] && error.code == 100);
}

#pragma mark - Private methods

- (void)loggedIn:(NSNotification *)notification {
    BOOL isSuccess = [EventHelper loginSuccessfulForNotification:notification];
    
    if (isSuccess) {
        
        // Set owner owner from the current installation.
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if ([CKUser isLoggedIn]) {
            [currentInstallation setObject:[CKUser currentUser].parseUser forKey:kUserModelForeignKeyName];
        }
        [currentInstallation saveEventually];
        
        // Register for push.
        [self registerForPush];
        
        // Identifier the user.
        [Crashlytics setUserIdentifier:[PFUser currentUser].objectId];
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
