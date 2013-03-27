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
+ (UIButton *)buttonWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(id)target selector:(SEL)selector;
//assumes an image exists with prefixes which end in '_on', and '_off' for normal and selected states
+ (UIButton *)buttonWithImagePrefix:(NSString*)imagePrefix target:(id)target selector:(SEL)selector;
+ (UIButton *)buttonWithTitle:(NSString*)title backgroundImage:(UIImage *)image target:(id)target selector:(SEL)selector;
+ (CGSize)bookSize;
+ (CGFloat)singleLineHeightForFont:(UIFont *)font;
+ (CGSize)screenSize;
+ (NSString*)formatAsHoursSeconds:(float)timeInSeconds ;
+ (void) adjustScrollContentSize:(UIScrollView*)scrollView forHeight:(float)height;
+ (CGPoint) centerPointForSmallerView:(UIView*)smallerView inLargerView:(UIView*)largerView;

// Convers view to images.
+ (UIImage *)imageWithView:(UIView *)view;
+ (UIImage *)imageWithView:(UIView *)view opaque:(BOOL)opaque;

@end
