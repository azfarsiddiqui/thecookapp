//
//  ProfileViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ProfileViewController.h"
#import "CKUser.h"
#import "ModalOverlayHelper.h"
#import "EventHelper.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "CKActivityIndicatorView.h"

@interface ProfileViewController ()

@property (nonatomic, strong) CKUser *user;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CKNavigationController *cookNavigationController;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;

@end

@implementation ProfileViewController

- (void)dealloc {
    [EventHelper unregisterPhotoLoading:self];
}

- (id)initWithUser:(CKUser *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    [self initBackground];
    
    self.backButton = [ViewHelper addBackButtonToView:self.view light:NO target:self selector:@selector(backTapped:)];
    if (self.cookNavigationController) {
        self.backButton.alpha = 0.0;
    }
}

#pragma mark - CKNavigationControllerSupport methods

- (void)cookNavigationControllerViewWillAppear:(NSNumber *)boolNumber {
    if (![boolNumber boolValue]) {
        [self.activityView stopAnimating];
    }
}

- (void)cookNavigationControllerViewAppearing:(NSNumber *)boolNumber {
    self.backButton.alpha = [boolNumber boolValue] ? 1.0 : 0.0;
}

- (void)cookNavigationControllerViewDidAppear:(NSNumber *)boolNumber {
    if ([boolNumber boolValue]) {
        [self loadData];
    }
}

#pragma mark - Properties

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        _activityView.center = self.view.center;
        _activityView.hidesWhenStopped = YES;
    }
    return _activityView;
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Background container view.
    UIView *backgroundContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundContainerView];
    
    // Background imageView.
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = (CGRect) {
        backgroundContainerView.bounds.origin.x - motionOffset.horizontal,
        backgroundContainerView.bounds.origin.y - motionOffset.vertical,
        backgroundContainerView.bounds.size.width + (motionOffset.horizontal * 2.0),
        backgroundContainerView.bounds.size.height + (motionOffset.vertical * 2.0)
    };
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [backgroundContainerView addSubview:imageView];
    imageView.alpha = 0.0;
    self.imageView = imageView;
    
    // Motion effects.
    [ViewHelper applyDraggyMotionEffectsToView:self.imageView];
}

- (void)loadData {
    [self.activityView startAnimating];
    [self.view addSubview:self.activityView];
    
    // Register photo loading events.
    [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
}

- (void)backTapped:(id)sender {
    [self.cookNavigationController popViewControllerAnimated:YES];
}

@end
