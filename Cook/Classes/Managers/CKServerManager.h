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
- (BOOL)handleFacebookCallback:(NSURL *)url;

// Geolocation.
- (void)requestForCurrentLocation:(void(^)(double latitude, double longitude))completion
                          failure:(void(^)(NSError *error))failure;

// Push notifications.
- (void)registerForPush;
- (void)handleDeviceToken:(NSData *)deviceToken;
- (void)handleDeviceTokenError:(NSError *)error;
- (void)handlePushWithUserInfo:(NSDictionary *)userInfo;

// Image uploads.
- (void)uploadImage:(UIImage *)image recipe:(CKRecipe *)recipe;
- (UIImage *)imageForRecipe:(CKRecipe *)recipe;
- (UIImage *)thumbnailImageForRecipe:(CKRecipe *)recipe;
- (CKRecipeImage *)recipeImageInTransitForRecipe:(CKRecipe *)recipe;

@end
