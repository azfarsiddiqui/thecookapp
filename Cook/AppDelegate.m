//
//  CKAppDelegate.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "CKServerManager.h"
#import "EventHelper.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSDate *lastLaunchedDate;

@end

@implementation AppDelegate

#define kFetchUpdateInterval    3600.0    // 1 hour.

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[CKServerManager sharedInstance] startWithLaunchOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[RootViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Check if the time of last launch exceeded the expiry.
    NSTimeInterval lastLaunchedElapsedSeconds = ABS([self.lastLaunchedDate timeIntervalSinceNow]);
    DLog(@"lastLaunchedElapsedSeconds[%f] expiry[%f]", lastLaunchedElapsedSeconds, kFetchUpdateInterval);
    if (lastLaunchedElapsedSeconds > kFetchUpdateInterval) {
        DLog(@"trigger resume update");
        [EventHelper postBackgroundFetch];
    }
    
    // Mark as launched date.
    self.lastLaunchedDate = [NSDate date];
    
    [[CKServerManager sharedInstance] handleActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[CKServerManager sharedInstance] handleFacebookCallback:url];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[CKServerManager sharedInstance] stop];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[CKServerManager sharedInstance] handleDeviceToken:deviceToken];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[CKServerManager sharedInstance] handleDeviceTokenError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[CKServerManager sharedInstance] handlePushWithUserInfo:userInfo];
}

- (void)application:(UIApplication *)application
    performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    DLog();
    [EventHelper postBackgroundFetch];
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
