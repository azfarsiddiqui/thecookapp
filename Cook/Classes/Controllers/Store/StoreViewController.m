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
#import "SuggestedStoreCollectionViewController.h"
#import "StoreBookCoverViewCell.h"
#import "EventHelper.h"
#import "StoreTabView.h"

@interface StoreViewController () <StoreTabViewDelegate, StoreCollectionViewControllerDelegate>

@property (nonatomic, strong) UIImageView *bottomShadowView;

@property (nonatomic, strong) FeaturedStoreCollectionViewController *featuredViewController;
@property (nonatomic, strong) FriendsStoreCollectionViewController *friendsViewController;
@property (nonatomic, strong) SuggestedStoreCollectionViewController *suggestedViewController;
@property (nonatomic, strong) StoreCollectionViewController *currentStoreCollectionViewController;
@property (nonatomic, strong) StoreTabView *storeTabView;
@property (nonatomic, strong) NSMutableArray *storeCollectionViewControllers;

@end

@implementation StoreViewController

#define kInsets                     UIEdgeInsetsMake(100.0, 0.0, 100.0, 0.0)
#define kVisibleHeight              460.0   // Varies by taste
#define kShelfTopOffset             439.0
#define kShelfTopOffsetFromBottom   275.0
#define kShelfHeight                249.0
#define kShellBottomShelfTrayHeight 25.0
#define kShellBottomShadowHeight    48.0

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    
    [self initBackground];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initStores];
    [self initTabs];
}

- (void)enable:(BOOL)enable {
    if (enable && !self.currentStoreCollectionViewController) {
        [self.storeTabView selectFeatured];
    }
}

- (CGFloat)visibleHeight {
    return kVisibleHeight;
}

- (CGFloat)bottomShelfTrayHeight {
    return kShellBottomShelfTrayHeight;
}

- (CGFloat)bottomShadowHeight {
    return kShellBottomShadowHeight;
}

#pragma mark - StoreTabView methods

- (void)storeTabSelectedFeatured {
    [self selectedStoreCollectionViewController:self.featuredViewController];
}

- (void)storeTabSelectedFriends {
    [self selectedStoreCollectionViewController:self.friendsViewController];
}

- (void)storeTabSelectedSuggested {
    [self selectedStoreCollectionViewController:self.suggestedViewController];
}

#pragma mark - StoreCollectionViewControllerDelegate methods

- (void)storeCollectionViewControllerPanRequested:(BOOL)enabled {
    [self.delegate panEnabledRequested:enabled];
}

#pragma mark - Private methods

- (void)initBackground {
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_shelves.png"]];
    UIImageView *bottomShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_shelves_shadow.png"]];
    
    // Shelf + Bottom Shadow
    self.view.frame = (CGRect){
        self.view.frame.origin.x,
        self.view.frame.origin.y,
        backgroundView.frame.size.width,
        backgroundView.frame.size.height + bottomShadowView.frame.size.height
    };
    
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    
    // Bottom shadow.
    bottomShadowView.frame = (CGRect){
        self.view.bounds.origin.x,
        self.view.bounds.origin.y + backgroundView.frame.size.height,
        bottomShadowView.frame.size.width,
        bottomShadowView.frame.size.height
    };
    [self.view addSubview:bottomShadowView];
    [self.view sendSubviewToBack:bottomShadowView];
    self.bottomShadowView = bottomShadowView;
}

- (void)initStores {
    CGFloat rowHeight = kShelfHeight;
    self.storeCollectionViewControllers = [NSMutableArray arrayWithCapacity:3];
    
    // Featured.
    FeaturedStoreCollectionViewController *featuredViewController = [[FeaturedStoreCollectionViewController alloc] initWithDelegate:self];
    featuredViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                   self.view.bounds.size.height - kShelfTopOffsetFromBottom - [self bottomShadowHeight],
                                                   self.view.bounds.size.width,
                                                   rowHeight);
    featuredViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    featuredViewController.view.hidden = YES;
    [self.view addSubview:featuredViewController.view];
    self.featuredViewController = featuredViewController;
    [self.storeCollectionViewControllers addObject:featuredViewController];
    
    // Friends.
    FriendsStoreCollectionViewController *friendsViewController = [[FriendsStoreCollectionViewController alloc] initWithDelegate:self];
    friendsViewController.view.frame = featuredViewController.view.frame;
    friendsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    friendsViewController.view.hidden = YES;
    [self.view addSubview:friendsViewController.view];
    self.friendsViewController = friendsViewController;
    [self.storeCollectionViewControllers addObject:friendsViewController];
    
    // Suggested.
    SuggestedStoreCollectionViewController *suggestedViewController = [[SuggestedStoreCollectionViewController alloc] initWithDelegate:self];
    suggestedViewController.view.frame = featuredViewController.view.frame;
    suggestedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    suggestedViewController.view.hidden = YES;
    [self.view addSubview:suggestedViewController.view];
    self.suggestedViewController = suggestedViewController;
    [self.storeCollectionViewControllers addObject:suggestedViewController];
}

- (void)initTabs {
    StoreTabView *storeTabView = [[StoreTabView alloc] initWithDelegate:self];
    storeTabView.frame = CGRectMake(floorf((self.view.bounds.size.width - storeTabView.frame.size.width) / 2.0),
                                    kShelfTopOffset - storeTabView.frame.size.height,
                                    storeTabView.frame.size.width,
                                    storeTabView.frame.size.height);
    [self.view addSubview:storeTabView];
    self.storeTabView = storeTabView;
}

- (void)selectedStoreCollectionViewController:(StoreCollectionViewController *)storeCollectionViewController {
    
    if (![CKUser isLoggedIn]) {
        return;
    }
    
    // Fade out the current VC.
    if (self.currentStoreCollectionViewController) {
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.currentStoreCollectionViewController.view.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             
                             // Unload the existing data.
                             [self.currentStoreCollectionViewController unloadData];
                             self.currentStoreCollectionViewController.view.hidden = YES;
                             
                             // Show the selected one.
                             [self showStoreCollectionViewController:storeCollectionViewController];
                         }];
        
    } else {
        [self showStoreCollectionViewController:storeCollectionViewController];
    }
}

- (void)showStoreCollectionViewController:(StoreCollectionViewController *)storeCollectionViewController {
    
    // Prep the selected one to be faded in.
    storeCollectionViewController.view.alpha = 0.0;
    storeCollectionViewController.view.hidden = NO;
    
    // Fade in the selected one.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         storeCollectionViewController.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [storeCollectionViewController loadData];
                         self.currentStoreCollectionViewController = storeCollectionViewController;
                     }];
}

@end
