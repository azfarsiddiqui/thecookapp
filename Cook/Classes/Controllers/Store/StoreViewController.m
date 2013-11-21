//
//  StoreViewController.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreViewController.h"
#import "FriendsStoreCollectionViewController.h"
#import "SuggestedStoreCollectionViewController.h"
#import "CategoriesStoreCollectionViewController.h"
#import "FeaturedStoreCollectionViewController.h"
#import "WorldStoreCollectionViewController.h"
#import "SearchStoreCollectionViewController.h"
#import "StoreBookCoverViewCell.h"
#import "EventHelper.h"
#import "StoreTabView.h"
#import "ImageHelper.h"
#import "NSString+Utilities.h"
#import "CKSearchFieldView.h"
#import "ViewHelper.h"
#import "StoreUnitTabView.h"

@interface StoreViewController () <StoreTabViewDelegate, StoreCollectionViewControllerDelegate,
    CKSearchFieldViewDelegate>

@property (nonatomic, strong) UIImageView *bottomShadowView;

// Store
@property (nonatomic, strong) CategoriesStoreCollectionViewController *categoriesViewController;
@property (nonatomic, strong) FeaturedStoreCollectionViewController *featuredViewController;
@property (nonatomic, strong) WorldStoreCollectionViewController *worldViewController;
@property (nonatomic, strong) StoreCollectionViewController *currentStoreCollectionViewController;
@property (nonatomic, strong) StoreTabView *storeTabView;
@property (nonatomic, strong) NSMutableArray *storeCollectionViewControllers;

// Keep states.
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) NSUInteger selectedStoreTabIndex;
@property (nonatomic, assign) NSUInteger selectedFriendsTabIndex;

// Search
@property (nonatomic, strong) CKSearchFieldView *searchFieldView;
@property (nonatomic, strong) SearchStoreCollectionViewController *searchViewController;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) BOOL searchMode;

