//
//  CKUIHelper.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//  User Interface helper for creation of user interface element
//

#import "ViewHelper.h"

@implementation ViewHelper

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    button.userInteractionEnabled = (target != nil && selector != nil);
    button.autoresizingMask = UIViewAutoresizingNone;
    return button;
}

+ (CGSize)bookSize {
    return CGSizeMake(300.0, 438.0);
}

+ (CGFloat)singleLineHeightForFont:(UIFont *)font {
    return [@"A" sizeWithFont:font constrainedToSize:[ViewHelper bookSize] lineBreakMode:NSLineBreakByTruncatingTail].height;
}

@end
