//
//  ServesNotchSliderView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 6/12/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesNotchSliderView.h"

@implementation ServesNotchSliderView

- (void)updateNotchSliderWithFrame:(CGRect)sliderFrame {
    [super updateNotchSliderWithFrame:sliderFrame];
    
    // Check intersection to interactively report values.
    for (NSInteger trackIndex = 0; trackIndex < [self.trackNotches count]; trackIndex++) {
        UIImageView *trackImageView = [self.trackNotches objectAtIndex:trackIndex];
        CGRect trackIntersection = CGRectIntersection(trackImageView.frame, sliderFrame);
        
        // Figure out the intersection of the slider, if fully covered, then fully visible.
        CGFloat intersectionRatio = MIN(1.0, trackIntersection.size.width / sliderFrame.size.width);
        
        if (intersectionRatio > 0.5 && self.currentNotchIndex != trackIndex) {
            [self.delegate notchSliderView:self selectedIndex:trackIndex];
        }
    }
}

@end
