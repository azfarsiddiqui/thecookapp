//
//  OverlayViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "OverlayViewController.h"
#import "ModalOverlayHelper.h"
#import "AppHelper.h"
#import "RecipeDetailsViewController.h"
#import "BookModalViewController.h"
#import "CKProgressView.h"
#import "CKActivityIndicatorView.h"

@interface OverlayViewController ()

@end

@implementation OverlayViewController

#define kStatusActivityGap  10.0
#define kStatusProgressGap  10.0

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    self.view.clipsToBounds = YES;
}

- (void)clearStatusMessage {
    [self.overlayActivityView stopAnimating];
    [self.progressView removeFromSuperview];
    [self.statusMessageLabel removeFromSuperview];
}

- (void)displayStatusMessage:(NSString *)statusMessage {
    [self displayStatusMessage:statusMessage activity:NO];
}

- (void)displayStatusMessage:(NSString *)statusMessage activity:(BOOL)activity {
    
    // Status message.
    self.statusMessageLabel.text = statusMessage;
    [self.statusMessageLabel sizeToFit];
    self.statusMessageLabel.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.statusMessageLabel.frame.size.width) / 2.0),
        floorf((self.view.bounds.size.height - self.statusMessageLabel.frame.size.height) / 2.0),
        self.statusMessageLabel.frame.size.width,
        self.statusMessageLabel.frame.size.height
    };
    
    if (!self.statusMessageLabel.superview) {
        [self.view addSubview:self.statusMessageLabel];
    }
    
    // Spinner.
    if (activity) {
        if (![self.overlayActivityView isAnimating]) {
            if (!self.overlayActivityView.superview) {
                [self.view addSubview:self.overlayActivityView];
            }
            [self.overlayActivityView startAnimating];
        }
        
        // Reposition the status message.
        CGRect statusFrame = self.statusMessageLabel.frame;
        statusFrame.origin.y = self.overlayActivityView.frame.origin.y - statusFrame.size.height - kStatusActivityGap;
        self.statusMessageLabel.frame = statusFrame;
        
    } else {
        [self.overlayActivityView stopAnimating];
    }
    
}

- (void)showProgress:(CGFloat)progress {
    
    // No spinner while in progress.
    [self.overlayActivityView stopAnimating];
    
    if (!self.progressView.superview) {
        [self.view addSubview:self.progressView];
    }
    
    // Reposition the status message.
    CGRect statusFrame = self.statusMessageLabel.frame;
    statusFrame.origin.y = self.progressView.frame.origin.y - statusFrame.size.height - kStatusProgressGap;
    self.statusMessageLabel.frame = statusFrame;

    [self.progressView setProgress:progress animated:YES];
}

- (void)showProgress:(CGFloat)progress delay:(NSTimeInterval)delay completion:(void (^)())completion {
    
    // No spinner while in progress.
    [self.overlayActivityView stopAnimating];
    
    if (!self.progressView.superview) {
        [self.view addSubview:self.progressView];
    }
    
   [self.progressView setProgress:progress delay:delay completion:completion];
}

- (void)hideProgress {
    [self.progressView removeFromSuperview];
}

#pragma mark - Properties

- (UILabel *)statusMessageLabel {
    if (!_statusMessageLabel) {
        _statusMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusMessageLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        _statusMessageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        _statusMessageLabel.textColor = [UIColor whiteColor];
    }
    return _statusMessageLabel;
}

- (CKActivityIndicatorView *)overlayActivityView {
    if (!_overlayActivityView) {
        _overlayActivityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        _overlayActivityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        _overlayActivityView.center = self.view.center;
    }
    return _overlayActivityView;
}

- (CKProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[CKProgressView alloc] initWithWidth:300.0];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        _progressView.frame = (CGRect){
            floorf((self.view.bounds.size.width - _progressView.frame.size.width) / 2.0),
            floorf((self.view.bounds.size.height - _progressView.frame.size.height) / 2.0) - 13.0,
            _progressView.frame.size.width,
            _progressView.frame.size.height};
    }
    return _progressView;
}

@end
