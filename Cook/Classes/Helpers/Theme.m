//
//  Theme.m
//  Cook
//
//  Created by Jonny Sagorin on 11/27/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "Theme.h"
#import "UIColor+Expanded.h"
@implementation Theme

#pragma mark - Common Fonts
+(UIFont *)defaultFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:size];
    
}

+(UIFont *)defaultLabelFont
{
    return [UIFont fontWithName:@"Neutraface2Display-Medium" size:20];
}

#pragma mark - Common Colors

+(UIColor *)defaultLabelColor
{
    return [UIColor colorWithHexString:@"707070"];
}

#pragma mark - Recipe View
+(UIColor *)ingredientsLabelColor
{
    return [UIColor colorWithHexString:@"606060"];
    
}

+(UIColor *)directionsLabelColor;
{
    return [UIColor colorWithHexString:@"505050"];
    
}
@end
