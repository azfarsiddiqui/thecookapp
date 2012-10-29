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

+ (CGSize)bookSize;
+ (CGFloat)singleLineHeightForFont:(UIFont *)font;
+ (CGSize)screenSize;

@end
