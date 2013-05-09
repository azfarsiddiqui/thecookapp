//
//  CKDialerView.m
//  CKDialerViewDemo
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKDialerControl.h"

@interface CKDialerControl ()

@property (nonatomic, assign) id<CKDialerControlDelegate> delegate;
@property (nonatomic, strong) UIView *dialerView;
@property (nonatomic, assign) CGAffineTransform startTransform;
@property (nonatomic, assign) CGFloat unitDegrees;
@property (nonatomic, assign) CGFloat deltaAngle;

@end

//
// Thanks to http://www.raywenderlich.com/9864/how-to-create-a-rotating-wheel-control-with-uikit
//
@implementation CKDialerControl

- (id)initWithUnitDegrees:(CGFloat)unitDegrees delegate:(id<CKDialerControlDelegate>)delegate {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.unitDegrees = unitDegrees;
        self.delegate = delegate;
        self.selectedOptionIndex = 0;
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_timedial_bg.png"]];
        self.frame = backgroundView.frame;
        backgroundView.userInteractionEnabled = NO;
        [self addSubview:backgroundView];
        
        UIImageView *dialerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_edit_timedial_dial.png"]];
        dialerView.userInteractionEnabled = NO;
        [self addSubview:dialerView];
        self.dialerView = dialerView;
    }
    return self;
}

- (void)selectOptionAtIndex:(NSInteger)optionIndex {
    [self selectOptionAtIndex:optionIndex animated:YES];
}

- (void)selectOptionAtIndex:(NSInteger)optionIndex animated:(BOOL)animated {
    NSInteger maxIndex = [self maxOptionIndex];
    if (optionIndex > maxIndex) {
        return;
    }
    
    self.selectedOptionIndex = optionIndex;
    CGFloat requiredRadians = optionIndex * [self unitRadians];
    CGAffineTransform transform = CGAffineTransformMakeRotation(requiredRadians);
    
    if (animated) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.dialerView.transform = transform;
                         }
                         completion:^(BOOL finished) {
                         }];
        
    } else {
        self.dialerView.transform = transform;
    }
}

#pragma mark - UIControl methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // 1 - Get touch position
    CGPoint touchPoint = [touch locationInView:self];
    
    // 2 - Calculate distance from center
    float dx = touchPoint.x - self.dialerView.center.x;
    float dy = touchPoint.y - self.dialerView.center.y;
    
    // 3 - Calculate arctangent value
    self.deltaAngle = atan2(dy,dx);
    
    // 4 - Save current transform
    self.startTransform = self.dialerView.transform;
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {

    CGPoint pt = [touch locationInView:self];
    CGFloat dx = pt.x  - self.dialerView.center.x;
    CGFloat dy = pt.y  - self.dialerView.center.y;
    CGFloat ang = atan2(dy,dx);
    CGFloat angleDifference = self.deltaAngle - ang;
    
    // Figure out the radians to snap to.
    CGFloat unitRadians = [self unitRadians];
    
    // Determine the transform required.
    CGAffineTransform transform = CGAffineTransformRotate(self.startTransform, -angleDifference);
    
    // Then grab the overall radians that would've rotated.
    CGFloat overallRadians = atan2f(transform.b, transform.a);
    
    // Get the discrete snap radians by dividing by radians-per-unit.
    NSInteger remainder = overallRadians / unitRadians;
    CGFloat snapRadians = unitRadians * remainder;
    if (remainder < 0) {
        remainder = [self maxOptionIndex] + remainder - 1;
    }
    
    // Keep it within the range.
    if (remainder >= 0 && remainder <= [self maxOptionIndex] && abs(self.selectedOptionIndex - remainder) == 1) {
        self.dialerView.transform = CGAffineTransformMakeRotation(snapRadians);
        self.selectedOptionIndex = remainder;
        
        // Inform delegate.
        [self.delegate dialerControlSelectedIndex:self.selectedOptionIndex];
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
}

#pragma mark - Private methods

- (CGFloat)unitRadians {
    return [self degreesToRadians:self.unitDegrees];
}

- (CGFloat)degreesToRadians:(CGFloat)degrees {
    return degrees * M_PI / 180;
}

- (CGFloat)radiansToDegrees:(CGFloat)radians {
    return radians * 180 / M_PI;
}

- (NSInteger)maxOptionIndex {
    return (360.0 / self.unitDegrees) -1;
}

@end
