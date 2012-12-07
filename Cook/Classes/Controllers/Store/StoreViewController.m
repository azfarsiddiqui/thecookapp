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

@interface StoreViewController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) FeaturedStoreCollectionViewController *featuredViewController;
@property (nonatomic, strong) FriendsStoreCollectionViewController *friendsViewController;
@property (nonatomic, strong) UIImageView *featuredBanner;
@property (nonatomic, strong) UIImageView *friendsBanner;

@end

@implementation StoreViewController

#define kInsets     UIEdgeInsetsMake(100.0, 0.0, 100.0, 0.0)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBackground];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
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
}

- (void)enable:(BOOL)enable {
    [self.featuredViewController enable:enable];
    [self.friendsViewController enable:enable];
    [self showBanners:enable animated:enable ? YES : NO];
}

#pragma mark - Private methods

- (void)initBackground {
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_shelves.png"]];
    self.view.frame = CGRectMake(self.view.frame.origin.x,
                                 self.view.frame.origin.y,
                                 backgroundView.frame.size.width,
                                 backgroundView.frame.size.height);
    [self.view addSubview:backgroundView];
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

@end
