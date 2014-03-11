//
//  CKProgressView.h
//  UIProgressViewDemo
//
//  Created by Jeff Tan-Ang on 7/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

// http://stackoverflow.com/questions/7848766/how-can-we-programmatically-detect-which-ios-version-is-device-running-on
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface CKProgressView : UIProgressView

- (id)initWithWidth:(CGFloat)width;
- (void)setProgress:(float)progress completion:(void (^)())completion;
- (void)setProgress:(float)progress delay:(NSTimeInterval)delay completion:(void (^)())completion;

@end
