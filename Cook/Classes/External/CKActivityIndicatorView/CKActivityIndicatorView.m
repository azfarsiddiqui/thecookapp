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

+ (CGSize)sizeForStyle:(CKActivityIndicatorViewStyle *)style {
    return [self backgroundImageForStyle:style].size;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                                  object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification
                                                  object:[UIApplication sharedApplication]];
}

- (id)initWithStyle:(CKActivityIndicatorViewStyle)style {
    if (self = [super init]) {
        self.style = style;
        self.currentTransform = CGAffineTransformIdentity;
        self.userInteractionEnabled = NO;
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[CKActivityIndicatorView backgroundImageForStyle:style]];
        self.frame = backgroundView.frame;
        [self addSubview:backgroundView];
        self.backgroundImageView = backgroundView;
        
        UIImageView *activityIndicatorImageView = [[UIImageView alloc] initWithImage:[CKActivityIndicatorView imageForStyle:style]];
        self.activityIndicatorImageView = activityIndicatorImageView;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.activityIndicatorImageView];
        self.activityIndicatorImageView.hidden = YES;
        
        // To be shown when animation is started.
        self.hidden = YES;
        
        // Register for notification that app did enter background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pauseActivityIfRequired)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        // Register for notification that app did enter foreground
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeActivityIfRequired)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)startAnimating {
    if (self.animating) {
        [self stopAnimating];
    }
    
    self.hidden = NO;
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
    
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

- (void)restartAnimating {
    [self stopAnimating];
    [self startAnimating];
}

- (BOOL)isAnimating {
    return self.animating;
}

#pragma mark - Background/Foreground activity.

- (void)pauseActivityIfRequired {
    // Rely on the resume to stop/start
}

- (void)resumeActivityIfRequired {
    if (self.superview && [self isAnimating]) {
        [self restartAnimating];
    }
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

+ (UIImage *)backgroundImageForStyle:(CKActivityIndicatorViewStyle)style {
    UIImage *image = nil;
    switch (style) {
        case CKActivityIndicatorViewStyleTiny:
            image = [UIImage imageNamed:@"cook_book_inner_loading_tiny_outer.png"];
            break;
        case CKActivityIndicatorViewStyleTinyDark:
            image = [UIImage imageNamed:@"cook_book_inner_loading_tiny_dark_outer.png"];
            break;
        case CKActivityIndicatorViewStyleTinyDarkBlue:
            image = [UIImage imageNamed:@"cook_book_inner_loading_tiny_dark_outer_blue.png"];
            break;
        case CKActivityIndicatorViewStyleSmall:
            image = [UIImage imageNamed:@"cook_book_inner_loading_small_outer.png"];
            break;
        case CKActivityIndicatorViewStyleMedium:
            image = [UIImage imageNamed:@"cook_dash_loading_outer.png"];
            break;
        case CKActivityIndicatorViewStyleLarge:
            image = [UIImage imageNamed:@"cook_book_inner_loading_large_outer.png"];
            break;
        default:
            break;
    }
    return image;
}

+ (UIImage *)imageForStyle:(CKActivityIndicatorViewStyle)style {
    UIImage *image = nil;
    switch (style) {
        case CKActivityIndicatorViewStyleTiny:
            image = [UIImage imageNamed:@"cook_book_inner_loading_tiny_inner.png"];
            break;
        case CKActivityIndicatorViewStyleTinyDark:
            image = [UIImage imageNamed:@"cook_book_inner_loading_tiny_dark_inner.png"];
            break;
        case CKActivityIndicatorViewStyleTinyDarkBlue:
            image = [UIImage imageNamed:@"cook_book_inner_loading_tiny_dark_inner_blue.png"];
            break;
        case CKActivityIndicatorViewStyleSmall:
            image = [UIImage imageNamed:@"cook_book_inner_loading_small_inner.png"];
            break;
        case CKActivityIndicatorViewStyleMedium:
            image = [UIImage imageNamed:@"cook_dash_loading_inner.png"];
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
