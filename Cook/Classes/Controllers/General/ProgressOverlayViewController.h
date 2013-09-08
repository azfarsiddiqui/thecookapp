//
//  SaveOverlayViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 7/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKProgressView;

@interface ProgressOverlayViewController : UIViewController

- (id)initWithTitle:(NSString *)title;
- (void)updateWithTitle:(NSString *)title;
- (void)updateWithTitle:(NSString *)title delay:(NSTimeInterval)delay completion:(void (^)())completion;
- (void)updateProgress:(CGFloat)progress;
- (void)updateProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)updateProgress:(float)progress delay:(NSTimeInterval)delay completion:(void (^)())completion;

@end
