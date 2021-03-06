//
//  BookPageViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookPageViewController.h"
#import "ViewHelper.h"
#import "CardViewHelper.h"
#import "ShareViewController.h"

@interface BookPageViewController ()

@property (nonatomic, strong) UIImageView *leftShadowView;
@property (nonatomic, strong) UIImageView *rightShadowView;

@end

@implementation BookPageViewController

#define kContentInsets  (UIEdgeInsets){ 35.0, 30.0, 0.0, 10.0 }

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Apply shadows after everything has been loaded in viewDidLoad.
    [self applyPageEdgeShadows];
}

- (void)addCloseButtonLight:(BOOL)white {
    [self.closeButton removeFromSuperview];
    self.closeButton = [ViewHelper closeButtonLight:white target:self selector:@selector(closeTapped:)];
    self.closeButton.frame = (CGRect){
        kContentInsets.left,
        kContentInsets.top,
        self.closeButton.frame.size.width,
        self.closeButton.frame.size.height
    };
    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.closeButton];
}

- (void)addShareButtonLight:(BOOL)white {
    [self.shareButton removeFromSuperview];
    self.shareButton = [ViewHelper shareButtonLight:white target:self selector:@selector(shareTapped:)];
    self.shareButton.frame = (CGRect){
        self.view.bounds.size.width - kContentInsets.right - self.shareButton.frame.size.width - 20.0,
        kContentInsets.top,
        self.shareButton.frame.size.width,
        self.shareButton.frame.size.height
    };
    self.shareButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.shareButton];
}

- (void)applyPageEdgeShadows {
    [self.view addSubview:self.leftShadowView];
    [self.view addSubview:self.rightShadowView];
}

- (void)enableEditMode:(BOOL)editMode {
    [self enableEditMode:editMode completion:nil];
}

- (void)enableEditMode:(BOOL)editMode completion:(void (^)())completion {
    [self enableEditMode:editMode animated:YES completion:completion];
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated completion:(void (^)())completion {
    self.editMode = editMode;
}

- (UIEdgeInsets)pageContentInsets {
    return kContentInsets;
}

- (void)showIntroCard:(BOOL)show {
    // Subclasses to implement.
}

#pragma mark - CKSaveableContent methods

- (BOOL)contentSaveRequired {
    return NO;
}

- (void)contentPerformSave:(BOOL)save {
    // Subclasses to implement.
}

#pragma mark - Properties

- (UIImageView *)leftShadowView {
    if (!_leftShadowView) {
        _leftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_pageshadow_left.png"]];
        _leftShadowView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
        _leftShadowView.frame = (CGRect) {
            self.view.bounds.origin.x - _leftShadowView.frame.size.width,
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
            self.view.bounds.size.width,
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

- (void)shareTapped:(id)sender {
    [self showShareOverlay:YES];
}

- (void)showShareOverlay:(BOOL)show {
}

@end
