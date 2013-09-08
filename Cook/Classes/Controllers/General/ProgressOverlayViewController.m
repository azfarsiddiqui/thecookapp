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
@property (nonatomic, strong) UILabel *titleLabel;
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
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = [self.title uppercaseString];
    titleLabel.font = [Theme progressSavingFont];
    titleLabel.textColor = [Theme progressSavingColour];
    [titleLabel sizeToFit];
    titleLabel.frame = (CGRect){
        floorf((self.view.bounds.size.width - titleLabel.frame.size.width) / 2.0),
        self.progressView.frame.origin.y - titleLabel.frame.size.height + 13.0,
        titleLabel.frame.size.width,
        titleLabel.frame.size.height
    };
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)updateWithTitle:(NSString *)title {
    [self updateWithTitle:title delay:0.0 completion:nil];
}

- (void)updateWithTitle:(NSString *)title delay:(NSTimeInterval)delay completion:(void (^)())completion {
    self.title = title;
    self.titleLabel.text = [title uppercaseString];
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.titleLabel.frame.size.width) / 2.0),
        self.progressView.frame.origin.y - self.titleLabel.frame.size.height + 13.0,
        self.titleLabel.frame.size.width,
        self.titleLabel.frame.size.height
    };
    
    if (completion != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                completion();
        });
    }
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
