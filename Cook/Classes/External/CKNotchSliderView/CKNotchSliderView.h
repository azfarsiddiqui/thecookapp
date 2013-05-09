//
//  CKNotchSliderControl.h
//  CKNotchSliderControlDemo
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKNotchSliderViewDelegate <NSObject>

- (void)notchSliderViewSelectedIndex:(NSInteger)notchIndex;

@end

@interface CKNotchSliderView : UIView

@property (nonatomic, assign) NSInteger currentNotchIndex;

- (id)initWithNumNotches:(NSInteger)numNotches delegate:(id<CKNotchSliderViewDelegate>)delegate;
- (void)selectNotch:(NSInteger)notch;
- (void)selectNotch:(NSInteger)notch animated:(BOOL)animated;

@end
