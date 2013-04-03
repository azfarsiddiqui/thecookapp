//
//  BookProfileViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookProfileViewController.h"
#import "CKBook.h"
#import "CKUser.h"
#import "Theme.h"
#import "CKUserProfilePhotoView.h"
#import "CKBookSummaryView.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface BookProfileViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *introView;

@end

@implementation BookProfileViewController

#define kIntroOffset    CGPointMake(30.0, 30.0)
#define kIntroWidth     400.0
#define kProfileNameGap 20.0

- (id)initWithBook:(CKBook *)book {
    if (self = [super init]) {
        self.book = book;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [self initImageView];
    [self initIntroView];
}

#pragma mark - Private methods

- (void)initImageView {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

- (void)initIntroView {
    
    UIView *introView = [[UIView alloc] initWithFrame:CGRectMake(kIntroOffset.x,
                                                                 kIntroOffset.y,
                                                                 kIntroWidth,
                                                                 self.view.bounds.size.height - (kIntroOffset.y * 2.0))];
    introView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    introView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:introView];
    self.introView = introView;
    
    // Semi-transparent black overlay.
    UIView *introOverlay = [[UIView alloc] initWithFrame:introView.bounds];
    introOverlay.backgroundColor = [UIColor blackColor];
    introOverlay.alpha = 0.8;
    [introView addSubview:introOverlay];
    
    // Book summary view.
    CKBookSummaryView *bookSummaryView = [[CKBookSummaryView alloc] initWithBook:self.book];
    bookSummaryView.frame = CGRectMake(floorf((introView.bounds.size.width - bookSummaryView.frame.size.width) / 2.0),
                                       floorf((introView.bounds.size.height - bookSummaryView.frame.size.height) / 2.0),
                                       bookSummaryView.frame.size.width,
                                       bookSummaryView.frame.size.height);
    [introView addSubview:bookSummaryView];
}

@end
