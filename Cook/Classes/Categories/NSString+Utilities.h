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
+ (NSString *)CK_stringForBoolean:(BOOL)boolean;

@end
