//
//  ServesAndTimeEditViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesAndTimeEditViewController.h"
#import "CKDialerControl.h"
#import "CKNotchSliderView.h"
#import "Theme.h"

@interface ServesAndTimeEditViewController () <CKDialerControlDelegate, CKNotchSliderViewDelegate>

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *servesTitleLabel;
@property (nonatomic, strong) UILabel *servesLabel;
@property (nonatomic, strong) CKNotchSliderView *servesSlider;

@property (nonatomic, strong) UILabel *prepTitleLabel;
@property (nonatomic, strong) UILabel *prepLabel;
@property (nonatomic, strong) CKDialerControl *prepDialer;

@property (nonatomic, strong) UILabel *cookTitleLabel;
@property (nonatomic, strong) UILabel *cookLabel;
@property (nonatomic, strong) CKDialerControl *cookDialer;

@end

@implementation ServesAndTimeEditViewController

#define kSize           CGSizeMake(850.0, 580.0)
#define kContentInsets  UIEdgeInsetsMake(40.0, 50.0, 50.0, 50.0)
#define kDialerGap      100.0
#define kTitleLabelGap  10.0
#define kTitleDialerGap 5.0
#define kUnitServes     2
#define kUnitMinutes    10

- (UIView *)createTargetEditView {
    [self initServes];
    [self initDialers];
    return self.containerView;
}

#pragma mark - Lazy getters

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - kSize.width) / 2.0),
                                                                  floorf((self.view.bounds.size.height - kSize.height) / 2.0),
                                                                  kSize.width,
                                                                  kSize.height)];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (UILabel *)servesTitleLabel {
    if (!_servesTitleLabel) {
        _servesTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _servesTitleLabel.backgroundColor = [UIColor clearColor];
        _servesTitleLabel.font = [Theme editServesTitleFont];
        _servesTitleLabel.textColor = [Theme editServesTitleColour];
        _servesTitleLabel.text = @"SERVES";
        [_servesTitleLabel sizeToFit];
    }
    return _servesTitleLabel;
}

- (UILabel *)servesLabel {
    if (!_servesLabel) {
        _servesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _servesLabel.backgroundColor = [UIColor clearColor];
        _servesLabel.font = [Theme editServesFont];
        _servesLabel.textColor = [Theme editServesColour];
        _servesLabel.text = @"2";
        [_servesLabel sizeToFit];
    }
    return _servesLabel;
}

- (CKNotchSliderView *)servesSlider {
    if (!_servesSlider) {
        _servesSlider = [[CKNotchSliderView alloc] initWithNumNotches:5 delegate:self];
    }
    return _servesSlider;
}

- (UILabel *)prepTitleLabel {
    if (!_prepTitleLabel) {
        _prepTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _prepTitleLabel.backgroundColor = [UIColor clearColor];
        _prepTitleLabel.font = [Theme editPrepTitleFont];
        _prepTitleLabel.textColor = [Theme editPrepTitleColour];
        _prepTitleLabel.text = @"PREP";
        [_prepTitleLabel sizeToFit];
    }
    return _prepTitleLabel;
}

- (UILabel *)prepLabel {
    if (!_prepLabel) {
        _prepLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _prepLabel.backgroundColor = [UIColor clearColor];
        _prepLabel.font = [Theme editPrepFont];
        _prepLabel.textColor = [Theme editPrepColour];
        _prepLabel.text = @"0m";
        [_prepLabel sizeToFit];
    }
    return _prepLabel;
}

- (CKDialerControl *)prepDialer {
    if (!_prepDialer) {
        _prepDialer = [[CKDialerControl alloc] initWithUnitDegrees:10 delegate:self];
    }
    return _prepDialer;
}

- (UILabel *)cookTitleLabel {
    if (!_cookTitleLabel) {
        _cookTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cookTitleLabel.backgroundColor = [UIColor clearColor];
        _cookTitleLabel.font = [Theme editCookTitleFont];
        _cookTitleLabel.textColor = [Theme editCookTitleColour];
        _cookTitleLabel.text = @"COOK";
        [_cookTitleLabel sizeToFit];
    }
    return _cookTitleLabel;
}

- (UILabel *)cookLabel {
    if (!_cookLabel) {
        _cookLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cookLabel.backgroundColor = [UIColor clearColor];
        _cookLabel.font = [Theme editCookFont];
        _cookLabel.textColor = [Theme editCookColour];
        _cookLabel.text = @"0m";
        [_cookLabel sizeToFit];
    }
    return _cookLabel;
}

- (CKDialerControl *)cookDialer {
    if (!_cookDialer) {
        _cookDialer = [[CKDialerControl alloc] initWithUnitDegrees:10 delegate:self];
    }
    return _cookDialer;
}

#pragma mark - CKNotchSliderViewDelegate methods

- (void)notchSliderView:(CKNotchSliderView *)sliderView selectedIndex:(NSInteger)notchIndex {
    NSInteger serves = (notchIndex + 1) * kUnitServes;
    self.servesLabel.text = [NSString stringWithFormat:@"%d", serves];
    [self.servesLabel sizeToFit];
}

