//
//  LocalisationHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 30/07/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "LocalisationHelper.h"
#import "MRCEnumerable.h"

@implementation LocalisationHelper

//
// http://stackoverflow.com/questions/8211996/fake-va-list-in-arc/8217755#8217755
//
+ (NSString *)stringWithPlaceholderFormat:(NSString *)placeholderFormat placeholderKeys:(NSArray *)placeholderKeys {
    
    if ([placeholderKeys count] == 0) {
        return NSLocalizedString(placeholderFormat, nil);
    }
    
    // First, localised the placeholders.
    NSArray *localisedPlaceholders = [self localisedValuesForKeys:placeholderKeys];
    
    NSRange range = NSMakeRange(0, [localisedPlaceholders count]);
    NSMutableData *data = [NSMutableData dataWithLength:sizeof(id) * [localisedPlaceholders count]];
    [localisedPlaceholders getObjects:(__unsafe_unretained id *)data.mutableBytes range:range];
    
    // Use the localised placeholder format and pass in localised values.
    NSString *result = [[NSString alloc] initWithFormat:NSLocalizedString(placeholderFormat, nil)
                                              arguments:data.mutableBytes];
    
    return result;
}

#pragma mark - Private methods

+ (NSArray *)localisedValuesForKeys:(NSArray *)keys {
    
    return [keys collect:^id(NSString *key) {
        return NSLocalizedString(key, nil);
    }];
}

@end
