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

@interface OverlayViewController ()

@end

@implementation OverlayViewController

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Snapshot the benchtop to improve performance (flatten views) on this VC.
    UIView *snapshotView = [[[AppHelper sharedInstance] rootView] snapshotViewAfterScreenUpdates:YES];
    [self.view addSubview:snapshotView];

    // Overlay view.
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayView.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:overlayView];
}

@end
