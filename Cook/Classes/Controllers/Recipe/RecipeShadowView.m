//
//  RecipeShadowView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeShadowView.h"

@implementation RecipeShadowView

+ (NSString *)decorationKind {
    return @"RecipeShadowView";
}

+ (UIImage *)image {
    return [UIImage imageNamed:@"cook_book_update_header_shadow.png"];
}

@end
