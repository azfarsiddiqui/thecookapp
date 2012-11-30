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

@property (nonatomic, strong) FeaturedStoreCollectionViewController *featuredViewController;
@property (nonatomic, strong) FriendsStoreCollectionViewController *friendsViewController;

@end

@implementation StoreViewController

#define kInsets     UIEdgeInsetsMake(100.0, 0.0, 100.0, 0.0)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGFloat rowHeight = [StoreBookCoverViewCell cellSize].height;
    
    FeaturedStoreCollectionViewController *featuredViewController = [[FeaturedStoreCollectionViewController alloc] init];
//    featuredViewController.view.frame = CGRectMake(kInsets.left, kInsets.top, self.view.bounds.size.width, rowHeight);
    featuredViewController.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, rowHeight);
    featuredViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:featuredViewController.view];
    self.featuredViewController = featuredViewController;
    [featuredViewController loadData];
    
    FriendsStoreCollectionViewController *friendsViewController = [[FriendsStoreCollectionViewController alloc] init];
//    friendsViewController.view.frame = CGRectMake(kInsets.left, self.view.bounds.size.height - rowHeight - kInsets.bottom, self.view.bounds.size.width, rowHeight);
    friendsViewController.view.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - rowHeight, self.view.bounds.size.width, rowHeight);
    friendsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:friendsViewController.view];
    self.friendsViewController = friendsViewController;
    [friendsViewController loadData];
    
}

- (void)enable:(BOOL)enable {
    [self.featuredViewController enable:enable];
    [self.friendsViewController enable:enable];
}

@end