// Friends
@property (nonatomic, strong) FriendsStoreCollectionViewController *friendsViewController;
@property (nonatomic, strong) SuggestedStoreCollectionViewController *suggestedViewController;
@property (nonatomic, strong) UIButton *friendsButton;
@property (nonatomic, strong) StoreTabView *friendsTabView;
@property (nonatomic, assign) BOOL friendsMode;

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
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
    [EventHelper unregisterFollowUpdated:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                                  object:[UIApplication sharedApplication]];
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
    [self initFriends];
    
    [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
    
    // Register for notification that app did enter background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)enable:(BOOL)enable {
    if (enable && !self.currentStoreCollectionViewController) {
        
         // Featured
        [self.storeTabView selectTabAtIndex:1];
        
    }
    self.enabled = enable;
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

- (void)storeTabView:(StoreTabView *)storeTabView selectedTabAtIndex:(NSInteger)tabIndex {
    
    if (storeTabView == self.storeTabView) {
        
        // Remember the store tab index so we can return to it via Friends.
        self.selectedStoreTabIndex = tabIndex;
        
        switch (tabIndex) {
            case 0:
                [self selectedStoreCollectionViewController:self.categoriesViewController];
                break;
            case 1:
                [self selectedStoreCollectionViewController:self.featuredViewController];
                break;
            case 2:
                [self selectedStoreCollectionViewController:self.worldViewController];
                break;
            default:
                break;
        }
    } else if (storeTabView == self.friendsTabView) {
        
        // Remember the friends tab index so we can return to it via Friends.
        self.selectedFriendsTabIndex = tabIndex;
        
        switch (tabIndex) {
            case 0:
                [self selectedStoreCollectionViewController:self.friendsViewController];
                break;
            case 1:
                [self selectedStoreCollectionViewController:self.suggestedViewController];
                break;
            default:
                break;
        }
    }
    
}

#pragma mark - StoreCollectionViewControllerDelegate methods

- (void)storeCollectionViewControllerPanRequested:(BOOL)enabled {
    if (!enabled) {
        [self.searchFieldView resignFirstResponder];
    }
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

- (CategoriesStoreCollectionViewController *)categoriesViewController {
    if (!_categoriesViewController) {
        _categoriesViewController = [[CategoriesStoreCollectionViewController alloc] initWithDelegate:self];
    }
    return _categoriesViewController;
}

- (FeaturedStoreCollectionViewController *)featuredViewController {
    if (!_featuredViewController) {
        _featuredViewController = [[FeaturedStoreCollectionViewController alloc] initWithDelegate:self];
    }
    return _featuredViewController;
}

- (WorldStoreCollectionViewController *)worldViewController {
    if (!_worldViewController) {
        _worldViewController = [[WorldStoreCollectionViewController alloc] initWithDelegate:self];
    }
    return _worldViewController;
}

- (SearchStoreCollectionViewController *)searchViewController {
    if (!_searchViewController) {
        _searchViewController = [[SearchStoreCollectionViewController alloc] initWithDelegate:self];
    }
    return _searchViewController;
}

- (FriendsStoreCollectionViewController *)friendsViewController {
    if (!_friendsViewController) {
        _friendsViewController = [[FriendsStoreCollectionViewController alloc] initWithDelegate:self];
    }
    return _friendsViewController;
}

- (SuggestedStoreCollectionViewController *)suggestedViewController {
    if (!_suggestedViewController) {
        _suggestedViewController = [[SuggestedStoreCollectionViewController alloc] initWithDelegate:self];
    }
    return _suggestedViewController;
}

- (CKSearchFieldView *)searchFieldView {
    if (!_searchFieldView) {
        _searchFieldView = [[CKSearchFieldView alloc] initWithWidth:390.0 delegate:self];
    }
    return _searchFieldView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [ViewHelper backButtonLight:NO target:self selector:@selector(backTapped)];
    }
    return _backButton;
}

- (UIButton *)friendsButton {
    if (!_friendsButton) {
        _friendsButton = [ViewHelper buttonWithImage:[self imageForFriendsButtonSelected:YES]
                                       selectedImage:[self imageForFriendsButtonSelected:YES]
                                              target:self selector:@selector(friendsTapped)];
    }
    return _friendsButton;
}

- (StoreTabView *)storeTabView {
    if (!_storeTabView) {
        NSArray *tabViews = @[
                              [[StoreUnitTabView alloc] initWithText:@"COLLECTIONS"
                                                                icon:[UIImage imageNamed:@"cook_library_icons_categories.png"]
                                                             offIcon:[UIImage imageNamed:@"cook_library_icons_categories_off.png"]],
                              [[StoreUnitTabView alloc] initWithText:@"FEATURED"
                                                                icon:[UIImage imageNamed:@"cook_library_icons_featured.png"]
                                                             offIcon:[UIImage imageNamed:@"cook_library_icons_featured_off.png"]],
                              [[StoreUnitTabView alloc] initWithText:@"WORLD"
                                                                icon:[UIImage imageNamed:@"cook_library_icons_world.png"]
                                                             offIcon:[UIImage imageNamed:@"cook_library_icons_world_off.png"]]
                              ];
        _storeTabView = [[StoreTabView alloc] initWithUnitTabViews:tabViews delegate:self];
    }
    return _storeTabView;
}

- (StoreTabView *)friendsTabView {
    if (!_friendsTabView) {
        NSArray *tabViews = @[
                              [[StoreUnitTabView alloc] initWithText:@"FRIENDS"
                                                                icon:[UIImage imageNamed:@"cook_library_icons_friends.png"]
                                                             offIcon:[UIImage imageNamed:@"cook_library_icons_friends_off.png"]],
                              [[StoreUnitTabView alloc] initWithText:@"SUGGESTIONS"
                                                                icon:[UIImage imageNamed:@"cook_library_icons_friends.png"]
                                                             offIcon:[UIImage imageNamed:@"cook_library_icons_friends_off.png"]],
                              ];
        _friendsTabView = [[StoreTabView alloc] initWithUnitTabViews:tabViews delegate:self];
    }
    return _friendsTabView;
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
    self.storeCollectionViewControllers = [NSMutableArray arrayWithCapacity:5];
    
    // Categories.
    self.categoriesViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                          self.view.bounds.size.height - kShelfTopOffsetFromBottom - [self bottomShadowHeight],
                                                          self.view.bounds.size.width,
                                                          rowHeight);
    self.categoriesViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.categoriesViewController.view.hidden = YES;
    [self.view addSubview:self.categoriesViewController.view];
    [self.storeCollectionViewControllers addObject:self.categoriesViewController];
    
    // Featured.
    self.featuredViewController.view.frame = self.categoriesViewController.view.frame;
    self.featuredViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.featuredViewController.view.hidden = YES;
    [self.view addSubview:self.featuredViewController.view];
    [self.storeCollectionViewControllers addObject:self.featuredViewController];
    
    // World.
    self.worldViewController.view.frame = self.categoriesViewController.view.frame;
    self.worldViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.worldViewController.view.hidden = YES;
    [self.view addSubview:self.worldViewController.view];
    [self.storeCollectionViewControllers addObject:self.worldViewController];
    
    // Friends.
    self.friendsViewController.view.frame = self.categoriesViewController.view.frame;
    self.friendsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.friendsViewController.view.hidden = YES;
    [self.view addSubview:self.friendsViewController.view];
    [self.storeCollectionViewControllers addObject:self.friendsViewController];
    
    // Suggested.
    self.suggestedViewController.view.frame = self.categoriesViewController.view.frame;
    self.suggestedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.suggestedViewController.view.hidden = YES;
    [self.view addSubview:self.suggestedViewController.view];
    [self.storeCollectionViewControllers addObject:self.suggestedViewController];
    
    // Search.
    self.searchViewController.view.frame = self.categoriesViewController.view.frame;
    self.searchViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.searchViewController.view.hidden = YES;
    [self.view addSubview:self.searchViewController.view];
    [self.storeCollectionViewControllers addObject:self.searchViewController];
}

