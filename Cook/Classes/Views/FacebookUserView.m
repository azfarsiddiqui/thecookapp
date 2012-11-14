//
//  FacebookUserView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/14/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "FacebookUserView.h"
#import <Parse/Parse.h>

#define kHeight 22.0f
#define kWidth 22.0f

@interface FacebookUserView()
@property(nonatomic,strong) PF_FBProfilePictureView *fbProfileView;
@property(nonatomic,strong) UILabel *userNameLabel;
@end

@implementation FacebookUserView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)setUser:(CKUser *)user
{
    if (user) {
        self.userNameLabel.text = [user.name uppercaseString];
        CGSize maxSize = CGSizeMake(CGFLOAT_MAX, kHeight);
        [self.userNameLabel sizeThatFits:maxSize];
        if (user.facebookId) {
            self.fbProfileView.profileID = user.facebookId;
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 50.0f, kHeight);
    }
}

#pragma mark - private methods
-(UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(25.0f, 0.0f, 100.0f, kHeight)];
        _userNameLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview: _userNameLabel];
    }
    return _userNameLabel;
}

-(PF_FBProfilePictureView *)fbProfileView
{
    if (!_fbProfileView) {
        _fbProfileView = [[PF_FBProfilePictureView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kWidth, kHeight)];
        [self addSubview: _fbProfileView];
        UIImageView *maskOverlayImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cook_book_profile_sm.png"]];
        maskOverlayImageView.frame = CGRectMake(0.0f, 0.0f, kWidth, kWidth);
        [self addSubview:maskOverlayImageView];
    }
    return _fbProfileView;
}
@end
