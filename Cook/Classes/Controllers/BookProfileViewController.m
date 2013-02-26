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
#import <Parse/Parse.h>

@interface BookProfileViewController ()

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIView *introView;

@end

@implementation BookProfileViewController

#define kIntroOffset    CGPointMake(50.0, 100.0)
#define kIntroSize      CGSizeMake(400.0, 600.0)
#define kProfileSize    CGSizeMake(80.0, 80.0)
#define kProfileNameGap 20.0

- (id)initWithBook:(CKBook *)book {
    if (self = [super init]) {
        self.book = book;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initIntroView];
}

#pragma mark - Private methods

- (void)initIntroView {
    
    UIView *introView = [[UIView alloc] initWithFrame:CGRectMake(kIntroOffset.x,
                                                                 kIntroOffset.y,
                                                                 kIntroSize.width,
                                                                 kIntroSize.height)];
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
    PF_FBProfilePictureView *profileView = [[PF_FBProfilePictureView alloc] initWithFrame:CGRectMake(floorf((introView.bounds.size.width - kProfileSize.width) / 2.0),
                                                                                                     nameLabel.frame.origin.y - kProfileNameGap - kProfileSize.height,
                                                                                                     kProfileSize.width,
                                                                                                     kProfileSize.height)];
    profileView.profileID = self.book.user.facebookId;
    [introView addSubview:profileView];
}

@end
