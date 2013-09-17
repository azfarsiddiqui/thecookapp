//
//  EventHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "EventHelper.h"

@implementation EventHelper

#define kEventBenchtopFreeze        @"CKEventBenchtopFreeze"
#define kBoolBenchtopFreeze         @"CKBoolBenchtopFreeze"
#define kEventLoginSuccessful       @"CKEventLoginSuccessful"
#define kBoolLoginSuccessful        @"CKBoolLoginSuccessful"
#define kEventOpenBook              @"CKEventOpenBook"
#define kBoolOpenBook               @"CKBoolOpenBook"
#define kEventEditMode              @"CKEventEditMode"
#define kBoolEditMode               @"CKBoolEditMode"
#define kBoolEditModeSave           @"CKBoolEditModeSave"
#define kEventFollowUpdated         @"CKEventFollowUpdated"
#define kBoolFollow                 @"CKBoolFollow"
#define kBookFollow                 @"CKBookFollow"
#define kEventLogout                @"CKEventLogout"
#define kEventLike                  @"CKEventLike"
#define kBoolLike                   @"CKBoolLike"
#define kRecipeLike                 @"CKRecipeLike"
#define kEventThemeChange           @"CKThemeChange"
#define kEventStatusBarChange       @"CKStatusBarChange"
#define kBoolLightStatusBar         @"CKStatusBarLight"
#define kEventUserNotifications     @"CKUserNotifications"
#define kUserNotificationsCount     @"CKUserNotificationsCount"
#define kEventPhotoLoading          @"CKPhotoLoading"
#define kNamePhotoLoading           @"CKNamePhotoLoading"
#define kImagePhotoLoading          @"CKImagePhotoLoading"
#define kThumbPhotoLoading          @"CKThumbPhotoLoading"
#define kEventPhotoLoadingProgress  @"CKEventPhotoLoadingProgress"
#define kProgressPhotoLoading       @"CKProgressPhotoLoading"
#define kEventBackgroundFetch       @"CKEventBackgroundFetch"

#pragma mark - Login successful event

+ (void)registerLoginSucessful:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventLoginSuccessful];
}

+ (void)postLoginSuccessful:(BOOL)success {
    [EventHelper postEvent:kEventLoginSuccessful
              withUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:success]
                                                       forKey:kBoolLoginSuccessful]];
}

+ (void)unregisterLoginSucessful:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventLoginSuccessful];
}

+ (BOOL)loginSuccessfulForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolLoginSuccessful] boolValue];
}

#pragma mark - Logout 

+ (void)registerLogout:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventLogout];
}

+ (void)postLogout {
    [EventHelper postEvent:kEventLogout];
}

+ (void)unregisterLogout:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventLogout];
}

#pragma mark - Benchtop events

+ (void)registerBenchtopFreeze:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventBenchtopFreeze];
}

+ (void)postBenchtopFreeze:(BOOL)freeze {
    [EventHelper postEvent:kEventBenchtopFreeze
              withUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:freeze]
                                                       forKey:kBoolBenchtopFreeze]];
}

+ (void)unregisterBenchtopFreeze:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventBenchtopFreeze];
}

+ (BOOL)benchFreezeForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolBenchtopFreeze] boolValue];
}

#pragma mark - Book events

+ (void)registerOpenBook:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventOpenBook];
}

+ (void)postOpenBook:(BOOL)open {
    [EventHelper postEvent:kEventOpenBook
              withUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:open]
                                                       forKey:kBoolOpenBook]];
}

+ (void)unregisterOpenBook:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventOpenBook];
}

+ (BOOL)openBookForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolOpenBook] boolValue];
}

#pragma mark - Edit mode

+ (void)registerEditMode:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventEditMode];
}

+ (void)postEditMode:(BOOL)editMode {
    [self postEditMode:editMode save:NO];
}

+ (void)postEditMode:(BOOL)editMode save:(BOOL)save {
    [EventHelper postEvent:kEventEditMode
              withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:editMode], kBoolEditMode,
                            [NSNumber numberWithBool:save], kBoolEditModeSave,
                            nil]];
}

+ (void)unregisterEditMode:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventEditMode];
}

+ (BOOL)editModeForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolEditMode] boolValue];
}

+ (BOOL)editModeSaveForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolEditModeSave] boolValue];
}

#pragma mark - Follows

+ (void)registerFollowUpdated:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventFollowUpdated];
}

+ (void)postFollow:(BOOL)follow book:(CKBook *)book {
    [EventHelper postEvent:kEventFollowUpdated
              withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:follow], kBoolFollow,
                            book, kBookFollow,
                            nil]];
}

+ (void)unregisterFollowUpdated:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventFollowUpdated];
}

+ (BOOL)followForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolFollow] boolValue];
}

+ (CKBook *)bookFollowForNotification:(NSNotification *)notification {
    return [[notification userInfo] valueForKey:kBookFollow];
}

#pragma mark - Likes

+ (void)registerLiked:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventLike];
}

