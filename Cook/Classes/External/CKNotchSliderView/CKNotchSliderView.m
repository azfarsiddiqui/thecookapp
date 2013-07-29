//
//  CKNotchSliderControl.m
//  CKNotchSliderControlDemo
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKNotchSliderView.h"

@interface CKNotchSliderView ()

@property (nonatomic, assign) NSInteger numNotches;
@property (nonatomic, assign) BOOL animating;

@end

@implementation CKNotchSliderView

#define kHeight 58.0

- (id)initWithNumNotches:(NSInteger)numNotches delegate:(id<CKNotchSliderViewDelegate>)delegate {
    if ([self initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.numNotches = numNotches;
        [self initTrack];
        [self selectNotch:0 animated:NO informDelegate:NO];
    }
    return self;
}

- (void)selectNotch:(NSInteger)notch {
    [self selectNotch:notch animated:YES];
}

- (void)selectNotch:(NSInteger)notch animated:(BOOL)animated {
    [self selectNotch:notch animated:animated informDelegate:YES];
}

- (void)selectNotch:(NSInteger)notch animated:(BOOL)animated informDelegate:(BOOL)informDelegate {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    self.currentNotchIndex = notch;
    if (animated) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self slideToNotchIndex:notch animated:animated];
                         }
                         completion:^(BOOL finished) {
                             if (informDelegate) {
                                 [self selectedNotchIndex:notch];
                             } else {
                                 [self initNotchIndex:notch];
                             }
                             self.animating = NO;
                         }];
    } else {
        [self slideToNotchIndex:notch animated:animated];
        if (informDelegate) {
            [self selectedNotchIndex:notch];
        } else {
            [self initNotchIndex:notch];
        }
        self.animating = NO;
    }
}

- (UIImage *)imageForLeftTrack {
    return [UIImage imageNamed:@"cook_edit_serves_notches_left.png"];
}

- (UIImage *)imageForMiddleTrack {
    return [UIImage imageNamed:@"cook_edit_serves_notches_mid.png"];
}

- (UIImage *)imageForRightTrack {
    return [UIImage imageNamed:@"cook_edit_serves_notches_right.png"];
}

- (UIImage *)imageForSlider {
    return [UIImage imageNamed:@"cook_edit_serves_slider.png"];
}
         
- (void)initNotchIndex:(NSInteger)selectedNotchIndex {
    // Initialise anything at notch index, usually on startup.
}

- (void)selectedNotchIndex:(NSInteger)selectedNotchIndex {
    if ([self.delegate respondsToSelector:@selector(notchSliderView:selectedIndex:)]) {
        [self.delegate notchSliderView:self selectedIndex:selectedNotchIndex];
    }
}

- (void)updateNotchSliderWithFrame:(CGRect)sliderFrame {
    self.currentNotchView.frame = sliderFrame;
}

- (void)slideToNotchIndex:(NSInteger)notchIndex animated:(BOOL)animated {
    UIImageView *trackNotch = [self.trackNotches objectAtIndex:notchIndex];
    self.currentNotchView.center = trackNotch.center;
}

#pragma mark - Lazy getters

- (UIImageView *)currentNotchView {
    if (!_currentNotchView) {
        _currentNotchView = [[UIImageView alloc] initWithImage:[self imageForSlider]];
        _currentNotchView.userInteractionEnabled = YES;
        
        // Register pan
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(notchPanned:)];
        [_currentNotchView addGestureRecognizer:panGesture];
        
        [self addSubview:_currentNotchView];
    }
    return _currentNotchView;
}

#pragma mark - Private methods

- (void)initTrack {
    CGRect frame = CGRectZero;
    self.trackNotches = [NSMutableArray arrayWithCapacity:self.numNotches];
    
    CGFloat trackOffset = 0.0;
    for (NSInteger trackIndex = 0; trackIndex < self.numNotches; trackIndex++) {
        UIImage *trackImage = [self trackImageForIndex:trackIndex];
        UIImageView *trackImageView = [[UIImageView alloc] initWithImage:trackImage];
        trackImageView.userInteractionEnabled = YES;
        trackImageView.frame = CGRectMake(trackOffset, 0.0, trackImage.size.width, trackImage.size.height);
        [self addSubview:trackImageView];
        
        // Register tap
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(trackTapped:)];
        [trackImageView addGestureRecognizer:tapGesture];
        
        // Update the current frame.
        frame = CGRectUnion(frame, trackImageView.frame);
        
        // Keep a reference to the notch.
        [self.trackNotches addObject:trackImageView];
        
        // Bump to next offset.
        trackOffset += trackImageView.frame.size.width;
    }
    
    // Update self frame.
    self.frame = frame;
}

- (UIImage *)trackImageForIndex:(NSInteger)trackIndex {
    if (trackIndex == 0) {
        return [self imageForLeftTrack];
    } else if (trackIndex == self.numNotches - 1) {
        return [self imageForRightTrack];
    } else {
        return [self imageForMiddleTrack];
    }
}

- (void)trackTapped:(UITapGestureRecognizer *)tapGesture {
    UIView *trackView = tapGesture.view;
    NSInteger trackIndex = [self.trackNotches indexOfObject:trackView];
    if (trackIndex != self.currentNotchIndex) {
        [self selectNotch:trackIndex];
    }
}

- (void)notchPanned:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self];
    CGRect frame = self.currentNotchView.frame;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        
        frame.origin.x += translation.x;
        
        // Cap on both ends.
        if (frame.origin.x < 0) {
            frame.origin.x = 0;
        } else if (frame.origin.x > (self.bounds.size.width - frame.size.width)) {
            frame.origin.x = (self.bounds.size.width - frame.size.width);
        }
        
        [self updateNotchSliderWithFrame:frame];
        
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        NSInteger selectedTrackIndex = [self currentNotchIndexForSliderFrame:frame];
        [self selectNotch:selectedTrackIndex];
    }
    
    [panGesture setTranslation:CGPointZero inView:self];
}

- (NSInteger)currentNotchIndexForSliderFrame:(CGRect)sliderFrame {
    NSInteger selectedTrackIndex = 0;
    CGRect intersection = CGRectZero;
    for (NSInteger trackIndex = 0; trackIndex < [self.trackNotches count]; trackIndex++) {
        UIImageView *trackImageView = [self.trackNotches objectAtIndex:trackIndex];
        CGRect trackIntersection = CGRectIntersection(trackImageView.frame, sliderFrame);
        if (trackIntersection.size.width >= intersection.size.width) {
            selectedTrackIndex = trackIndex;
            intersection = trackIntersection;
        }
    }
    return selectedTrackIndex;
}

@end
