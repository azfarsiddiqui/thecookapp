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

+ (NSString *)CK_stringOrNilForNumber:(NSNumber *)number {
    return (number != nil) ? [number stringValue] : nil;
}

+ (NSString *)CK_lineBreakString {
    return @"\u2028";
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

- (NSString *)CK_whitespaceAndNewLinesTrimmed {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)CK_containsText {
    return ([[self CK_whitespaceAndNewLinesTrimmed] length] > 0);
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

- (NSString *)CK_lineBreakFormattedString {
    NSString *sanitisedString = [self CK_whitespaceTrimmed];
    sanitisedString = [sanitisedString stringByReplacingOccurrencesOfString:@"\n" withString:[NSString CK_lineBreakString]];
    return sanitisedString;
}

- (NSInteger)CK_wordCount {
    return [[self componentsSeparatedByString:@" "] count];
}

- (NSString *)CK_mixedCase {
    return [self capitalizedStringWithLocale:nil];
}

@end
