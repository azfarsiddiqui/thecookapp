//
//  StoreViewController.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreViewController.h"
#import "FriendsStoreCollectionViewController.h"
#import "FeaturedStoreCollectionViewController.h"
#import "StoreBookCoverViewCell.h"
#import "CKLoginView.h"
#import "EventHelper.h"

@interface StoreViewController () <CKLoginViewDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) FeaturedStoreCollectionViewController *featuredViewController;
@property (nonatomic, strong) FriendsStoreCollectionViewController *friendsViewController;
@property (nonatomic, strong) UIImageView *featuredBanner;
@property (nonatomic, strong) UIImageView *friendsBanner;
@property (nonatomic, strong) UIView *loginOverlayView;
@property (nonatomic, strong) UIView *loginBannerView;
@property (nonatomic, strong) UIView *rightShadowView;
@property (nonatomic, strong) UIView *leftShadowView;
@property (nonatomic, strong) CKLoginView *loginButton;

@end

@implementation StoreViewController

#define kInsets                 UIEdgeInsetsMake(100.0, 0.0, 100.0, 0.0)
#define kStoreShadowOffset      31.0

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self initBackground];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGFloat rowHeight = [StoreBookCoverViewCell cellSize].height;
    
    FeaturedStoreCollectionViewController *featuredViewController = [[FeaturedStoreCollectionViewController alloc] init];
    featuredViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                   self.view.bounds.size.height - rowHeight - 280.0,
                                                   self.view.bounds.size.width,
                                                   rowHeight);
    featuredViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:featuredViewController.view];
    self.featuredViewController = featuredViewController;
    [featuredViewController loadData];
    
    FriendsStoreCollectionViewController *friendsViewController = [[FriendsStoreCollectionViewController alloc] init];
    friendsViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                  self.view.bounds.size.height - rowHeight + 48.0,
                                                  self.view.bounds.size.width,
                                                  rowHeight);
    friendsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:friendsViewController.view];
    self.friendsViewController = friendsViewController;
    [friendsViewController loadData];
    
    [self initBanners];
    [self initLoginViewIfRequired];
}

- (void)enable:(BOOL)enable {
    [self.featuredViewController enable:enable];
    [self.friendsViewController enable:enable];
    [self showBanners:enable animated:enable];
}

#pragma mark - CKLoginViewDelegate

- (void)loginViewTapped {
    
    // Spin the facebook button.
    [self.loginButton loginStarted];
    
    // Dispatch login after one second.
    [self performSelector:@selector(performLogin) withObject:nil afterDelay:1.0];
}

#pragma mark - Private methods

- (void)initBackground {
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_shelves.png"]];
    self.view.frame = CGRectMake(self.view.frame.origin.x,
                                 self.view.frame.origin.y,
                                 backgroundView.frame.size.width,
                                 backgroundView.frame.size.height);
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    self.backgroundView = backgroundView;
}

- (void)initBanners {
    UIImageView *featuredBanner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_library_banner_featured.png"]];
    UIView *featuredContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                         self.view.bounds.size.height - 692.0,
                                                                         featuredBanner.frame.size.width,
                                                                         featuredBanner.frame.size.height)];
    featuredContainer.clipsToBounds = YES;
    [featuredContainer addSubview:featuredBanner];
    [self.view addSubview:featuredContainer];
    self.featuredBanner = featuredBanner;

    UIImageView *friendsBanner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_library_banner_friends.png"]];
    UIView *friendsContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                        self.view.bounds.size.height - 360.0,
                                                                        friendsBanner.frame.size.width,
                                                                        friendsBanner.frame.size.height)];
    friendsContainer.clipsToBounds = YES;
    [friendsContainer addSubview:friendsBanner];
    [self.view addSubview:friendsContainer];
    self.friendsBanner = friendsBanner;
    
    [self showBanners:NO animated:NO];
}

- (void)initLoginViewIfRequired {
    CKUser *currentUser = [CKUser currentUser];
    if (![currentUser isSignedIn]) {
        
        // Login overlay.
        UIImageView *loginOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_signin_banner_overlay.png"]];
        loginOverlayView.frame = CGRectMake(self.view.bounds.origin.x,
                                            self.view.bounds.size.height - loginOverlayView.frame.size.height - kStoreShadowOffset,
                                            loginOverlayView.frame.size.width,
                                            loginOverlayView.frame.size.height);
        loginOverlayView.userInteractionEnabled = YES;
        [self.view addSubview:loginOverlayView];
        self.loginOverlayView = loginOverlayView;
        
        // Banner.
        UIImageView *loginBannerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_signin_banner.png"]];
        loginBannerView.frame = CGRectMake(floorf((loginOverlayView.bounds.size.width - loginBannerView.frame.size.width) / 2.0),
                                           floorf((loginOverlayView.frame.size.height - loginBannerView.frame.size.height) / 2.0) + 70.0,
                                           loginBannerView.frame.size.width,
                                           loginBannerView.frame.size.height);
//        loginBannerView.alpha = 0.5;
        loginBannerView.userInteractionEnabled = YES;
        [loginOverlayView addSubview:loginBannerView];
        self.loginBannerView = loginBannerView;
        
        // Right/Left shadows.
        UIImageView *rightShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_signin_banner_right.png"]];
        rightShadowView.userInteractionEnabled = YES;
        [loginBannerView addSubview:rightShadowView];
        self.rightShadowView = rightShadowView;
        UIImageView *leftShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_library_signin_banner_left.png"]];
        leftShadowView.userInteractionEnabled = YES;
        [loginBannerView addSubview:leftShadowView];
        self.leftShadowView = leftShadowView;
        
        // Login button
        CKLoginView *loginButton = [[CKLoginView alloc] initWithDelegate:self];
        loginButton.frame = CGRectMake(560.0,
                                       150.0,
                                       loginButton.frame.size.width,
                                       loginButton.frame.size.height);
        [loginBannerView addSubview:loginButton];
        self.loginButton = loginButton;

    }
}

- (void)showBanners:(BOOL)show animated:(BOOL)animated {
    
    CGAffineTransform featuredTransform = CGAffineTransformMakeTranslation(0.0, -self.featuredBanner.frame.size.height);
    CGAffineTransform friendsTransform = CGAffineTransformMakeTranslation(0.0, -self.friendsBanner.frame.size.height);
    if (animated) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.featuredBanner.transform = show ? CGAffineTransformIdentity : featuredTransform;
                             self.friendsBanner.transform = show ? CGAffineTransformIdentity : friendsTransform;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.featuredBanner.transform = show ? CGAffineTransformIdentity : featuredTransform;
        self.friendsBanner.transform = show ? CGAffineTransformIdentity : friendsTransform;
    }
}

- (void)performLogin {
    
    // Now tries and log the user in.
    [CKUser loginWithFacebookCompletion:^{
        
        CKUser *user = [CKUser currentUser];
        if (user.admin) {
            [self.loginButton loginAdminDone];
        } else {
            [self.loginButton loginLoadingFriends:[user numFollows]];
        }
        
        [self informLoginSuccessful:YES];
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        // Reset the facebook button.
        [self.loginButton loginFailed];
        
        [self informLoginSuccessful:NO];
    }];
}

- (void)informLoginSuccessful:(BOOL)success {
    
    [self.loginOverlayView removeFromSuperview];
    
    // Inform login successful.
    [EventHelper postLoginSuccessful:success];
    
}

@end
