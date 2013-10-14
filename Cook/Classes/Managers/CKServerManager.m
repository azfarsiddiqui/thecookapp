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
    
    // Register/refresh device tokens if logged in.
    if ([CKUser isLoggedIn]) {
        [self registerForPush];
    }
    
    // Set up Facebook
    [PFFacebookUtils initializeFacebook];
    
    // Crashlytics.
    [Crashlytics startWithAPIKey:@"78b5ee31da5ef077dd802aa93ca267444ea27b07"];
    
    // Start up setup.
    [[CKPhotoManager sharedInstance] setupBooks];
    
    DLog(@"Started ServerManager");
}

- (void)handleActive {
    
    // Resets the badge.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        
        // Inform received notification.
        [EventHelper postUserNotifications:currentInstallation.badge];
        
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
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
    [currentInstallation saveInBackground];
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
    [currentInstallation saveInBackground];
    
    // Remove crash identification.
    [Crashlytics setUserIdentifier:nil];
}

@end
