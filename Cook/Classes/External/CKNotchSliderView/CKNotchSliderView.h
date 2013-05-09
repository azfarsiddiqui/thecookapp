//
//  CKNotchSliderControl.h
//  CKNotchSliderControlDemo
//
//  Created by Jeff Tan-Ang on 8/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKNotchSliderView : UIView

@property (nonatomic, assign) NSInteger currentNotchIndex;

- (id)initWithNumNotches:(NSInteger)numNotches unit:(NSInteger)unit;

@end
