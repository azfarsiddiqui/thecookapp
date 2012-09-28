//
//  CKAppHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKAppHelper.h"

@interface CKAppHelper ()

@end

@implementation CKAppHelper

#define kExistingVersion    @"COOK_EXISTING_VERSION"

+ (CKAppHelper *)sharedInstance {
    static dispatch_once_t pred;
    static CKAppHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKAppHelper alloc] init];
    });
    return sharedInstance;
}

- (BOOL)newInstall {
    BOOL newInstall = NO;
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *existingVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kExistingVersion];
    if (existingVersion) {
        if ([[currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue] > [[existingVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue]) {
            newInstall = YES;
        }
        
    } else {
        newInstall = YES;
    }
    
    if (newInstall) {
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kExistingVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return newInstall;
}

@end
