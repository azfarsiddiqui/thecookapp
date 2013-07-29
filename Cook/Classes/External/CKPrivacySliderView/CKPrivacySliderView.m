//
//  CKPrivacySliderView.m
//  CKNotchSliderControlDemo
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPrivacySliderView.h"

@interface CKPrivacySliderView () <CKNotchSliderViewDelegate>

@property (nonatomic, strong) UIImageView *sliderPrivateIconView;
@property (nonatomic, strong) UIImageView *sliderFriendsIconView;
@property (nonatomic, strong) UIImageView *sliderGlobalIconView;

@end

@implementation CKPrivacySliderView

- (id)initWithDelegate:(id<CKPrivacySliderViewDelegate>)delegate {
    if (self = [super initWithNumNotches:3 delegate:delegate]) {
    }
    return self;
}

- (UIImage *)imageForLeftTrack {
    return [UIImage imageNamed:@"cook_customise_privacy_bg_left.png"];
}

- (UIImage *)imageForMiddleTrack {
    return [UIImage imageNamed:@"cook_customise_privacy_bg_middle.png"];
}

- (UIImage *)imageForRightTrack {
    return [UIImage imageNamed:@"cook_customise_privacy_bg_right.png"];
}

- (UIImage *)imageForSlider {
    return [UIImage imageNamed:@"cook_customise_privacy_picker.png"];
}

- (void)initNotchIndex:(NSInteger)selectedNotchIndex {
    self.sliderPrivateIconView.alpha = 1.0;
    self.sliderFriendsIconView.alpha = 0.0;
    self.sliderGlobalIconView.alpha = 0.0;
    [self.currentNotchView addSubview:self.sliderPrivateIconView];
    [self.currentNotchView addSubview:self.sliderFriendsIconView];
    [self.currentNotchView addSubview:self.sliderGlobalIconView];
}

- (void)selectedNotchIndex:(NSInteger)selectedNotchIndex {
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for (NSInteger trackIndex = 0; trackIndex < [self.trackNotches count]; trackIndex++) {
                             [self sliderIconViewForIndex:trackIndex].alpha = (selectedNotchIndex == trackIndex) ? 1.0 : 0.0;
                         }
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self selectedPrivacyAtNotchIndex:selectedNotchIndex];
}

- (void)updateNotchSliderWithFrame:(CGRect)sliderFrame {
    [super updateNotchSliderWithFrame:sliderFrame];
    
    for (NSInteger trackIndex = 0; trackIndex < [self.trackNotches count]; trackIndex++) {
        UIImageView *trackImageView = [self.trackNotches objectAtIndex:trackIndex];
        CGRect trackIntersection = CGRectIntersection(trackImageView.frame, sliderFrame);
        
        // Figure out the intersection of the slider, if fully covered, then fully visible.
        CGFloat intersectionRatio = MIN(1.0, trackIntersection.size.width / sliderFrame.size.width);
        [self sliderIconViewForIndex:trackIndex].alpha = intersectionRatio;
    }

}

- (void)slideToNotchIndex:(NSInteger)notchIndex animated:(BOOL)animated {
    [super slideToNotchIndex:notchIndex animated:animated];
    [self updateNotchSliderWithFrame:self.currentNotchView.frame];
}


#pragma mark - Properties

- (UIImageView *)sliderPrivateIconView {
    if (!_sliderPrivateIconView) {
        _sliderPrivateIconView = [[UIImageView alloc] initWithImage:[self imageForIconAtNotchIndex:0]];
        _sliderPrivateIconView.frame = (CGRect){
            floorf((self.currentNotchView.bounds.size.width - _sliderPrivateIconView.frame.size.width) / 2.0),
            floorf((self.currentNotchView.bounds.size.height - _sliderPrivateIconView.frame.size.height) / 2.0),
            _sliderPrivateIconView.frame.size.width,
            _sliderPrivateIconView.frame.size.height
        };
    }
    return _sliderPrivateIconView;
}

- (UIImageView *)sliderFriendsIconView {
    if (!_sliderFriendsIconView) {
        _sliderFriendsIconView = [[UIImageView alloc] initWithImage:[self imageForIconAtNotchIndex:1]];
        _sliderFriendsIconView.frame = (CGRect){
            floorf((self.currentNotchView.bounds.size.width - _sliderFriendsIconView.frame.size.width) / 2.0),
            floorf((self.currentNotchView.bounds.size.height - _sliderFriendsIconView.frame.size.height) / 2.0),
            _sliderFriendsIconView.frame.size.width,
            _sliderFriendsIconView.frame.size.height
        };
    }
    return _sliderFriendsIconView;
}

- (UIImageView *)sliderGlobalIconView {
    if (!_sliderGlobalIconView) {
        _sliderGlobalIconView = [[UIImageView alloc] initWithImage:[self imageForIconAtNotchIndex:2]];
        _sliderGlobalIconView.frame = (CGRect){
            floorf((self.currentNotchView.bounds.size.width - _sliderGlobalIconView.frame.size.width) / 2.0),
            floorf((self.currentNotchView.bounds.size.height - _sliderGlobalIconView.frame.size.height) / 2.0),
            _sliderGlobalIconView.frame.size.width,
            _sliderGlobalIconView.frame.size.height
        };
    }
    return _sliderGlobalIconView;
}

#pragma mark - Private methods

- (UIImageView *)sliderIconViewForIndex:(NSInteger)notchIndex {
    UIImageView *sliderIconView = nil;
    switch (notchIndex) {
        case 0:
            sliderIconView = self.sliderPrivateIconView;
            break;
        case 1:
            sliderIconView = self.sliderFriendsIconView;
            break;
        case 2:
            sliderIconView = self.sliderGlobalIconView;
            break;
        default:
            break;
    }
    return sliderIconView;
}

- (UIImage *)imageForIconAtNotchIndex:(NSInteger)notchIndex {
    UIImage *iconImage = nil;
    switch (notchIndex) {
        case 0:
            iconImage = [UIImage imageNamed:@"cook_customise_privacy_secret.png"];
            break;
        case 1:
            iconImage = [UIImage imageNamed:@"cook_customise_privacy_friends.png"];
            break;
        case 2:
            iconImage = [UIImage imageNamed:@"cook_customise_privacy_public.png"];
            break;
        default:
            break;
    }
    return iconImage;
}

- (void)selectedPrivacyAtNotchIndex:(NSInteger)notchIndex {
    id<CKPrivacySliderViewDelegate> privacyDelegate = (id<CKPrivacySliderViewDelegate>)self.delegate;
    switch (notchIndex) {
        case 0:
            [privacyDelegate privacySelectedPrivateForSliderView:self];
            break;
        case 1:
            [privacyDelegate privacySelectedFriendsForSliderView:self];
            break;
        case 2:
            [privacyDelegate privacySelectedGlobalForSliderView:self];
            break;
        default:
            break;
    }
}

@end
