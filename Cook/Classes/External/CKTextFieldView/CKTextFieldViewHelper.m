//
//  CKTextFieldViewHelper.m
//  CKTextFieldDemo
//
//  Created by Jeff Tan-Ang on 30/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTextFieldViewHelper.h"

@implementation CKTextFieldViewHelper

+ (BOOL)isValidEmailForString:(NSString *)checkString {
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL currentValid = [emailTest evaluateWithObject:checkString];
    if (currentValid) {
        
        // No consecutive dots.
        currentValid = ([checkString rangeOfString:@".."].location == NSNotFound);
        
    }
    return currentValid;
}

+ (BOOL)isValidLengthForString:(NSString *)checkString min:(NSInteger)min max:(NSInteger)max {
    NSInteger length = [checkString length];
    return (length >= min && length <= max);
}

+ (NSString *)progressTextForEmailWithString:(NSString *)checkString {
    NSString *progressText = nil;
    if ([self isValidEmailForString:checkString]) {
        progressText = @"LOOKS ABOUT RIGHT";
    } else if ([checkString length] > 0) {
        progressText = @"LOOKING GOOD";
    }
    return progressText;
}

+ (NSString *)progressTextForNameWithString:(NSString *)checkString {
    NSString *progressText = nil;
    if ([checkString length] > 0) {
        progressText = @"LOOKING GOOD";
    }
    return progressText;
}

+ (NSString *)progressPasswordForNameWithString:(NSString *)checkString min:(NSInteger)min max:(NSInteger)max {
    NSString *progressText = nil;
    if ([self isValidLengthForString:checkString min:min max:max]) {
        progressText = @"THAT SHOULD DO IT";
    } else if ([checkString length] > 0) {
        NSInteger charactersLeft = min - [checkString length];
        if (charactersLeft == 1) {
            progressText = @"JUST ONE MORE";
        } else {
            progressText = [NSString stringWithFormat:@"%d CHARACTERS PLEASE", charactersLeft];
        }
    }
    return progressText;
}

@end
