//
//  LocalisationHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 30/07/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalisationHelper : NSObject

+ (NSString *)stringWithPlaceholderFormat:(NSString *)placeholderFormat placeholderKeys:(NSArray *)placeholderKeys;

@end