- (void)initTabs {
    self.storeTabView.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.storeTabView.frame.size.width) / 2.0),
        kShelfTopOffset - self.storeTabView.frame.size.height,
        self.storeTabView.frame.size.width,
        self.storeTabView.frame.size.height
    };
    [self.view addSubview:self.storeTabView];
}

- (void)initFriends {
    
    // Friends button.
    self.friendsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.friendsButton.frame = (CGRect){
        self.view.bounds.size.width - self.friendsButton.frame.size.width - 25.0,
        self.storeTabView.frame.origin.y + floorf((self.storeTabView.frame.size.height - self.friendsButton.frame.size.height) / 2.0),
        self.friendsButton.frame.size.width,
        self.friendsButton.frame.size.height
    };
    [self.view insertSubview:self.friendsButton belowSubview:self.storeTabView];
    
    // Friends tab.
    self.friendsTabView.frame = (CGRect) {
        floorf((self.view.bounds.size.width - self.friendsTabView.frame.size.width) / 2.0),
        self.storeTabView.frame.origin.y,
        self.friendsTabView.frame.size.width,
        self.friendsTabView.frame.size.height
    };
    self.friendsTabView.alpha = 0.0;
    [self.view addSubview:self.friendsTabView];
}

- (void)initSearch {
    
    self.backButton.alpha = 0.0;
    self.backButton.frame = (CGRect){
        20.0,
        self.storeTabView.frame.origin.y + floorf((self.storeTabView.frame.size.height - self.backButton.frame.size.height) / 2.0),
        self.backButton.frame.size.width,
        self.backButton.frame.size.height
    };
    [self.view addSubview:self.backButton];
    
    self.searchFieldView.frame = (CGRect){
        floorf((self.view.bounds.size.width - self.searchFieldView.frame.size.width) / 2.0),
        self.storeTabView.frame.origin.y + floorf((self.storeTabView.frame.size.height - self.searchFieldView.frame.size.height) / 2.0),
        self.searchFieldView.frame.size.width,
        self.searchFieldView.frame.size.height
    };
    self.searchFieldView.backgroundView.alpha = 0.0;
    [self.view insertSubview:self.searchFieldView belowSubview:self.storeTabView];
    
    self.searchFieldView.transform = CGAffineTransformMakeTranslation([self searchStartOffset], 0.0);
    self.backButton.transform = CGAffineTransformMakeTranslation((self.view.bounds.size.width / 2.0), 0.0);
}

- (void)selectedStoreCollectionViewController:(StoreCollectionViewController *)storeCollectionViewController {
    
    if (self.animating) {
        return;
    }
    
    // Fade out the current VC.
    if (self.currentStoreCollectionViewController) {
        
        if (self.currentStoreCollectionViewController == storeCollectionViewController) {
            
            // Reload data for current tab if tapped again.
            if (!storeCollectionViewController.loading) {
                [storeCollectionViewController unloadDataCompletion:^{
                    [storeCollectionViewController loadData];
                }];
            }
            
        } else {
            
            // Unload existing data on the targeted tab.
            [storeCollectionViewController unloadData];
            
            // Fade between controllers.
            [UIView animateWithDuration:0.1
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.currentStoreCollectionViewController.view.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 
                                 // Hide the existing tab.
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
    
    if (self.searchMode) {
        return;
    }
    
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
                         [storeCollectionViewController loadBooks];
                         self.animating = NO;
                     }];
}

- (void)enableSearchMode:(BOOL)searchMode {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    if (searchMode) {
        [self.searchViewController unloadData];
        self.searchViewController.view.alpha = 0.0;
        self.searchViewController.view.hidden = NO;
        self.backButton.transform = CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0.0);
    } else {
        [self.searchFieldView focus:NO];
        [self.currentStoreCollectionViewController unloadData];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         // Store tabs.
                         self.storeTabView.alpha = searchMode ? 0.0 : 1.0;
                         self.storeTabView.transform = searchMode ? CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0) : CGAffineTransformIdentity;
                         
                         // Search field.
                         self.searchFieldView.backgroundView.alpha = searchMode ? 1.0 : 0.0;
                         self.searchFieldView.transform = searchMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation([self searchStartOffset], 0.0);
                         
                         // Back button.
                         self.backButton.alpha = searchMode ? 1.0 : 0.0;
                         self.backButton.transform = searchMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0.0);
                         
                         // Friends button.
                         self.friendsButton.alpha = searchMode ? 0.0 : 1.0;
                         self.friendsButton.transform = searchMode ? CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0) : CGAffineTransformIdentity;
                         
                         // VCs
                         self.currentStoreCollectionViewController.view.alpha = searchMode ? 0.0 : 1.0;
                         self.searchViewController.view.alpha = searchMode ? 1.0 : 0.0;
                         
                     }
                     completion:^(BOOL finished) {
                         self.searchMode = searchMode;
                         
                         if (searchMode) {
                             [self.searchFieldView focus:YES];
                             [self.searchViewController loadBooks];
                         } else {
                             self.searchViewController.view.hidden = YES;
                             [self.currentStoreCollectionViewController loadBooks];
                         }
                         
                         self.animating = NO;
                     }];
}

