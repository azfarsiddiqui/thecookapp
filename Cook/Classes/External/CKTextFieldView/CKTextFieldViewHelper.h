//
//  CKTextFieldViewHelper.h
//  CKTextFieldDemo
//
//  Created by Jeff Tan-Ang on 30/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKTextFieldViewHelper : NSObject

+ (BOOL)isValidEmailForString:(NSString *)checkString;
+ (BOOL)isValidLengthForString:(NSString *)checkString min:(NSInteger)min max:(NSInteger)max;

+ (NSString *)progressTextForEmailWithString:(NSString *)checkString;
+ (NSString *)progressTextForNameWithString:(NSString *)checkString;
+ (NSString *)progressPasswordForNameWithString:(NSString *)checkString min:(NSInteger)min max:(NSInteger)max;

@end
