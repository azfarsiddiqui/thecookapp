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

@end
