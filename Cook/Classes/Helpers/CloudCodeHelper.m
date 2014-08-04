//
//  CloudCodeHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 25/07/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CloudCodeHelper.h"
#import "AppHelper.h"

@implementation CloudCodeHelper

+ (NSDictionary *)commonCloudCodeParams {
    return [self commonCloudCodeParamsWithExtraParams:nil];
}

+ (NSDictionary *)commonCloudCodeParamsWithExtraParams:(NSDictionary *)extraParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if ([extraParams count] > 0) {
        [params addEntriesFromDictionary:extraParams];
    }
    
    // Add Cook version.
    [self safeAddToParams:params key:@"cookVersion" value:[[AppHelper sharedInstance] appVersion]];
    
    // Add user language.
    [self safeAddToParams:params key:@"cookLanguage" value:[AppHelper sharedInstance].languageCode];
    
    // Add user country.
    [self safeAddToParams:params key:@"cookCountry" value:[[AppHelper sharedInstance] localeCountryCode]];
    
    return params;
}

#pragma mark - Private methods

+ (void)safeAddToParams:(NSMutableDictionary *)params key:(NSString *)key value:(NSString *)value  {
    if ([key length] > 0 && [value length] > 0) {
        [params setObject:value forKey:key];
    }
}

@end
