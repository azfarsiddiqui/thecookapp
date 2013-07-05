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
#define kVisibleHeight              375.0
#define kShelfTopOffset             438.0
#define kShelfTopOffsetFromBottom   239.0
#define kShelfHeight                212.0
#define kShellBottomShelfTrayHeight 25.0

- (void)dealloc {
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    
    [self initBackground];
    
    [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initStores];
    [self initTabs];
}

- (void)enable:(BOOL)enable {
    DLog();
}

- (CGFloat)visibleHeight {
    return kVisibleHeight;
}

- (CGFloat)bottomShelfTrayHeight {
    return kShellBottomShelfTrayHeight;
}

- (CGFloat)bottomShadowHeight {
    return self.bottomShadowView.frame.size.height;
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
    
    FriendsStoreCollectionViewController *friendsViewController = [[FriendsStoreCollectionViewController alloc] initWithDelegate:self];
    friendsViewController.view.frame = featuredViewController.view.frame;
    friendsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    friendsViewController.view.hidden = YES;
    [self.view addSubview:friendsViewController.view];
    self.friendsViewController = friendsViewController;
    [self.storeCollectionViewControllers addObject:friendsViewController];
    
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

- (void)loggedIn:(NSNotification *)notification {
    [self.storeTabView selectFeatured];
}

- (void)loggedOut:(NSNotification *)notification {
    [self.currentStoreCollectionViewController unloadData];
}

- (void)selectedStoreCollectionViewController:(StoreCollectionViewController *)storeCollectionViewController {
    
    if (![CKUser isLoggedIn]) {
        return;
    }
    
    // Remember selected store tab.
    self.currentStoreCollectionViewController = storeCollectionViewController;
    
    // Unload existing data.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for (StoreCollectionViewController *viewController in self.storeCollectionViewControllers) {
                             if (viewController != storeCollectionViewController) {
                                 [viewController unloadData];
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                             for (StoreCollectionViewController *viewController in self.storeCollectionViewControllers) {
                                 if (viewController != storeCollectionViewController) {
                                     viewController.view.hidden = YES;
                                 }
                             }
                             storeCollectionViewController.view.hidden = NO;
                             [storeCollectionViewController loadData];
                         });
                         
                         
                     }];
}

@end
