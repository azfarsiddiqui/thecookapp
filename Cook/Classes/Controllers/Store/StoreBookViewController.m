//
//  StoreBookViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreBookViewController.h"
#import "CKBook.h"
#import "CKBookCoverView.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "BenchtopBookCoverViewCell.h"

@interface StoreBookViewController () <CKBookCoverViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<StoreBookViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation StoreBookViewController

#define kBookViewContentInsets  UIEdgeInsetsMake(100.0, 100.0, 100.0, 100.0)

- (id)initWithBook:(CKBook *)book delegate:(id<StoreBookViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    [self initBackground];
    [self initBookView];
}

#pragma mark - CKBookCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Background imageView.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.alpha = 0.8;
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)initBookView {
    
    // Container view.
    UIView *bookContainerView = [[UIView alloc] initWithFrame:CGRectMake(kBookViewContentInsets.left,
                                                                         kBookViewContentInsets.top,
                                                                         self.view.bounds.size.width - kBookViewContentInsets.left - kBookViewContentInsets.right,
                                                                         self.view.bounds.size.height - kBookViewContentInsets.top - kBookViewContentInsets.bottom)];
    bookContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bookContainerView];
    
    // Black overlay.
    UIView *overlayView = [[UIView alloc] initWithFrame:bookContainerView.bounds];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.7;
    [bookContainerView addSubview:overlayView];
    
    // Close button.
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"btn_close.png"] target:self selector:@selector(closeTapped)];
    closeButton.frame = CGRectMake(15.0, 10.0, closeButton.frame.size.width, closeButton.frame.size.height);
    [bookContainerView addSubview:closeButton];
    
    // Book cover.
    CGSize size = [BenchtopBookCoverViewCell cellSize];
    CKBookCoverView *bookCoverView = [[CKBookCoverView alloc] initWithFrame:CGRectMake(50.0, 50.0, size.width, size.height) delegate:self];
    [bookCoverView setCover:self.book.cover illustration:self.book.illustration];
    [bookCoverView setTitle:self.book.name author:[self.book userName] caption:self.book.caption editable:[self.book editable]];
    [bookContainerView addSubview:bookCoverView];
}

- (void)closeTapped {
    [self.delegate storeBookViewControllerCloseRequested];
}

@end
