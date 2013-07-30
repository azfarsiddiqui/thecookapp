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
@property (nonatomic, strong) UIImageView *leftShadowView;
@property (nonatomic, strong) UIImageView *rightShadowView;

@end

@implementation BookPageViewController

#define kContentInsets  (UIEdgeInsets){ 30.0, 20.0, 0.0, 0.0 }

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Apply shadows after everything has been loaded in viewDidLoad.
    [self applyPageEdgeShadows];
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

- (void)applyPageEdgeShadows {
    [self.view addSubview:self.leftShadowView];
    [self.view addSubview:self.rightShadowView];
}

#pragma mark - Properties

- (UIImageView *)leftShadowView {
    if (!_leftShadowView) {
        _leftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_pageshadow_left.png"]];
        _leftShadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
        _leftShadowView.frame = (CGRect) {
            self.view.bounds.origin.x - _leftShadowView.frame.size.width + 1.0,  // Tuck 1pt in.
            self.view.bounds.origin.y,
            _leftShadowView.frame.size.width,
            self.view.bounds.size.height
        };
    }
    return _leftShadowView;
}

- (UIImageView *)rightShadowView {
    if (!_rightShadowView) {
        _rightShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_pageshadow_right.png"]];
        _rightShadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
        _rightShadowView.frame = (CGRect) {
            self.view.bounds.size.width - 1.0,  // Tuck 1pt in.
            self.view.bounds.origin.y,
            self.rightShadowView.frame.size.width,
            self.view.bounds.size.height
        };
    }
    return _rightShadowView;
}

#pragma mark - Private methods

- (void)closeTapped:(id)sender {
    DLog();
    [self.bookPageDelegate bookPageViewControllerCloseRequested];
}

- (UIImage *)closeButtonImageForWhite:(BOOL)white {
    NSString *imageName = [NSString stringWithFormat:@"cook_book_inner_icon_close_%@.png", white ? @"light" : @"dark"];
    return [UIImage imageNamed:imageName];
}

@end
