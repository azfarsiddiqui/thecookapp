//
//  UserViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 20/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "AccountViewController.h"
#import "CKUserInfoView.h"
#import "ViewHelper.h"

@interface AccountViewController ()

@property (nonatomic, weak) id<AccountViewControllerDelegate> delegate;
@property (nonatomic, strong) CKUser *user;

@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation AccountViewController

#define kContentInsets              (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kHeaderHeight               110.0

- (id)initWithUser:(CKUser *)user delegate:(id<AccountViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.user = user;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.blurredImageView];
    [self.view addSubview:self.closeButton];
}

#pragma mark - Properties

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        _blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _blurredImageView.image = [self.delegate accountViewControllerBlurredImageForDash];
    }
    return _blurredImageView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            floorf((kHeaderHeight - _closeButton.frame.size.height) / 2.0) + 7.0,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

#pragma mark - Private methods

- (void)closeTapped:(id)sender {
    [self.delegate accountViewControllerDismissRequested];
}

@end
