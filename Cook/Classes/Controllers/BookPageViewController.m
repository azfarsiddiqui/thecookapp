//
//  BookPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookPageViewController.h"
#import "ViewHelper.h"

@interface BookPageViewController ()

@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation BookPageViewController

#define kContentInsets  (UIEdgeInsets){ 30.0, 20.0, 0.0, 0.0 }

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSideShadowViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)addCloseButtonWhite:(BOOL)white {
    [self.closeButton removeFromSuperview];
    self.closeButton = [ViewHelper buttonWithImage:[self closeButtonImageForWhite:white]
                                            target:self selector:@selector(closeTapped:)];
    self.closeButton.frame = (CGRect){
        kContentInsets.left,
        kContentInsets.top,
        self.closeButton.frame.size.width,
        self.closeButton.frame.size.height
    };
    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.closeButton];
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

- (void)closeTapped:(id)sender {
    DLog();
    [self.bookPageDelegate bookPageViewControllerCloseRequested];
}

- (UIImage *)closeButtonImageForWhite:(BOOL)white {
    NSString *imageName = [NSString stringWithFormat:@"cook_book_inner_icon_close_%@.png", white ? @"light" : @"dark"];
    return [UIImage imageNamed:imageName];
}

@end
