//
//  CKFacebookSignInButtonView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKFacebookSignInButtonView.h"
#import "Theme.h"

@implementation CKFacebookSignInButtonView

- (UIFont *)textLabelFont {
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:15];
}

- (UIColor *)textLabelColour {
    return [UIColor colorWithHexString:@"ffffff"];
}

- (UIImage *)normalBackgroundImage {
    return [[UIImage imageNamed:@"cook_login_btn_signup_facebook.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
}

- (UIImage *)onPressBackgroundImage {
    return [[UIImage imageNamed:@"cook_login_btn_signup_facebook_onpress.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(37.0, 10.0, 37.0, 10.0)];
}

- (UIImage *)iconImage {
    return [UIImage imageNamed:@"cook_login_icon_facebook.png"];
}

- (CKActivityIndicatorViewStyle)activityViewStyle {
    return CKActivityIndicatorViewStyleTiny;
}

@end
