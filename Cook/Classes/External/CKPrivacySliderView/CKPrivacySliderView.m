//
//  CKPrivacySliderView.m
//  CKNotchSliderControlDemo
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPrivacySliderView.h"
#import "Theme.h"
#import "CKEditingTextBoxView.h"

@interface CKPrivacySliderView () <CKNotchSliderViewDelegate>

@property (nonatomic, strong) UIImageView *sliderPrivateIconView;
@property (nonatomic, strong) UIImageView *sliderFriendsIconView;
@property (nonatomic, strong) UIImageView *sliderPublicIconView;
@property (nonatomic, strong) UILabel *infoPrivateLabel;
@property (nonatomic, strong) UILabel *infoFriendsLabel;
@property (nonatomic, strong) UILabel *infoPublicLabel;
@property (nonatomic, strong) UIView *toastView;
@property (nonatomic, strong) UILabel *toastLabel;

@end

@implementation CKPrivacySliderView

#define kToastFont      [UIFont fontWithName:@"BrandonGrotesque-Regular" size:12.0]
#define kToastColour    [UIColor colorWithHexString:@"269ce0"]
#define kToastInsets    (UIEdgeInsets){ 17.0, 22.0, 27.0, 22.0 }

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
                         [self selectedPrivacyAtNotchIndex:selectedNotchIndex];
                     }];
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

- (void)toastMessage:(NSString *)message {
    
    // Cancel any previous hideToast.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToast) object:nil];
    
    CGSize availableSize = (CGSize){ self.toastView.bounds.size.width - kToastInsets.left - kToastInsets.right,
        self.toastView.bounds.size.height - kToastInsets.top - kToastInsets.bottom };
    
    // Update the toast label.
    [self.toastLabel removeFromSuperview];
    self.toastLabel.text = [message uppercaseString];
    [self.toastLabel sizeToFit];
    self.toastLabel.frame = (CGRect){
        kToastInsets.left + floorf((availableSize.width - self.toastLabel.frame.size.width) / 2.0),
        kToastInsets.top + floorf((availableSize.height - self.toastLabel.frame.size.height) / 2.0) + 1.0,
        self.toastLabel.frame.size.width,
        self.toastLabel.frame.size.height
    };
    
    CGRect toastFrame = self.toastView.frame;
    toastFrame.origin.x = self.currentNotchView.center.x - floorf(toastFrame.size.width / 2.0);
    toastFrame.origin.y = self.bounds.size.height - 32.0;
    self.toastView.frame = toastFrame;
    
    if (!self.toastView.superview) {
        [self insertSubview:self.toastView belowSubview:self.currentNotchView];
    }
    [self.toastView addSubview:self.toastLabel];
    
    self.toastView.alpha = 0.0;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.toastView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(hideToast) withObject:nil afterDelay:1.5];
                     }];
    
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

- (UIView *)toastView {
    if (!_toastView) {
        _toastView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_customise_privacy_label.png"]];
    }
    return _toastView;
}

- (UILabel *)toastLabel {
    if (!_toastLabel) {
        _toastLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _toastLabel.font = kToastFont;
        _toastLabel.textColor = kToastColour;
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.backgroundColor = [UIColor clearColor];
        _toastLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _toastLabel;
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
    
    [self toastMessage:[self infoForNotchIndex:notchIndex]];
    
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
            info = NSLocalizedString(@"SECRET", nil);
            break;
        case 1:
            info = NSLocalizedString(@"FRIENDS", nil);
            break;
        case 2:
            info = NSLocalizedString(@"PUBLIC", nil);
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

- (void)hideToast {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.toastView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                     }];
}

@end
