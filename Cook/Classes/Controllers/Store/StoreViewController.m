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
                                                   self.view.bounds.origin.y,
                                                   self.view.bounds.size.width,
                                                   rowHeight + 93.0);
    featuredViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:featuredViewController.view];
    self.featuredViewController = featuredViewController;
    [featuredViewController loadData];
    
    FriendsStoreCollectionViewController *friendsViewController = [[FriendsStoreCollectionViewController alloc] init];
    friendsViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                  self.view.bounds.size.height - rowHeight + 45.0,
                                                  self.view.bounds.size.width,
                                                  rowHeight);
    friendsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:friendsViewController.view];
    self.friendsViewController = friendsViewController;
    [friendsViewController loadData];
    
}

- (void)enable:(BOOL)enable {
    [self.featuredViewController enable:enable];
    [self.friendsViewController enable:enable];
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

@end
