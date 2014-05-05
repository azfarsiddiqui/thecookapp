//
//  CKServerManager.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKRecipe;
@class CKRecipeImage;

@interface CKServerManager : NSObject

+ (CKServerManager *)sharedInstance;

- (void)startWithLaunchOptions:(NSDictionary *)launchOptions;
- (void)handleActive;
- (void)stop;

// Facebook integration.
- (BOOL)handleFacebookCallback:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

// Push notifications.
- (void)registerForPush;
- (void)handleDeviceToken:(NSData *)deviceToken;
- (void)handleDeviceTokenError:(NSError *)error;
- (void)handlePushWithUserInfo:(NSDictionary *)userInfo;

@end
