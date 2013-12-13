//
//  FollowReloadButtonView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/12/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "FollowReloadButtonView.h"
#import "CKActivityIndicatorView.h"
#import "ViewHelper.h"
#import "NSString+Utilities.h"

@interface FollowReloadButtonView ()

@property (nonatomic, weak) id<FollowReloadButtonViewDelegate> delegate;
@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL activity;

@end

@implementation FollowReloadButtonView

- (id)initWithDelegate:(id<FollowReloadButtonViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = delegate;
        self.frame = (CGRect) { 0.0, 0.0, self.reloadButton.frame.size.width, self.reloadButton.frame.size.height };
        [self addSubview:self.reloadButton];
    }
    return self;
}

- (void)enableActivity:(BOOL)activity {
    [self enableActivity:activity hideReload:NO];
}

- (void)enableActivity:(BOOL)activity hideReload:(BOOL)hideReload {
    
    // Ignore if already in the same status.
    if (self.activity == activity) {
        return;
    }
    self.activity = activity;
    
    // Enable interaction when not spinning and reload button is not hidden.
    self.userInteractionEnabled = !activity && !hideReload;
    
    // Hide reload button on activity, or specifically asked to.
    self.reloadButton.hidden = activity ? YES : hideReload;
    
    if (activity) {
        if (!self.activityView.superview) {
            [self addSubview:self.activityView];
        }
        if (![self.activityView isAnimating]) {
            [self.activityView startAnimating];
        }
    } else {
        [self.activityView stopAnimating];
        [self.activityView removeFromSuperview];
    }
}

#pragma mark - Properties

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleMedium];
    }
    return _activityView;
}

- (UIButton *)reloadButton {
    if (!_reloadButton) {
        _reloadButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_dash_icons_refresh.png"]
                                      selectedImage:[UIImage imageNamed:@"cook_dash_icons_refresh_onpress.png"]
                                             target:self
                                           selector:@selector(reloadTapped)];
    }
    return _reloadButton;
}

#pragma mark - Private methods

- (void)reloadTapped {
    if ([self.delegate respondsToSelector:@selector(followReloadButtonViewTapped)]) {
        [self.delegate followReloadButtonViewTapped];
    }
}

@end
