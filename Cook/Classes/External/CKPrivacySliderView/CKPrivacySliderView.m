//
//  CKPrivacySliderView.m
//  CKNotchSliderControlDemo
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPrivacySliderView.h"
#import "Theme.h"

@interface CKPrivacySliderView () <CKNotchSliderViewDelegate>

@property (nonatomic, strong) UIImageView *sliderPrivateIconView;
@property (nonatomic, strong) UIImageView *sliderFriendsIconView;
@property (nonatomic, strong) UIImageView *sliderPublicIconView;
@property (nonatomic, strong) UILabel *infoPrivateLabel;
@property (nonatomic, strong) UILabel *infoFriendsLabel;
@property (nonatomic, strong) UILabel *infoPublicLabel;

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

- (UIImage *)imageForSliderSelected:(BOOL)selected {
    return selected ? [UIImage imageNamed:@"cook_customise_privacy_picker_onpress.png"] : [UIImage imageNamed:@"cook_customise_privacy_picker.png"];
}

- (void)initNotchIndex:(NSInteger)selectedNotchIndex {
    self.sliderPrivateIconView.alpha = 1.0;
    self.sliderFriendsIconView.alpha = 0.0;
    self.sliderPublicIconView.alpha = 0.0;
    [self.currentNotchView addSubview:self.sliderPrivateIconView];
    [self.currentNotchView addSubview:self.sliderFriendsIconView];
    [self.currentNotchView addSubview:self.sliderPublicIconView];
    [super initNotchIndex:selectedNotchIndex];
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
        [self infoLabelForIndex:trackIndex].alpha = intersectionRatio;
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

- (UIImageView *)sliderPublicIconView {
    if (!_sliderPublicIconView) {
        _sliderPublicIconView = [[UIImageView alloc] initWithImage:[self imageForIconAtNotchIndex:2]];
        _sliderPublicIconView.frame = (CGRect){
            floorf((self.currentNotchView.bounds.size.width - _sliderPublicIconView.frame.size.width) / 2.0),
            floorf((self.currentNotchView.bounds.size.height - _sliderPublicIconView.frame.size.height) / 2.0),
            _sliderPublicIconView.frame.size.width,
            _sliderPublicIconView.frame.size.height
        };
    }
    return _sliderPublicIconView;
}

- (UILabel *)infoPrivateLabel {
    if (!_infoPrivateLabel) {
        _infoPrivateLabel = [self infoLabelForText:[self infoForNotchIndex:0]];
    }
    return _infoPrivateLabel;
}

- (UILabel *)infoFriendsLabel {
    if (!_infoFriendsLabel) {
        _infoFriendsLabel = [self infoLabelForText:[self infoForNotchIndex:1]];
    }
    return _infoFriendsLabel;
}

- (UILabel *)infoPublicLabel {
    if (!_infoFriendsLabel) {
        _infoFriendsLabel = [self infoLabelForText:[self infoForNotchIndex:2]];
    }
    return _infoFriendsLabel;
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
            sliderIconView = self.sliderPublicIconView;
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

- (UILabel *)infoLabelForIndex:(NSInteger)notchIndex {
    UILabel *infoLabel = nil;
    switch (notchIndex) {
        case 0:
            infoLabel = self.infoPrivateLabel;
            break;
        case 1:
            infoLabel = self.infoFriendsLabel;
            break;
        case 2:
            infoLabel = self.infoPublicLabel;
            break;
        default:
            break;
    }
    return infoLabel;
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
            [privacyDelegate privacySelectedPublicForSliderView:self];
            break;
        default:
            break;
    }
}

- (NSString *)infoForNotchIndex:(NSInteger)notchIndex {
    NSString *info = nil;
    switch (notchIndex) {
        case 0:
            info = @"SECRET";
            break;
        case 1:
            info = @"FRIENDS";
            break;
        case 2:
            info = @"PUBLIC";
            break;
        default:
            break;
    }
    return info;
}

- (UILabel *)infoLabelForText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [Theme privacyInfoFont];
    label.textColor = [Theme privacyInfoColour];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByClipping;
    label.text = text;
    [label sizeToFit];
    label.frame = (CGRect){
        floorf((self.bounds.size.width - label.frame.size.width) / 2.0),
        floorf((self.bounds.size.height - label.frame.size.height) / 2.0) - 7.0,
        label.frame.size.width,
        label.frame.size.height
    };
    return label;
}

@end
