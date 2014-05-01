//
//  TimeNotchSliderView.m
//  Cook
//
//  Created by Gerald on 1/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "TimeSliderView.h"
#import "ImageHelper.h"

@interface TimeSliderView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation TimeSliderView

#define kControlHeight 50

- (id)init {
    self = [super init];
    if (!self) return nil;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
    [self addGestureRecognizer:self.tapGesture];
    
    return self;
}

//- (void)tappedOnSlider {
//    CGPoint touchPoint = [self.tapGesture locationInView:self];
//    [self setValue:(self.maximumValue * touchPoint.x)/self.frame.size.width animated:YES];
//    [self sendActionsForControlEvents:UIControlEventValueChanged];
//}

- (void)sliderTapped:(UIGestureRecognizer *)g {
    UISlider* s = (UISlider*)g.view;
    if (s.highlighted)
        return; // tap on thumb, let slider deal with it
    CGPoint pt = [g locationInView: s];
    CGFloat percentage = pt.x / s.bounds.size.width;
    CGFloat delta = percentage * (s.maximumValue - s.minimumValue);
    CGFloat value = s.minimumValue + delta;
    [s setValue:value animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

//- (void)updateNotchSliderWithFrame:(CGRect)sliderFrame {
//    [super updateNotchSliderWithFrame:sliderFrame];
//    
//    // Check intersection to interactively report values.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (NSInteger trackIndex = 0; trackIndex < [self.trackNotches count]; trackIndex++) {
//            UIImageView *trackImageView = [self.trackNotches objectAtIndex:trackIndex];
//            CGRect trackIntersection = CGRectIntersection(trackImageView.frame, sliderFrame);
//            
//            // Figure out the intersection of the slider, if fully covered, then fully visible.
//            CGFloat intersectionRatio = MIN(1.0, trackIntersection.size.width / sliderFrame.size.width);
//            
//            if (intersectionRatio > 0.35 && self.currentNotchIndex != trackIndex) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.delegate notchSliderView:self selectedIndex:trackIndex];
//                });
//            }
//        }
//    });
//}
//
//- (UIImage *)trackImageForIndex:(NSInteger)trackIndex {
//    if (trackIndex == 0) {
//        return [self imageForLeftTrack];
//    } else if (trackIndex == self.numNotches - 1) {
//        return [self imageForRightTrack];
//    } else {
//        return [self imageForMiddleTrackForIndex:trackIndex];
//    }
//}
//
//- (UIImage *)imageForMiddleTrackForIndex:(NSInteger)trackIndex {
//    return trackIndex%2 == 0 ? [UIImage imageNamed:@"cook_edit_smooth2_notches_mid.png"] : [UIImage imageNamed:@"cook_edit_smooth_notches_mid.png"];
//}
//
//- (UIImage *)imageForSliderSelected:(BOOL)selected {
//    return selected ? [UIImage imageNamed:@"cook_edit_time_slider.png"] : [UIImage imageNamed:@"cook_edit_time_slider.png"];
//}

@end
