//
//  RoundedProfileView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 2/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RoundedProfileView.h"
#import <QuartzCore/QuartzCore.h>

@interface RoundedProfileView ()

@property (nonatomic, assign) RoundedProfileViewSize profileSize;

@end

@implementation RoundedProfileView

#define kSmallSize  CGSizeMake(30.0, 30.0)
#define kMediumSize CGSizeMake(60.0, 60.0)
#define kLargeSize  CGSizeMake(90.0, 90.0)

+ (CGSize)sizeForProfileSize:(RoundedProfileViewSize)profileSize {
    CGSize size = kSmallSize;
    switch (profileSize) {
        case RoundedProfileViewSizeSmall:
            size = kSmallSize;
            break;
        case RoundedProfileViewSizeMedium:
            size = kMediumSize;
            break;
        case RoundedProfileViewSizeLarge:
            size = kLargeSize;
            break;
        default:
            break;
    }
    return size;
}

- (id)initWithProfileSize:(RoundedProfileViewSize)profileSize {
    if (self = [super initWithFrame:[RoundedProfileView frameForProfileSize:profileSize]]) {
        self.profileSize = profileSize;
    }
    return self;
}

- (void)setProfileID:(NSString *)profileID {
    [super setProfileID:profileID];
    
    // Round the layer.
    CGSize size = [RoundedProfileView sizeForProfileSize:self.profileSize];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(floorf(size.width / 2.0), floorf(size.height / 2.0))];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

#pragma mark - Private methods

+ (CGRect)frameForProfileSize:(RoundedProfileViewSize)profileSize {
    CGSize size = [self sizeForProfileSize:profileSize];
    return CGRectMake(0.0, 0.0, size.width, size.height);
}

@end
