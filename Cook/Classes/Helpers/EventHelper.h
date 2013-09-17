//
//  EventHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 11/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRecipe.h"
#import "CKBook.h"

@interface EventHelper : NSObject

+ (void)registerLoginSucessful:(id)observer selector:(SEL)selector;
+ (void)postLoginSuccessful:(BOOL)success;
+ (void)unregisterLoginSucessful:(id)observer;
+ (BOOL)loginSuccessfulForNotification:(NSNotification *)notification;

+ (void)registerLogout:(id)observer selector:(SEL)selector;
+ (void)postLogout;
+ (void)unregisterLogout:(id)observer;

+ (void)registerBenchtopFreeze:(id)observer selector:(SEL)selector;
+ (void)postBenchtopFreeze:(BOOL)freeze;
+ (void)unregisterBenchtopFreeze:(id)observer;
+ (BOOL)benchFreezeForNotification:(NSNotification *)notification;

+ (void)registerOpenBook:(id)observer selector:(SEL)selector;
+ (void)postOpenBook:(BOOL)open;
+ (void)unregisterOpenBook:(id)observer;
+ (BOOL)openBookForNotification:(NSNotification *)notification;

+ (void)registerEditMode:(id)observer selector:(SEL)selector;
+ (void)postEditMode:(BOOL)editMode;
+ (void)postEditMode:(BOOL)editMode save:(BOOL)save;
+ (void)unregisterEditMode:(id)observer;
+ (BOOL)editModeForNotification:(NSNotification *)notification;
+ (BOOL)editModeSaveForNotification:(NSNotification *)notification;

+ (void)registerFollowUpdated:(id)observer selector:(SEL)selector;
+ (void)postFollow:(BOOL)follow book:(CKBook *)book;
+ (void)unregisterFollowUpdated:(id)observer;
+ (BOOL)followForNotification:(NSNotification *)notification;
+ (CKBook *)bookFollowForNotification:(NSNotification *)notification;

+ (void)registerLiked:(id)observer selector:(SEL)selector;
+ (void)postLiked:(BOOL)liked recipe:(CKRecipe *)recipe;
+ (void)unregisterLiked:(id)observer;
+ (BOOL)likedForNotification:(NSNotification *)notification;
+ (CKRecipe *)recipeForNotification:(NSNotification *)notification;

+ (void)registerThemeChange:(id)observer selector:(SEL)selector;
+ (void)postThemeChange;
+ (void)unregisterThemeChange:(id)observer;

+ (void)registerStatusBarChange:(id)observer selector:(SEL)selector;
+ (void)postStatusBarChangeUpdate;
+ (void)postStatusBarChangeForLight:(BOOL)light;
+ (BOOL)lightStatusBarChangeUpdateOnly:(NSNotification *)notification;
+ (BOOL)lightStatusBarChangeForNotification:(NSNotification *)notification;
+ (void)unregisterStatusBarChange:(id)observer;

+ (void)registerUserNotifications:(id)observer selector:(SEL)selector;
+ (void)postUserNotifications:(NSInteger)notificationsCount;
+ (NSInteger)userNotificationsCountForNotification:(NSNotification *)notification;
+ (void)unregisterUserNotifications:(id)observer;

// Image loading events.
+ (void)registerPhotoLoading:(id)observer selector:(SEL)selector;
+ (void)postPhotoLoadingImage:(UIImage *)image name:(NSString *)name thumb:(BOOL)thumb;
+ (BOOL)hasImageForPhotoLoading:(NSNotification *)notification;
+ (UIImage *)imageForPhotoLoading:(NSNotification *)notification;
+ (NSString *)nameForPhotoLoading:(NSNotification *)notification;
+ (BOOL)thumbForPhotoLoading:(NSNotification *)notification;
+ (void)unregisterPhotoLoading:(id)observer;
+ (void)registerPhotoLoadingProgress:(id)observer selector:(SEL)selector;
+ (void)postPhotoLoadingProgress:(CGFloat)progress name:(NSString *)name;
+ (CGFloat)progressForPhotoLoading:(NSNotification *)notification;
+ (void)unregisterPhotoLoadingProgress:(id)observer;

// Background fetch.
+ (void)registerBackgroundFetch:(id)observer selector:(SEL)selector;
+ (void)postBackgroundFetch;
+ (void)unregisterBackgroundFetch:(id)observer;

@end
