//
//  RecipeLikeCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 28/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeLikeCell.h"
#import "CKUserProfilePhotoView.h"
#import "CKRecipeLike.h"

@interface RecipeLikeCell ()

@property (nonatomic, strong) CKUserProfilePhotoView *profileView;

@end

@implementation RecipeLikeCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.profileView];
    }
    return self;
}

- (void)configureLike:(CKRecipeLike *)like {
    [self.profileView loadProfilePhotoForUser:like.user];
}

#pragma mark - Properties

- (CKUserProfilePhotoView *)profileView {
    if (!_profileView) {
        _profileView = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeMini];
        _profileView.frame = self.contentView.bounds;
    }
    return _profileView;
}

@end
