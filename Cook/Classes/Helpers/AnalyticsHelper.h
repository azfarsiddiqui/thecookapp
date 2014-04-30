//
//  AnalyticsHelper.h
//  Cook
//
//  Created by Gerald Kim on 8/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsHelper : NSObject

#pragma mark - Events

extern NSString *const kEventLibraryView;
extern NSString *const kEventLibraryBookSummaryView;

extern NSString *const kEventBookView;
extern NSString *const kEventBookLoad;
extern NSString *const kEventBookAdd;
extern NSString *const kEventBookDelete;
extern NSString *const kEventPageView;

extern NSString *const kEventSearch;

extern NSString *const kEventRecipeView;
extern NSString *const kEventRecipeSave;
extern NSString *const kEventRecipeShare;
extern NSString *const kEventRecipeComment;
extern NSString *const kEventRecipeLike;
extern NSString *const kEventRecipePin;
extern NSString *const kEventRecipeSocialView;

extern NSString *const kEventNotificationsView;
extern NSString *const kEventSearchView;
extern NSString *const kEventSearchSubmit;

#pragma mark - Properties

extern NSString *const kEventParamsBookPageName;
extern NSString *const kEventParamsBookPageIndex;
extern NSString *const kEventParamsSearchFilter;

#pragma mark - Tracking methods

+ (void)trackEventName:(NSString *)eventName;
+ (void)trackEventName:(NSString *)eventName params:(NSDictionary *)params;
+ (void)trackEventName:(NSString *)eventName params:(NSDictionary *)params timed:(BOOL)timed;
+ (void)endTrackEventName:(NSString *)eventName;
+ (void)endTrackEventName:(NSString *)eventName params:(NSDictionary *)params;

@end
