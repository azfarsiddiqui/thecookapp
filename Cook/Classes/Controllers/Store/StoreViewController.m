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
#import "SearchStoreCollectionViewController.h"
#import "StoreBookCoverViewCell.h"
#import "EventHelper.h"
#import "StoreTabView.h"
#import "ImageHelper.h"
#import "NSString+Utilities.h"
#import "CKSearchFieldView.h"
#import "ViewHelper.h"

@interface StoreViewController () <StoreTabViewDelegate, StoreCollectionViewControllerDelegate,
    CKSearchFieldViewDelegate>

@property (nonatomic, strong) UIImageView *bottomShadowView;

@property (nonatomic, strong) FeaturedStoreCollectionViewController *featuredViewController;
@property (nonatomic, strong) FriendsStoreCollectionViewController *friendsViewController;
@property (nonatomic, strong) StoreCollectionViewController *currentStoreCollectionViewController;
@property (nonatomic, strong) StoreTabView *storeTabView;
@property (nonatomic, strong) NSMutableArray *storeCollectionViewControllers;

// Search
@property (nonatomic, strong) CKSearchFieldView *searchFieldView;
@property (nonatomic, strong) SearchStoreCollectionViewController *searchViewController;
@property (nonatomic, strong) UIButton *searchBackButton;
@property (nonatomic, assign) BOOL searchMode;

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
    [self initSearch];
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
    [self selectedStoreCollectionViewController:self.searchViewController];
}

#pragma mark - StoreCollectionViewControllerDelegate methods

- (void)storeCollectionViewControllerPanRequested:(BOOL)enabled {
    [self.delegate panEnabledRequested:enabled];
}

#pragma mark - CKSearchFieldViewDelegate methods

- (BOOL)searchFieldShouldFocus {
    return self.searchMode;
}

- (void)searchFieldViewSearchIconTapped {
    [self enableSearchMode:!self.searchMode];
}

- (void)searchFieldViewSearchByText:(NSString *)text {
    [self.searchViewController searchByKeyword:text];
}

- (void)searchFieldViewClearRequested {
    [self.searchViewController unloadData];
}

#pragma mark - Properties

- (CKSearchFieldView *)searchFieldView {
    if (!_searchFieldView) {
        _searchFieldView = [[CKSearchFieldView alloc] initWithWidth:390.0 delegate:self];
    }
    return _searchFieldView;
}

- (UIButton *)searchBackButton {
    if (!_searchBackButton) {
        _searchBackButton = [ViewHelper backButtonLight:NO target:self selector:@selector(searchCloseTapped)];
    }
    return _searchBackButton;
}

#pragma mark - Private methods

- (void)initBackground {
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_dash_shelves" type:@"png"]];
    UIImageView *bottomShadowView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_dash_shelves_shadow" type:@"png"]];
    
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
    bottomShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    bottomShadowView.frame = (CGRect){
        self.view.bounds.origin.x,
        self.view.bounds.origin.y + backgroundView.frame.size.height,
        self.view.bounds.size.width,
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
    SearchStoreCollectionViewController *searchViewController = [[SearchStoreCollectionViewController alloc] initWithDelegate:self];
    searchViewController.view.frame = featuredViewController.view.frame;
    searchViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    searchViewController.view.hidden = YES;
    [self.view addSubview:searchViewController.view];
    self.searchViewController = searchViewController;
    [self.storeCollectionViewControllers addObject:searchViewController];
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

- (void)initSearch {
    
    self.searchBackButton.alpha = 0.0;
    self.searchBackButton.frame = (CGRect){
        20.0,
        self.storeTabView.frame.origin.y + floorf((self.storeTabView.frame.size.height - self.searchBackButton.frame.size.height) / 2.0),
        self.searchBackButton.frame.size.width,
        self.searchBackButton.frame.size.height
    };
    [self.view addSubview:self.searchBackButton];
    
    self.searchFieldView.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.searchFieldView.frame.size.width) / 2.0),
        self.storeTabView.frame.origin.y + floorf((self.storeTabView.frame.size.height - self.searchFieldView.frame.size.height) / 2.0),
        self.searchFieldView.frame.size.width,
        self.searchFieldView.frame.size.height
    };
    self.searchFieldView.backgroundView.alpha = 0.0;
    [self.view addSubview:self.searchFieldView];
    
    self.searchFieldView.transform = CGAffineTransformMakeTranslation([self searchStartOffset], 0.0);
    self.searchBackButton.transform = CGAffineTransformMakeTranslation(20.0, 0.0);
}

- (void)selectedStoreCollectionViewController:(StoreCollectionViewController *)storeCollectionViewController {
    
    // Fade out the current VC.
    if (self.currentStoreCollectionViewController) {
        
        if (self.currentStoreCollectionViewController == storeCollectionViewController) {
            
            // Just show again.
            [storeCollectionViewController unloadDataCompletion:^{
                [storeCollectionViewController loadData];
            }];
            
        } else {
            
            // Fade between controllers.
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
        }
        
    } else {
        [self showStoreCollectionViewController:storeCollectionViewController];
    }
}

- (void)showStoreCollectionViewController:(StoreCollectionViewController *)storeCollectionViewController {
    self.currentStoreCollectionViewController = storeCollectionViewController;
    
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
                     }];
}

- (void)enableSearchMode:(BOOL)searchMode {
    if (searchMode) {
        self.searchViewController.view.alpha = 0.0;
        self.searchViewController.view.hidden = NO;
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.storeTabView.alpha = searchMode ? 0.0 : 1.0;
                         self.searchFieldView.backgroundView.alpha = searchMode ? 1.0 : 0.0;
                         self.searchFieldView.transform = searchMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation([self searchStartOffset], 0.0);
                         self.searchBackButton.alpha = searchMode ? 1.0 : 0.0;
                         self.searchBackButton.transform = searchMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(20.0, 0.0);
                         self.currentStoreCollectionViewController.view.alpha = searchMode ? 0.0 : 1.0;
                         self.searchViewController.view.alpha = searchMode ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         self.searchMode = searchMode;
                         [self.searchFieldView focus:searchMode];
                         
                         if (!searchMode) {
                             self.searchViewController.view.hidden = YES;
                         }
                         
                     }];
}

- (CGFloat)searchStartOffset {
    return self.view.bounds.size.width - self.searchFieldView.frame.origin.x - 90.0;
}

- (void)searchCloseTapped {
    [self enableSearchMode:NO];
}

@end
