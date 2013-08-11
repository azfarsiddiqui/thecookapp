//
//  NSString+Utilities.m
//  Cook
//
//  Created by Jeff Tan-Ang on 2/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

+ (NSString *)CK_safeString:(NSString *)string {
    return [NSString CK_safeString:string defaultString:@""];
}

+ (NSString *)CK_safeString:(NSString *)string defaultString:(NSString *)defaultString {
    return string == nil ? defaultString : string;
}

+ (NSString *)CK_stringForBoolean:(BOOL)boolean {
    return boolean ? @"YES" : @"NO";
}

- (BOOL)CK_equalsIgnoreCase:(NSString *)string {
    return ([self localizedCaseInsensitiveCompare:string] == NSOrderedSame);
}

- (BOOL)CK_equals:(NSString *)string {
    return [self isEqualToString:string];
}

- (NSString *)CK_whitespaceTrimmed {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)CK_containsText {
    return ([[self CK_whitespaceTrimmed] length] > 0);
}

- (NSString *)CK_truncatedStringToLength:(NSInteger)length {
    NSString *truncatedString = [NSString stringWithString:self];
    if ([self length]) {
        
        NSInteger indexToTruncate = 0;
        if (length > [self length]) {
            indexToTruncate = [self length];
        } else {
            indexToTruncate = length;
        }
        truncatedString = [truncatedString substringToIndex:indexToTruncate];
    }
    return truncatedString;
}

- (NSInteger)wordCount {
    return [[self componentsSeparatedByString:@" "] count];
}

@end
