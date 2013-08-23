//
//  APActivityIndicatorView.m
//  APActivityIndicatorViewDemo
//
//  Created by Jeff Tan-Ang on 22/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CKActivityIndicatorView.h"

@interface CKActivityIndicatorView()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *activityIndicatorImageView;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) CGAffineTransform currentTransform;
@property (nonatomic, assign) CKActivityIndicatorViewStyle style;

@end

@implementation CKActivityIndicatorView

- (id)initWithStyle:(CKActivityIndicatorViewStyle)style {
    if (self = [super init]) {
        self.style = style;
        self.currentTransform = CGAffineTransformIdentity;
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[self backgroundImageForStyle:style]];
        self.frame = backgroundView.frame;
        [self addSubview:backgroundView];
        self.backgroundImageView = backgroundView;
        
        UIImageView *activityIndicatorImageView = [[UIImageView alloc] initWithImage:[self imageForStyle:style]];
        self.activityIndicatorImageView = activityIndicatorImageView;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.activityIndicatorImageView];
        self.activityIndicatorImageView.hidden = YES;
        
    }
    return self;
}

- (void)startAnimating {
    if (self.animating) {
        [self stopAnimating];
    }
    
    self.backgroundImageView.hidden = NO;
    self.activityIndicatorImageView.hidden = NO;
    self.animating = YES;
    [self spin];
}

- (void)stopAnimating {
    if (!self.animating) {
        return;
    }
    
    self.animating = NO;
    CALayer *pLayer = [self.activityIndicatorImageView.layer presentationLayer];
    self.activityIndicatorImageView.layer.transform = pLayer.transform;
    [self.activityIndicatorImageView.layer removeAnimationForKey:@"spinAnimation"];
    self.activityIndicatorImageView.hidden = YES;
    self.backgroundImageView.hidden = YES;
}

- (BOOL)isAnimating {
    return self.animating;
}

#pragma mark - Private methods

- (void)spin {
    CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spinAnimation.toValue = [NSNumber numberWithFloat:M_PI];
    spinAnimation.duration = 0.5;
    spinAnimation.cumulative = YES;
    spinAnimation.repeatCount = HUGE_VALF;
    spinAnimation.fillMode = kCAFillModeForwards;
    self.activityIndicatorImageView.layer.transform = CATransform3DIdentity;
    [self.activityIndicatorImageView.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
}

- (UIImage *)backgroundImageForStyle:(CKActivityIndicatorViewStyle)style {
    UIImage *image = nil;
    switch (style) {
        case CKActivityIndicatorViewStyleSmall:
            image = [UIImage imageNamed:@"cook_book_inner_loading_small_outer.png"];
            break;
        case CKActivityIndicatorViewStyleLarge:
            image = [UIImage imageNamed:@"cook_book_inner_loading_large_outer.png"];
            break;
        default:
            break;
    }
    return image;
}

- (UIImage *)imageForStyle:(CKActivityIndicatorViewStyle)style {
    UIImage *image = nil;
    switch (style) {
        case CKActivityIndicatorViewStyleSmall:
            image = [UIImage imageNamed:@"cook_book_inner_loading_small_inner.png"];
            break;
        case CKActivityIndicatorViewStyleLarge:
            image = [UIImage imageNamed:@"cook_book_inner_loading_large_inner.png"];
            break;
        default:
            break;
    }
    return image;
}

@end
