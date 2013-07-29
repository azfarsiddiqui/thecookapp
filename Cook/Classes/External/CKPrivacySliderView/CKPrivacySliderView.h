//
//  CKPrivacySliderView.h
//  CKNotchSliderControlDemo
//
//  Created by Jeff Tan-Ang on 29/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKNotchSliderView.h"

@protocol CKPrivacySliderViewDelegate <CKNotchSliderViewDelegate>

- (void)privacySelectedPrivateForSliderView:(CKNotchSliderView *)sliderView;
- (void)privacySelectedFriendsForSliderView:(CKNotchSliderView *)sliderView;
- (void)privacySelectedGlobalForSliderView:(CKNotchSliderView *)sliderView;

@end

@interface CKPrivacySliderView : CKNotchSliderView

- (id)initWithDelegate:(id<CKPrivacySliderViewDelegate>)delegate;

@end
