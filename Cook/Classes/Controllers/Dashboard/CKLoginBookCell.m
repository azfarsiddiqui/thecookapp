//
//  CKLoginBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKLoginBookCell.h"

@implementation CKLoginBookCell

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        UIImageView *loginView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_signin_banner.png"]];
        loginView.autoresizingMask = UIViewAutoresizingNone;
        loginView.center = self.contentView.center;
        [self.contentView addSubview:loginView];
    }
    return self;
}

#pragma mark - Private

- (void)loginTapped {
    DLog();
}

@end
