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
    
    // Name
    NSString *name = [[self.book userName] uppercaseString];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.font = [Theme bookProfileNameFont];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.shadowColor = [UIColor blackColor];
    nameLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    nameLabel.text = name;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [nameLabel sizeToFit];
    nameLabel.frame = CGRectMake(floorf((introView.bounds.size.width - nameLabel.frame.size.width) / 2.0),
                                 floorf((introView.bounds.size.height - nameLabel.frame.size.height) / 2.0),
                                 nameLabel.frame.size.width,
                                 nameLabel.frame.size.height);
    [introView addSubview:nameLabel];
    
    // Profile photo
    CKUserProfilePhotoView *profileView = [[CKUserProfilePhotoView alloc] initWithUser:self.book.user profileSize:ProfileViewSizeLarge];
    profileView.frame = CGRectMake(floorf((introView.bounds.size.width - profileView.frame.size.width) / 2.0),
                                   nameLabel.frame.origin.y - kProfileNameGap - profileView.frame.size.height,
                                   profileView.frame.size.width,
                                   profileView.frame.size.height);
    [introView addSubview:profileView];
}

@end
