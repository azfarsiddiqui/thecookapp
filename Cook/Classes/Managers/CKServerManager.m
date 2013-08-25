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
#import "ParsePhotoStore.h"
#import "ImageHelper.h"
#import "CKRecipeImage.h"
#import <Parse/Parse.h>
#import <Crashlytics/Crashlytics.h>

@interface CKServerManager ()

@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSMutableDictionary *transientImages;

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
        
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.transientImages = [NSMutableDictionary dictionary];
        
        [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
        [EventHelper registerLogout:self selector:@selector(loggedOut:)];
    }
    return self;
}

- (void)startWithLaunchOptions:(NSDictionary *)launchOptions {
    
    // Set up Parse
    [Parse setApplicationId:@"36DsRqQPcsSgInjBmAiUYDHFtxkFqlxHnoli69VS"
                  clientKey:@"c4J2TvKqYVh7m7pfZRasve4HuySArVSDxpAOXmMN"];
    
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
    
    DLog(@"Started ServerManager");
}

- (void)handleActive {
    
    // Resets the badge.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
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

- (void)requestForCurrentLocation:(void(^)(double latitude, double longitude))completion
                          failure:(void(^)(NSError *error))failure {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            DLog(@"Got current location %@", geoPoint);
            completion(geoPoint.latitude, geoPoint.longitude);
        } else {
            DLog(@"Unable to get current location [%@]", [error localizedDescription]);
        }
    }];
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

#pragma mark - Image uploads.

- (void)uploadImage:(UIImage *)image recipe:(CKRecipe *)recipe {
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    __block UIBackgroundTaskIdentifier *backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
    }];
    
    // Fullsize and thumbnail.
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);  // Least compression.
    PFFile *imageFile = [PFFile fileWithName:@"fullsize.jpg" data:imageData];
    UIImage *thumbImage = [ImageHelper thumbImageForImage:image];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, 1.0);  // TODO Less compression?
    PFFile *thumbImageFile = [PFFile fileWithName:@"thumbnail.jpg" data:thumbImageData];
    
    // Create the wrapper object.
    CKRecipeImage *recipeImage = [CKRecipeImage recipeImage];
    recipeImage.imageUuid = [[NSUUID UUID] UUIDString];
    recipeImage.thumbImageUuid = [[NSUUID UUID] UUIDString];
    
    // Keep a reference of the recipe and its associated CKRecipeImage, it is assumed that the recipe has been persisted.
    [self.transientImages setObject:recipeImage forKey:recipe.objectId];
    
    // Save both in the photoStore temporarily.
    [self.photoStore storeImage:thumbImage forKey:recipeImage.thumbImageUuid];
    [self.photoStore storeImage:image forKey:recipeImage.imageUuid];
    
    // Now upload the thumb sized.
    [thumbImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            DLog(@"Thumbnail image uploaded successfully.");
            
            // Attach it to the recipe image.
            recipeImage.thumbImageFile = thumbImageFile;
            
            // Now upload fullsized.
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    
                    // Attach it to the recipe image.
                    recipeImage.imageFile = imageFile;
                    
                    // Save the recipe image to Parse.
                    [recipeImage saveInBackground:^{
                        
                        // Now associate it with the recipe.
                        recipe.recipeImage = recipeImage;
                        
                        // Save recipe image off.
                        [recipe saveInBackground];
                        
                    } failure:^(NSError *error) {
                        
                        // Clear the store of the temp images.
                        [self clearTransientImagesForRecipeImage:recipeImage];
                    }];
                    
                    // Clear the store of the temp images.
                    [self clearTransientImagesForRecipeImage:recipeImage];
                    NSLog(@"Fullsize image uploaded successfully");
                    
                } else {
                    DLog(@"Fullsize image error %@", [error localizedDescription]);
                    [self clearTransientImagesForRecipeImage:recipeImage];
                }
                
                // End background task.
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
            }];
            
        } else {
            
            DLog(@"Thumbnail image error %@", [error localizedDescription]);
            [self clearTransientImagesForRecipeImage:recipeImage];
            
            // End background task.
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    }];

}

- (UIImage *)imageForRecipe:(CKRecipe *)recipe {
    UIImage *image = nil;
    CKRecipeImage *transientRecipeImage = [self.transientImages objectForKey:recipe.objectId];
    if (transientRecipeImage) {
        image = [self.photoStore cachedImageForKey:transientRecipeImage.imageUuid];
    }
    return image;
}

- (UIImage *)thumbnailImageForRecipe:(CKRecipe *)recipe {
    UIImage *image = nil;
    CKRecipeImage *transientRecipeImage = [self.transientImages objectForKey:recipe.objectId];
    if (transientRecipeImage) {
        image = [self.photoStore cachedImageForKey:transientRecipeImage.thumbImageUuid];
    }
    return image;
}

- (CKRecipeImage *)recipeImageInTransitForRecipe:(CKRecipe *)recipe {
    CKRecipeImage *recipeImage = nil;
    if ([recipe persisted]) {
        recipeImage = [self.transientImages objectForKey:recipe.objectId];
    }
    return recipeImage;
}

#pragma mark - Private methods

- (void)clearTransientImagesForRecipeImage:(CKRecipeImage *)recipeImage {
    [self.photoStore removeImageForKey:recipeImage.imageUuid];
    [self.photoStore removeImageForKey:recipeImage.thumbImageUuid];
}

- (void)loggedIn:(NSNotification *)notification {
    
    // Register for push.
    [self registerForPush];
}

- (void)loggedOut:(NSNotification *)notification {
    
    // Remove owner from the current installation.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObjectForKey:kUserModelForeignKeyName];
    [currentInstallation saveInBackground];
    
}

@end