#pragma mark - CKDialerControlDelegate methods

- (void)dialerControl:(CKDialerControl *)dialerControl selectedIndex:(NSInteger)selectedIndex {
    NSInteger minutes = selectedIndex * kUnitMinutes;
    NSString *minutesDisplay = [NSString stringWithFormat:@"%dm", minutes];
    if (dialerControl == self.prepDialer) {
        self.prepLabel.text = minutesDisplay;
        [self.prepLabel sizeToFit];
    } else if (dialerControl == self.cookDialer) {
        self.cookLabel.text = minutesDisplay;
        [self.cookLabel sizeToFit];
    }
}

#pragma mark - Private methods

- (void)initServes {
    CGFloat requiredWidth = self.servesTitleLabel.frame.size.width + kTitleLabelGap + self.servesLabel.frame.size.width;
    CGSize availableSize = [self availableSize];
    self.servesTitleLabel.frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - requiredWidth) / 2.0),
                                             kContentInsets.top,
                                             self.servesTitleLabel.frame.size.width,
                                             self.servesTitleLabel.frame.size.height);
    self.servesLabel.frame = CGRectMake(self.servesTitleLabel.frame.origin.x + self.servesTitleLabel.frame.size.width + kTitleLabelGap,
                                        self.servesTitleLabel.frame.origin.y,
                                        self.servesLabel.frame.size.width,
                                        self.servesLabel.frame.size.height);
    self.servesSlider.frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - self.servesSlider.frame.size.width) / 2.0),
                                         self.servesTitleLabel.frame.origin.y + self.servesTitleLabel.frame.size.height + 10.0,
                                         self.servesSlider.frame.size.width,
                                         self.servesSlider.frame.size.height);
    [self.containerView addSubview:self.servesTitleLabel];
    [self.containerView addSubview:self.servesLabel];
    [self.containerView addSubview:self.servesSlider];
}

- (void)initDialers {
    CGFloat requiredWidth = self.prepDialer.frame.size.width + kDialerGap + self.cookDialer.frame.size.width;
    CGSize availableSize = [self availableSize];
    self.prepDialer.frame = CGRectMake(kContentInsets.left + floorf((availableSize.width - requiredWidth) / 2.0),
                                       self.containerView.bounds.size.height - kContentInsets.bottom - self.prepDialer.frame.size.height,
                                       self.prepDialer.frame.size.width,
                                       self.prepDialer.frame.size.height);
    
    requiredWidth = self.prepTitleLabel.frame.size.width + kTitleLabelGap + self.prepLabel.frame.size.width;
    self.prepTitleLabel.frame = CGRectMake(self.prepDialer.frame.origin.x + floorf((self.prepDialer.frame.size.width - requiredWidth) / 2.0),
                                           self.prepDialer.frame.origin.y - kTitleDialerGap - self.prepTitleLabel.frame.size.height,
                                           self.prepTitleLabel.frame.size.width,
                                           self.prepTitleLabel.frame.size.height);
    self.prepLabel.frame = CGRectMake(self.prepTitleLabel.frame.origin.x + self.prepTitleLabel.frame.size.width + kTitleLabelGap,
                                      self.prepTitleLabel.frame.origin.y,
                                      self.prepLabel.frame.size.width,
                                      self.prepLabel.frame.size.height);
    
    self.cookDialer.frame = CGRectMake(self.prepDialer.frame.origin.x + self.prepDialer.frame.size.width + kDialerGap,
                                       self.containerView.bounds.size.height - kContentInsets.bottom - self.cookDialer.frame.size.height,
                                       self.cookDialer.frame.size.width,
                                       self.cookDialer.frame.size.height);
    
    requiredWidth = self.cookTitleLabel.frame.size.width + kTitleLabelGap + self.cookLabel.frame.size.width;
    self.cookTitleLabel.frame = CGRectMake(self.cookDialer.frame.origin.x + floorf((self.cookDialer.frame.size.width - requiredWidth) / 2.0),
                                           self.cookDialer.frame.origin.y - kTitleDialerGap - self.cookTitleLabel.frame.size.height,
                                           self.cookTitleLabel.frame.size.width,
                                           self.cookTitleLabel.frame.size.height);
    self.cookLabel.frame = CGRectMake(self.cookTitleLabel.frame.origin.x + self.cookTitleLabel.frame.size.width + kTitleLabelGap,
                                      self.cookTitleLabel.frame.origin.y,
                                      self.cookLabel.frame.size.width,
                                      self.cookLabel.frame.size.height);
    
    [self.containerView addSubview:self.prepTitleLabel];
    [self.containerView addSubview:self.prepLabel];
    [self.containerView addSubview:self.prepDialer];
    [self.containerView addSubview:self.cookTitleLabel];
    [self.containerView addSubview:self.cookLabel];
    [self.containerView addSubview:self.cookDialer];
}

- (CGSize)availableSize {
    return CGSizeMake(self.containerView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.containerView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

@end
