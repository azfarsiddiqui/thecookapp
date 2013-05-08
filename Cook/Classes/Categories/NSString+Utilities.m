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

- (NSString *)CK_whitespaceTrimmed {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)CK_blank {
    NSString *trimmed = [self CK_whitespaceTrimmed];
    return ([[self CK_whitespaceTrimmed] length] == 0);
}

@end
