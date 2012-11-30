//
//  CKUIHelper.h
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewHelper : NSObject

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector;
//assumes an image exists with prefixes which end in '_on', and '_off' for normal and selected states
+ (UIButton *)buttonWithImagePrefix:(NSString*)imagePrefix target:(id)target selector:(SEL)selector;
+ (CGSize)bookSize;
+ (CGFloat)singleLineHeightForFont:(UIFont *)font;
+ (CGSize)screenSize;
+ (NSString*)formatAsHoursSeconds:(float)timeInSeconds ;
+ (void) adjustScrollContentSize:(UIScrollView*)scrollView forHeight:(float)height;

@end
