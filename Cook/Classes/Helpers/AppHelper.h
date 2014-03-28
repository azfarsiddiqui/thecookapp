//
//  CKAppHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RootViewController;

@interface AppHelper : NSObject

+ (AppHelper *)sharedInstance;

- (BOOL)isNewUpdate;
- (void)maskAsNewUpdate:(BOOL)update;

- (UIView *)rootView;
- (RootViewController *)rootViewController;

// App version
- (NSString *)appVersion;
- (NSString *)systemVersion;
- (BOOL)systemVersionAtLeast:(NSString *)version;

// Provides a landscape frame which can be tricky to obtain in pre-rotation situations.
- (CGRect)fullScreenFrame;
- (CGFloat)screenScale;
- (BOOL)isRetina;

// Returns the keyboard ingredients items.
- (NSArray *)keyboardIngredients;
+ (id) configValueForKey:(NSString*) key;

// Local directories/files.
- (NSString *)documentsDirectoryPath;
- (NSString *)documentsPathForFileName:(NSString *)name;
- (NSString *)documentsPathForDirectoryName:(NSString *)name;

@end
