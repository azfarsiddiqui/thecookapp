//
//  OverlayViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 23/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;
@class CKProgressView;
@class CKActivityIndicatorView;

@interface OverlayViewController : UIViewController

@property (nonatomic, strong) UILabel *statusMessageLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) CKProgressView *progressView;
@property (nonatomic, strong) CKActivityIndicatorView *overlayActivityView;

- (void)clearStatusMessage;
- (void)displayStatusMessage:(NSString *)statusMessage;
- (void)displayStatusMessage:(NSString *)statusMessage activity:(BOOL)activity;

- (void)showProgress:(CGFloat)progress message:(NSString *)message;
- (void)showProgress:(CGFloat)progress delay:(NSTimeInterval)delay completion:(void (^)())completion;
- (void)hideProgress;

@end
