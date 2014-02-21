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
#define kNewUserLoginSuccessful     @"CKNewUserLoginSuccessful"
#define kEventOpenBook              @"CKEventOpenBook"
#define kBoolOpenBook               @"CKBoolOpenBook"
#define kEventEditMode              @"CKEventEditMode"
#define kBoolEditMode               @"CKBoolEditMode"
#define kBoolEditModeSave           @"CKBoolEditModeSave"
#define kEventFollowUpdated         @"CKEventFollowUpdated"
#define kBoolFollow                 @"CKBoolFollow"
#define kBookFollow                 @"CKBookFollow"
#define kEventLogout                @"CKEventLogout"
#define kEventThemeChange           @"CKThemeChange"
#define kEventStatusBarChange       @"CKStatusBarChange"
#define kBoolHideStatusBar          @"CKStatusBarHide"
#define kBoolLightStatusBar         @"CKStatusBarLight"
#define kEventUserNotifications     @"CKUserNotifications"
#define kUserNotificationsCount     @"CKUserNotificationsCount"
#define kEventPhotoLoading          @"CKPhotoLoading"
#define kNamePhotoLoading           @"CKNamePhotoLoading"
#define kImagePhotoLoading          @"CKImagePhotoLoading"
#define kThumbPhotoLoading          @"CKThumbPhotoLoading"
#define kEventPhotoLoadingProgress  @"CKEventPhotoLoadingProgress"
#define kProgressPhotoLoading       @"CKProgressPhotoLoading"
#define kEventDashFetch             @"CKEventDashFetch"
#define kBoolDashFetchBackground    @"CKBoolDashFetchBackground"
#define kEventSocialUpdates         @"CKEventSocialUpdates"
#define kRecipeSocialUpdates        @"CKRecipeSocialUpdates"
#define kNumLikesSocialUpdates      @"CKNumLikesSocialUpdates"
#define kNumCommentsSocialUpdates   @"CKNumCommentsSocialUpdates"
#define kLikedSocialUpdates         @"CKLikedSocialUpdates"
#define kUserChangeNotification     @"UserChangedNotification"
#define kEventAppActive             @"CKEventAppActive"
#define kBoolAppActive              @"CKAppActive"

#pragma mark - Login successful event

+ (void)registerLoginSucessful:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventLoginSuccessful];
}

+ (void)postLoginSuccessful:(BOOL)success {
    [self postLoginSuccessful:success newUser:NO];
}

+ (void)postLoginSuccessful:(BOOL)success newUser:(BOOL)newUser {
    [EventHelper postEvent:kEventLoginSuccessful
              withUserInfo:@{ kBoolLoginSuccessful : @(success),
                              kNewUserLoginSuccessful : @(newUser) }];
}

+ (void)unregisterLoginSucessful:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventLoginSuccessful];
}

+ (BOOL)loginSuccessfulForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kBoolLoginSuccessful] boolValue];
}

+ (BOOL)loginSuccessfulNewUserForNotification:(NSNotification *)notification {
    return [[[notification userInfo] valueForKey:kNewUserLoginSuccessful] boolValue];
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

#pragma mark - User profile change

+ (void)registerUserChange:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kUserChangeNotification];
}

+ (void)postUserChangeWithUser:(CKUser *)newUser {
    [EventHelper postEvent:kUserChangeNotification withUserInfo:@{kUserKey:newUser}];
}

+ (void)unregisterUserChange:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kUserChangeNotification];
}

#pragma mark - Status bar change.

+ (void)registerStatusBarChange:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventStatusBarChange];
}

+ (void)postStatusBarChangeForLight:(BOOL)light {
    [EventHelper postEvent:kEventStatusBarChange withUserInfo:@{kBoolLightStatusBar : @(light)}];
}

+ (void)postStatusBarHide:(BOOL)hide {
    [EventHelper postEvent:kEventStatusBarChange withUserInfo:@{kBoolHideStatusBar : @(hide)}];
}

+ (BOOL)shouldHideStatusBarForNotification:(NSNotification *)notification {
    return ([[notification userInfo] objectForKey:kBoolHideStatusBar] != nil);
}

+ (BOOL)hideStatusBarForNotification:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kBoolHideStatusBar] boolValue];
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

+ (void)postUserNotifications {
    [EventHelper postEvent:kEventUserNotifications];
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
                                                             kNamePhotoLoading : (name == nil) ? @"" : name,
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

+ (void)registerDashFetch:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventDashFetch];
}

+ (void)postDashFetchBackground:(BOOL)background {
    [EventHelper postEvent:kEventDashFetch withUserInfo:@{ kBoolDashFetchBackground : @(background) }];
}

+ (void)unregisterDashFetch:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventDashFetch];
}

+ (BOOL)isBackgroundForDashFetch:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kBoolDashFetchBackground] boolValue];
}

#pragma mark - Social stuff.

+ (void)registerSocialUpdates:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventSocialUpdates];
}

+ (void)postSocialUpdatesNumLikes:(NSInteger)numLikes liked:(BOOL)liked recipe:(CKRecipe *)recipe {
    if (recipe == nil || ![recipe persisted]) {
        return;
    }
    [EventHelper postEvent:kEventSocialUpdates withUserInfo:@{
                                                              kRecipeSocialUpdates : recipe,
                                                              kNumLikesSocialUpdates : @(numLikes),
                                                              kLikedSocialUpdates : @(liked)
                                                              }];
}

+ (void)postSocialUpdatesNumComments:(NSInteger)numComments recipe:(CKRecipe *)recipe {
    if (recipe == nil || ![recipe persisted]) {
        return;
    }
    [EventHelper postEvent:kEventSocialUpdates withUserInfo:@{
                                                              kRecipeSocialUpdates : recipe,
                                                              kNumCommentsSocialUpdates : @(numComments)
                                                              }];
}

+ (void)unregisterSocialUpdates:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventSocialUpdates];
}

+ (BOOL)socialUpdatesHasNumLikes:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kNumLikesSocialUpdates] isKindOfClass:[NSNumber class]];
}

+ (BOOL)socialUpdatesHasNumComments:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kNumCommentsSocialUpdates] isKindOfClass:[NSNumber class]];
}

+ (BOOL)socialUpdatesLiked:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kLikedSocialUpdates] boolValue];
}

+ (NSInteger)numLikesForNotification:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kNumLikesSocialUpdates] integerValue];
}

+ (NSInteger)numCommentsForNotification:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kNumCommentsSocialUpdates] integerValue];
}

+ (CKRecipe *)socialUpdatesRecipeForNotification:(NSNotification *)notification {
    return [[notification userInfo] objectForKey:kRecipeSocialUpdates];
}

#pragma mark - Lifecycle events.

+ (void)registerAppActive:(id)observer selector:(SEL)selector {
    [EventHelper registerObserver:observer withSelector:selector toEventName:kEventAppActive];
}

+ (void)postAppActive:(BOOL)active {
    [EventHelper postEvent:kEventAppActive withUserInfo:@{ kBoolAppActive : @(active) } ];
}

+ (void)unregisterAppActive:(id)observer {
    [EventHelper unregisterObserver:observer toEventName:kEventAppActive];
}

+ (BOOL)appActiveForNotification:(NSNotification *)notification {
    return [[[notification userInfo] objectForKey:kBoolAppActive] boolValue];
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
//    DLog("postEvent[%@] userInfo[%@]", eventName, theUserInfo);
    
    // Post all events on main thread as all involve UI updates.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:theUserInfo];
    });
}

+ (void)unregisterObserver:(id)observer toEventName:(NSString *)eventName {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:eventName object:nil];
}

@end
