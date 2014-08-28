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
@property (nonatomic, strong) RootViewController *rootViewController;

@end

@implementation AppDelegate

#define kFetchUpdateInterval    3600.0    // 1 hour.

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[CKServerManager sharedInstance] startWithLaunchOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootViewController = [[RootViewController alloc] init];
    self.window.rootViewController = self.rootViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Check if the time of last launch exceeded the expiry.
    NSTimeInterval lastLaunchedElapsedSeconds = ABS([self.lastLaunchedDate timeIntervalSinceNow]);
    DLog(@"lastLaunchedElapsedSeconds[%f] expiry[%f]", lastLaunchedElapsedSeconds, kFetchUpdateInterval);
    if (lastLaunchedElapsedSeconds > kFetchUpdateInterval) {
        DLog(@"trigger resume update");
        [EventHelper postDashFetchBackground:NO];
    }
    
    // Mark as launched date.
    self.lastLaunchedDate = [NSDate date];
    
    [[CKServerManager sharedInstance] handleActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url scheme] isEqualToString:@"cookapp"]) {
        [self openPageWithURL:url];
        return YES;
    }
    else if ([[url scheme] isEqualToString:[NSString stringWithFormat:@"fb%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"COOK_FACEBOOK_APP_ID"]]]) {
        return [[CKServerManager sharedInstance] handleFacebookCallback:url sourceApplication:sourceApplication
                                                         annotation:annotation];
    }
    else {
        return NO;
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    if ([userActivity.activityType isEqual:NSUserActivityTypeBrowsingWeb]) {
        [self openPageWithURL:userActivity.webpageURL];
    }
    return YES;
}
#endif

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

#pragma mark - Handle URL deep-linking

- (void)openPageWithURL:(NSURL *)url {
    NSArray *pathComponents = [url pathComponents];
    [pathComponents enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:@"recipe"] || [obj isEqualToString:@"recipes"]) {
            [self.rootViewController showModalWithRecipeID:[pathComponents objectAtIndex:(idx+1)]];
        }
    }];
}

//- (void)application:(UIApplication *)application
//    performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
//    DLog();
//    [EventHelper postDashFetchBackground:YES];
//    completionHandler(UIBackgroundFetchResultNewData);
//}

@end
