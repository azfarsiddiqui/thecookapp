//
//  Theme.h
//  Cook
//
//  Created by Jonny Sagorin on 11/27/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Theme : NSObject

#pragma mark - Common Fonts
+(UIFont*) defaultFontWithSize:(CGFloat)size;
+(UIFont*) defaultLabelFont;

#pragma mark - Common Colors
+(UIColor*) defaultLabelColor;

#pragma mark - Recipe View
+(UIColor*) ingredientsLabelColor;
+(UIColor*) directionsLabelColor;
@end

