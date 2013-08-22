//
//  CKNotchSliderControl.h
//  CKNotchSliderControlDemo
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKNotchSliderView;

@protocol CKNotchSliderViewDelegate <NSObject>

@optional
- (void)notchSliderView:(CKNotchSliderView *)sliderView selectedIndex:(NSInteger)notchIndex;

@end

@interface CKNotchSliderView : UIView

@property (nonatomic, weak) id<CKNotchSliderViewDelegate> delegate;
@property (nonatomic, assign) NSInteger currentNotchIndex;
@property (nonatomic, strong) UIImageView *currentNotchView;
@property (nonatomic, strong) NSMutableArray *trackNotches;
@property (nonatomic, assign) NSInteger numNotches;

- (id)initWithNumNotches:(NSInteger)numNotches delegate:(id<CKNotchSliderViewDelegate>)delegate;
- (void)selectNotch:(NSInteger)notch;
- (void)selectNotch:(NSInteger)notch animated:(BOOL)animated;
- (UIImage *)imageForLeftTrack;
- (UIImage *)imageForMiddleTrack;
- (UIImage *)imageForRightTrack;
- (UIImage *)imageForSlider;
- (UIImage *)imageForSliderSelected:(BOOL)selected;
- (void)initNotchIndex:(NSInteger)selectedNotchIndex;
- (void)selectedNotchIndex:(NSInteger)selectedNotchIndex;
- (void)updateNotchSliderWithFrame:(CGRect)sliderFrame;
- (void)slideToNotchIndex:(NSInteger)notchIndex animated:(BOOL)animated;

@end
