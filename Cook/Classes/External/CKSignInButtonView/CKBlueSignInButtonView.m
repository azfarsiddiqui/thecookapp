//
//  CKBlueSignInButtonView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBlueSignInButtonView.h"
#import "Theme.h"

@implementation CKBlueSignInButtonView

- (UIFont *)textLabelFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:15];
}

- (UIColor *)textLabelColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

- (UIImage *)normalBackgroundImage {
    return [[UIImage imageNamed:@"cook_login_btn_signup_blue.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
}

- (UIImage *)onPressBackgroundImage {
    return [[UIImage imageNamed:@"cook_login_btn_signup_blue_onpress.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
}

@end
