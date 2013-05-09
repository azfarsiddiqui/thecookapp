//
//  CKDialerView.h
//  CKDialerViewDemo
//
//  Created by Jeff Tan-Ang on 9/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKDialerControlDelegate <NSObject>

- (void)dialerControlSelectedIndex:(NSInteger)selectedIndex;

@end

@interface CKDialerControl : UIControl

@property (nonatomic, assign) NSInteger selectedOptionIndex;

- (id)initWithUnitDegrees:(CGFloat)unitDegrees delegate:(id<CKDialerControlDelegate>)delegate;
- (void)selectOptionAtIndex:(NSInteger)optionIndex;
- (void)selectOptionAtIndex:(NSInteger)optionIndex animated:(BOOL)animated;
                          
@end
