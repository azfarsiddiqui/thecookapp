//
//  SaveOverlayViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ProgressOverlayViewController.h"
#import "ModalOverlayHelper.h"
#import "CKProgressView.h"
#import "Theme.h"

@interface ProgressOverlayViewController ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) CKProgressView *progressView;

@end

@implementation ProgressOverlayViewController

- (id)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = YES;  // To block touches.
    self.view.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    // Add progress view.
    CKProgressView *progressView = [[CKProgressView alloc] initWithWidth:300.0];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    progressView.frame = (CGRect){
        floorf((self.view.bounds.size.width - progressView.frame.size.width) / 2.0),
        floorf((self.view.bounds.size.height - progressView.frame.size.height) / 2.0) - 13.0,
        progressView.frame.size.width,
        progressView.frame.size.height};
    [self.view addSubview:progressView];
    self.progressView = progressView;
    
    // Saving text.
    UILabel *savingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    savingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    savingLabel.backgroundColor = [UIColor clearColor];
    savingLabel.text = [self.title uppercaseString];
    savingLabel.font = [Theme progressSavingFont];
    savingLabel.textColor = [Theme progressSavingColour];
    [savingLabel sizeToFit];
    savingLabel.frame = (CGRect){
        floorf((self.view.bounds.size.width - savingLabel.frame.size.width) / 2.0),
        self.progressView.frame.origin.y - savingLabel.frame.size.height + 13.0,
        savingLabel.frame.size.width,
        savingLabel.frame.size.height
    };
    [self.view addSubview:savingLabel];
}

- (void)updateProgress:(CGFloat)progress {
    [self.progressView setProgress:progress];
}

- (void)updateProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressView setProgress:progress animated:animated];
}

- (void)updateProgress:(float)progress delay:(NSTimeInterval)delay completion:(void (^)())completion {
    [self.progressView setProgress:progress delay:delay completion:completion];
}

@end
