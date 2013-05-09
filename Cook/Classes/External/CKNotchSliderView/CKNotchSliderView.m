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
@property (nonatomic, assign) CGFloat unit;
@property (nonatomic, strong) NSMutableArray *trackNotches;
@property (nonatomic, strong) UIImageView *currentNotchView;

@end

@implementation CKNotchSliderView

#define kHeight 58.0

- (id)initWithNumNotches:(NSInteger)numNotches unit:(NSInteger)unit {
    if ([self initWithFrame:CGRectZero]) {
        self.numNotches = numNotches;
        self.unit = unit;
        [self initTrack];
        [self selectNotch:0 animated:NO];
    }
    return self;
}

#pragma mark - Lazy getters

- (UIImageView *)currentNotchView {
    if (!_currentNotchView) {
        _currentNotchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_serves_slider.png"]];
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

- (void)selectNotch:(NSInteger)notch {
    [self selectNotch:notch animated:YES];
}

- (void)selectNotch:(NSInteger)notch animated:(BOOL)animated {
    self.currentNotchIndex = notch;
    UIImageView *trackNotch = [self.trackNotches objectAtIndex:notch];
    if (animated) {
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.currentNotchView.center = trackNotch.center;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.currentNotchView.center = trackNotch.center;
    }
}

- (UIImage *)trackImageForIndex:(NSInteger)trackIndex {
    if (trackIndex == 0) {
        return [UIImage imageNamed:@"cook_edit_serves_notches_left.png"];
    } else if (trackIndex == self.numNotches - 1) {
        return [UIImage imageNamed:@"cook_edit_serves_notches_right.png"];
    } else {
        return [UIImage imageNamed:@"cook_edit_serves_notches_mid.png"];
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
        
        self.currentNotchView.frame = frame;
        
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
        
        NSInteger selectedTrackIndex = 0;
        CGRect intersection = CGRectZero;
        for (NSInteger trackIndex = 0; trackIndex < [self.trackNotches count]; trackIndex++) {
            UIImageView *trackImageView = [self.trackNotches objectAtIndex:trackIndex];
            
            CGRect trackIntersection = CGRectIntersection(trackImageView.frame, frame);
            if (trackIntersection.size.width >= intersection.size.width) {
                selectedTrackIndex = trackIndex;
                intersection = trackIntersection;
            }
        }
        
        [self selectNotch:selectedTrackIndex];
    }
    
    [panGesture setTranslation:CGPointZero inView:self];
}

@end
