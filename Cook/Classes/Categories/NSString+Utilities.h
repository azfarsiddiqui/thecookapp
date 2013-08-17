//
//  NSString+Utilities.h
//  Cook
//
//  Created by Jeff Tan-Ang on 2/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)

+ (NSString *)CK_safeString:(NSString *)string;
+ (NSString *)CK_safeString:(NSString *)string defaultString:(NSString *)defaultString;
+ (NSString *)CK_stringForBoolean:(BOOL)boolean;

- (BOOL)CK_equalsIgnoreCase:(NSString *)string;
- (BOOL)CK_equals:(NSString *)string;
- (NSString *)CK_whitespaceTrimmed;
- (NSString *)CK_whitespaceAndNewLinesTrimmed;
- (BOOL)CK_containsText;
- (NSString *)CK_truncatedStringToLength:(NSInteger)length;
- (NSInteger)wordCount;

@end