- (void)enableFriendsMode:(BOOL)friendsMode {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    if (friendsMode) {
        self.backButton.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
        self.friendsTabView.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
    }
    
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         // Store tabs.
                         self.storeTabView.alpha = friendsMode ? 0.0 : 1.0;
                         self.storeTabView.transform = friendsMode ? CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0.0) : CGAffineTransformIdentity;
                         
                         // Friends tab.
                         self.friendsTabView.alpha = friendsMode ? 1.0 : 0.0;
                         self.friendsTabView.transform = friendsMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
                         
                         // Search field.
                         self.searchFieldView.alpha = friendsMode ? 0.0 : 1.0;
                         self.searchFieldView.transform = friendsMode ? CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0.0) : CGAffineTransformMakeTranslation([self searchStartOffset], 0.0);
                         
                         // Friends button.
                         self.friendsButton.alpha = friendsMode ? 0.0 : 1.0;
                         self.friendsButton.transform = friendsMode ? CGAffineTransformMakeTranslation(-self.view.bounds.size.width, 0.0) : CGAffineTransformIdentity;
                         
                         // Back button.
                         self.backButton.alpha = friendsMode ? 1.0 : 0.0;
                         self.backButton.transform = friendsMode ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0.0);
                         
                         // Always force fade on current VC.
                         self.currentStoreCollectionViewController.view.alpha = 0.0;
                         
                     }
                     completion:^(BOOL finished) {
                         self.friendsMode = friendsMode;
                         
                         if (friendsMode) {
                             [self.friendsTabView selectTabAtIndex:self.selectedFriendsTabIndex];
                         } else {
                             [self.storeTabView selectTabAtIndex:self.selectedStoreTabIndex];
                         }
                         
                         self.animating = NO;
                     }];
}

- (CGFloat)searchStartOffset {
    return -315.0;
}

- (void)backTapped {
    if (self.searchMode) {
        [self enableSearchMode:NO];
    } else if (self.friendsMode) {
        [self enableFriendsMode:NO];
    }
}

- (void)friendsTapped {
    [self enableFriendsMode:!self.friendsMode];
}

- (void)loggedIn:(NSNotification *)notification {
    [self.storeCollectionViewControllers makeObjectsPerformSelector:@selector(isLoggedIn)];
}

- (void)loggedOut:(NSNotification *)notification {
    [self.storeCollectionViewControllers makeObjectsPerformSelector:@selector(isLoggedOut)];
    [self purgeData];
}

- (UIImage *)imageForFriendsButtonSelected:(BOOL)selected {
    return selected ? [UIImage imageNamed:@"cook_library_icons_friends_off.png"] : [UIImage imageNamed:@"cook_library_icons_friends.png"];
}

- (void)didEnterBackground {
    if (!self.enabled) {
        [self purgeData];
    }
}

- (void)purgeData {
    [self.storeCollectionViewControllers makeObjectsPerformSelector:@selector(purgeData)];
    if (self.searchMode) {
        [self enableSearchMode:NO];
    } else if (self.friendsMode) {
        [self enableFriendsMode:NO];
    }
    self.currentStoreCollectionViewController = nil;
}

- (void)unloadData {
    [self.storeCollectionViewControllers makeObjectsPerformSelector:@selector(unloadData)];
    [self.searchFieldView clearSearch];
    if (self.searchMode) {
        [self enableSearchMode:NO];
    }
    self.currentStoreCollectionViewController = nil;
}

@end