+ (void)postLiked:(BOOL)liked recipe:(CKRecipe *)recipe {
    [EventHelper postEvent:kEventLike
              withUserInfo:@{ kBoolLike : @(liked), kRecipeLike : recipe }];
}

+ (void)unregisterLiked:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventLike];
}

+ (BOOL)likedForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolLike] boolValue];
}

+ (CKRecipe *)recipeForNotification:(NSNotification *)notification {
    return [[notification userInfo] valueForKey:kRecipeLike];
}

#pragma mark - Theme change

+ (void)registerThemeChange:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventThemeChange];
}

+ (void)postThemeChange {
    [EventHelper postEvent:kEventThemeChange];
}

+ (void)unregisterThemeChange:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventThemeChange];
}

#pragma mark - Status bar change.

+ (void)registerStatusBarChange:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventStatusBarChange];
}

+ (void)postStatusBarChangeUpdate {
    [EventHelper postEvent:kEventStatusBarChange];
}

+ (void)postStatusBarChangeForLight:(BOOL)light {
    [EventHelper postEvent:kEventStatusBarChange withUserInfo:@{kBoolLightStatusBar : @(light)}];
}

+ (BOOL)lightStatusBarChangeUpdateOnly:(NSNotification *)notification {
    return ([[notification userInfo] objectForKey:kBoolLightStatusBar] == nil);
}

+ (BOOL)lightStatusBarChangeForNotification:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kBoolLightStatusBar] boolValue];
}

+ (void)unregisterStatusBarChange:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventStatusBarChange];
}

#pragma mark - User Notifications

+ (void)registerUserNotifications:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventUserNotifications];
}

+ (void)postUserNotifications:(NSInteger)notificationsCount {
    [EventHelper postEvent:kEventUserNotifications withUserInfo:@{ kUserNotificationsCount : @(notificationsCount) }];
}

+ (NSInteger)userNotificationsCountForNotification:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kUserNotificationsCount] integerValue];
}

+ (void)unregisterUserNotifications:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventUserNotifications];
}

#pragma mark Image loading events.

+ (void)registerPhotoLoading:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventPhotoLoading];
}

+ (void)postPhotoLoadingImage:(UIImage *)image name:(NSString *)name thumb:(BOOL)thumb {
    
    // Pass NSNull image if nil so that this doesn't crash when not loaded. A case might be when a user was trying to
    // load an image that doesn't yet have an image.
    [EventHelper postEvent:kEventPhotoLoading withUserInfo:@{
                                                             kImagePhotoLoading : (image == nil) ? [NSNull null] : image,
                                                             kNamePhotoLoading : name,
                                                             kThumbPhotoLoading : @(thumb)
                                                             }];
}

+ (BOOL)hasImageForPhotoLoading:(NSNotification *)notification {
    return ([[[notification userInfo] objectForKey:kImagePhotoLoading] isKindOfClass:[UIImage class]]);
}

+ (UIImage *)imageForPhotoLoading:(NSNotification *)notification {
    return [[notification userInfo] objectForKey:kImagePhotoLoading];
}

+ (NSString *)nameForPhotoLoading:(NSNotification *)notification {
    return [[notification userInfo] objectForKey:kNamePhotoLoading];
}

+ (BOOL)thumbForPhotoLoading:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kThumbPhotoLoading] boolValue];
}

+ (void)unregisterPhotoLoading:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventPhotoLoading];
}

+ (void)registerPhotoLoadingProgress:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventPhotoLoadingProgress];
}

+ (void)postPhotoLoadingProgress:(CGFloat)progress name:(NSString *)name {
    [EventHelper postEvent:kEventPhotoLoadingProgress withUserInfo:@{
                                                                     kProgressPhotoLoading : @(progress),
                                                                     kNamePhotoLoading : name
                                                                     }];
}

+ (CGFloat)progressForPhotoLoading:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kProgressPhotoLoading] floatValue];
}

+ (void)unregisterPhotoLoadingProgress:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventPhotoLoadingProgress];
}

#pragma mark - Background fetch.

+ (void)registerBackgroundFetch:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventBackgroundFetch];
}

+ (void)postBackgroundFetch {
    [EventHelper postEvent:kEventBackgroundFetch];
}

+ (void)unregisterBackgroundFetch:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventBackgroundFetch];
}

#pragma mark - Private

+ (void)registerObserver:(id)observer withSelector:(SEL)selector toEventName:(NSString *)eventName {
    [[NSNotificationCenter defaultCenter] addObserver:observer
                                             selector:selector
                                                 name:eventName object:nil];
}

+ (void)postEvent:(NSString *)eventName {
    [EventHelper postEvent:eventName withUserInfo:nil];
}

+ (void)postEvent:(NSString *)eventName withUserInfo:(NSDictionary *)theUserInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:theUserInfo];
}

+ (void)unregisterObserver:(id)observer toEventName:(NSString *)eventName {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:eventName object:nil];
}

@end
