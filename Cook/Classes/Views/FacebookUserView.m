//
//  FacebookUserView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/14/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "FacebookUserView.h"
#import <Parse/Parse.h>

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
        [self.userNameLabel sizeToFit];
        if (user.facebookId) {
            self.fbProfileView.profileID = user.facebookId;
        }
    }
}

#pragma mark - private methods
-(UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 0.0f, 100.0f, 20.0f)];
        [self addSubview: _userNameLabel];
    }
    return _userNameLabel;
}

-(PF_FBProfilePictureView *)fbProfileView
{
    if (!_fbProfileView) {
        _fbProfileView = [[PF_FBProfilePictureView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
        [self addSubview: _fbProfileView];
    }
    return _fbProfileView;
}
@end
