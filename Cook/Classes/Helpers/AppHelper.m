//
//  CKAppHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "AppHelper.h"
#import "AppDelegate.h"

@interface AppHelper ()

@end

@implementation AppHelper

#define kExistingVersion    @"COOK_EXISTING_VERSION"

+ (AppHelper *)sharedInstance {
    static dispatch_once_t pred;
    static AppHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[AppHelper alloc] init];
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

- (UIView *)rootView {
    return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

- (CGRect)fullScreenFrame {
    return [self rootView].bounds;
}

@end
