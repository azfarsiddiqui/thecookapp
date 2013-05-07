//
//  CKProgressView.h
//  UIProgressViewDemo
//
//  Created by Jeff Tan-Ang on 7/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKProgressView : UIProgressView

- (id)initWithWidth:(CGFloat)width;
- (void)setProgress:(float)progress delay:(NSTimeInterval)delay completion:(void (^)())completion;

@end
