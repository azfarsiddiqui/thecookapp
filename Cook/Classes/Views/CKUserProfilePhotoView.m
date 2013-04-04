//
//  RoundedProfileView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 2/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKUserProfilePhotoView.h"
#import "CKUser.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@interface CKUserProfilePhotoView ()

@property (nonatomic, assign) ProfileViewSize profileSize;
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) UIImage *placeholderImage;

@end

@implementation CKUserProfilePhotoView

#define kSmallSize  CGSizeMake(30.0, 30.0)
#define kMediumSize CGSizeMake(60.0, 60.0)
#define kLargeSize  CGSizeMake(90.0, 90.0)

+ (CGSize)sizeForProfileSize:(ProfileViewSize)profileSize {
    CGSize size = kSmallSize;
    switch (profileSize) {
        case ProfileViewSizeSmall:
            size = kSmallSize;
            break;
        case ProfileViewSizeMedium:
            size = kMediumSize;
            break;
        case ProfileViewSizeLarge:
            size = kLargeSize;
            break;
        default:
            break;
    }
    return size;
}

- (id)initWithProfileSize:(ProfileViewSize)profileSize {
    return [self initWithUser:nil profileSize:profileSize];
}

- (id)initWithUser:(CKUser *)user profileSize:(ProfileViewSize)profileSize {
    return [self initWithUser:user placeholder:nil profileSize:profileSize];
}

- (id)initWithUser:(CKUser *)user placeholder:(UIImage *)placeholderImage profileSize:(ProfileViewSize)profileSize {
    if (self = [super initWithFrame:[CKUserProfilePhotoView frameForProfileSize:profileSize]]) {
        self.placeholderImage = placeholderImage;
        self.profileSize = profileSize;
        self.image = placeholderImage;
        [self applyRoundMask];
        if (user) {
            [self loadProfilePhotoForUser:user];
        }
    }
    return self;
}

- (void)loadProfilePhotoForUser:(CKUser *)user {
    self.user = user;
    [self setImageWithURL:[user profilePhotoUrl]];
}

#pragma mark - Private methods

+ (CGRect)frameForProfileSize:(ProfileViewSize)profileSize {
    CGSize size = [self sizeForProfileSize:profileSize];
    return CGRectMake(0.0, 0.0, size.width, size.height);
}

- (void)applyRoundMask {
    CGSize size = [CKUserProfilePhotoView sizeForProfileSize:self.profileSize];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(floorf(size.width / 2.0), floorf(size.height / 2.0))];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

@end
