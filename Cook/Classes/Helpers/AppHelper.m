//
//  CKAppHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "AppHelper.h"
#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppHelper ()

@end

@implementation AppHelper

#define kCookInstalledVersion   @"CKInstalledVersion"

+ (AppHelper *)sharedInstance {
    static dispatch_once_t pred;
    static AppHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[AppHelper alloc] init];
    });
    return sharedInstance;
}

- (BOOL)isNewUpdate {
    BOOL newInstall = NO;
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *existingVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kCookInstalledVersion];
    if (existingVersion) {
        if ([[currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue] > [[existingVersion stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue]) {
            newInstall = YES;
        }
    } else {
        newInstall = YES;
    }
    
    return newInstall;
}

- (void)maskAsNewUpdate:(BOOL)update {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (update) {
            NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kCookInstalledVersion];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCookInstalledVersion];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

- (UIView *)rootView {
    return [self rootViewController].view;
}

- (RootViewController *)rootViewController {
    return (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}

- (NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (BOOL)systemVersionAtLeast:(NSString *)version {
    return ([[self systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending);
}

- (CGRect)fullScreenFrame {
    return [self rootView].bounds;
}

- (CGFloat)screenScale {
    return [UIScreen mainScreen].scale;
}

- (BOOL)isRetina {
    return ([self screenScale] == 2.0);
}

- (NSArray *)keyboardIngredients {
    return [NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] resourcePath]
                                             stringByAppendingPathComponent:@"ingredientsKeyboard.plist"]];
}

+ (id) configValueForKey:(NSString*) key
{
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
    id value = [[NSDictionary dictionaryWithContentsOfFile:configFilePath] objectForKey:key];
    return value;
}

#pragma mark - Directories and files.

- (NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

- (NSString *)documentsPathForFileName:(NSString *)name {
    return [[self documentsDirectoryPath] stringByAppendingPathComponent:name];
}

- (NSString *)documentsPathForDirectoryName:(NSString *)name {
    return [[self documentsDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", name]];
}

@end
