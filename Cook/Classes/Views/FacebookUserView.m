//
//  FacebookUserView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/14/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "FacebookUserView.h"
#import "Theme.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

#define kHeight 22.0f
#define kWidth 22.0f

@interface FacebookUserView()
@property(nonatomic,strong) FBProfilePictureView *fbProfileView;
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
        self.userNameLabel.font = [Theme userNameFont];
        self.userNameLabel.textColor = [Theme userNameColor];
        CGSize maxSize = CGSizeMake(CGFLOAT_MAX, kHeight);
        CGSize requiredSize = [[user.name uppercaseString] sizeWithFont:[Theme userNameFont] constrainedToSize:maxSize lineBreakMode:NSLineBreakByTruncatingTail];
        
        self.userNameLabel.frame = CGRectMake(self.userNameLabel.frame.origin.x, self.userNameLabel.frame.origin.y, requiredSize.width, requiredSize.height);
        if (user.facebookId) {
            self.fbProfileView.profileID = user.facebookId;
        }
    }
}

#pragma mark - private methods
-(UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(25.0f, 0.0f, 100.0f, 0.0f)];
        [self addSubview: _userNameLabel];
    }
    return _userNameLabel;
}

-(FBProfilePictureView *)fbProfileView
{
    if (!_fbProfileView) {
        _fbProfileView = [[FBProfilePictureView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, kWidth, kHeight)];
        [self addSubview: _fbProfileView];
        UIImageView *maskOverlayImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cook_book_profile_sm.png"]];
        maskOverlayImageView.frame = CGRectMake(0.0f, 0.0f, kWidth, kWidth);
        [self addSubview:maskOverlayImageView];
    }
    return _fbProfileView;
}
@end
