//
//  BookPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookPageViewController.h"

@interface BookPageViewController ()

@end

@implementation BookPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSideShadowViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Private methods

- (void)initSideShadowViews {
    DLog();
    
    // Left shadow.
    UIImageView *leftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_pageshadow_left.png"]];
    leftShadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
    leftShadowView.frame = (CGRect) {
        self.view.bounds.origin.x - leftShadowView.frame.size.width,
        self.view.bounds.origin.y,
        leftShadowView.frame.size.width,
        self.view.bounds.size.height
    };
    [self.view addSubview:leftShadowView];
    
    // Right shadow.
    UIImageView *rightShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_pageshadow_right.png"]];
    rightShadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    rightShadowView.frame = (CGRect) {
        self.view.bounds.size.width,
        self.view.bounds.origin.y,
        rightShadowView.frame.size.width,
        self.view.bounds.size.height
    };
    [self.view addSubview:rightShadowView];
}

@end
