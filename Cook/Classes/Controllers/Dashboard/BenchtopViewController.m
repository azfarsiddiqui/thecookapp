//
//  CKBenchtopViewController.m
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 9/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopViewController.h"
#import "BenchtopStackLayout.h"
#import "BenchtopFlowLayout.h"
#import "BenchtopPartingFlowLayout.h"
#import "BenchtopBookCell.h"
#import "BenchtopLayout.h"
#import "CKUser.h"
#import "CKBook.h"
#import "LoginBookCell.h"
#import "EventHelper.h"
#import "MRCEnumerable.h"
#import "NSString+Utilities.h"
#import "SettingsViewController.h"
#import "BenchtopEditLayout.h"

@interface BenchtopViewController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) BOOL firstBenchtop;
@property (nonatomic, assign) BOOL snapActivated;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) CKBook *myBook;
@property (nonatomic, strong) NSArray *friendsBooks;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSIndexPath *openedIndexPath;
@property (nonatomic, strong) BookViewController *bookViewController;
@property (nonatomic, strong) CKBook *selectedBook;
@property (nonatomic, strong) MenuViewController *menuViewController;
@property (nonatomic, strong) UIPopoverController *settingsPopoverController;
@property (nonatomic, strong) IllustrationPickerViewController *illustrationViewController;
@property (nonatomic, strong) CoverPickerViewController *coverViewController;
@property (nonatomic, strong) UIView *editOverlayView;

@end

@implementation BenchtopViewController

#define kBookCellId                 @"BookCell"
#define kLoginCellId                @"LoginCell"
#define kLibraryHeaderId            @"LibraryHeaderCell"
#define kLibraryHeaderKind          @"LibraryHeader"
#define kBackgroundAvailOffset      50.0
#define kNumFriendsMaxStack         2

- (void)dealloc {
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterBenchtopFreeze:self];
    [EventHelper unregisterOpenBook:self];
    [EventHelper unregisterEditMode:self];
    
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset"];
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[BenchtopStackLayout alloc] initWithBenchtopDelegate:self]]) {
        DLog(@"Loading benchtop for user %@", [CKUser currentUser]);
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithCollectionViewLayout:layout]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBackground];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    self.collectionView.frame = CGRectMake(self.collectionView.frame.origin.x,
                                           self.collectionView.frame.origin.y,
                                           self.collectionView.frame.size.width,
                                           self.view.bounds.size.height);
    
    // Important so that if contentSize is smaller than viewport, that it still bounces.
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.firstBenchtop = YES;
    
    [self.collectionView registerClass:[BenchtopBookCell class] forCellWithReuseIdentifier:kBookCellId];
    [self.collectionView registerClass:[LoginBookCell class] forCellWithReuseIdentifier:kLoginCellId];
    [self.collectionView registerClass:[UICollectionReusableView class]
             forSupplementaryViewOfKind:kLibraryHeaderKind withReuseIdentifier:kLibraryHeaderId];
    
    // Register for events.
    [EventHelper registerBenchtopFreeze:self selector:@selector(benchtopFreezeRequested:)];
    [EventHelper registerLoginSucessful:self selector:@selector(loginSuccessful:)];
    [EventHelper registerOpenBook:self selector:@selector(bookOpened:)];
    [EventHelper registerEditMode:self selector:@selector(editEvent:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [self showMenu:YES];
}

- (void)enable:(BOOL)enable {
    if (enable && !self.overlayView) {
        self.overlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_overlay.png"]];
        self.overlayView.autoresizingMask = UIViewAutoresizingNone;
        self.overlayView.alpha = 0.0;
        [self.view insertSubview:self.overlayView aboveSubview:self.backgroundView];
    }
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.overlayView.alpha = enable ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                         if (!enable) {
                             [self.overlayView removeFromSuperview];
                             self.overlayView = nil;
                         }
                         self.enabled = enable;
                        
                         // [self.collectionView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
                         CKUser *currentUser = [CKUser currentUser];
                         NSUInteger numSections = 0;
                         if ([currentUser isSignedIn]) {
                             numSections =  self.friendsBooks ? 2 : 1;
                         } else {
                             numSections = 2;
                         }
                         [self.collectionView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numSections)]];
                         [self loadData];
                     }];
    
}

- (void)freeze:(BOOL)freeze {
    self.collectionView.userInteractionEnabled = !freeze;
}

#pragma mark - BenchtopDelegate methods

- (BOOL)onMyBenchtop {
    return self.firstBenchtop;
}

- (BOOL)benchtopMyBookLoaded {
    return (self.myBook != nil);
}

- (CGSize)benchtopItemSize {
    return [BenchtopBookCell cellSize];
}

- (CGFloat)benchtopSideGap {
    return 62.0;
}

- (CGFloat)benchtopBookMinScaleFactor {
    return 0.78;
}

- (CGFloat)benchtopItemOffset {
    if (self.firstBenchtop) {
        return 0.0;
    } else {
        return -600.0;
    }
}

- (NSIndexPath *)benchtopOpenedIndexPath {
    return self.openedIndexPath;
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCell *cell = (BenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return [cell enabled];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // No selection while in edit mode.
    if (self.editMode) {
        return;
    }
    
    // Remember the selected indexPath.
    self.selectedIndexPath = indexPath;
    
    if (!self.firstBenchtop && indexPath.section == 1 && [self stacked]) {
        
        // Unstack books if we are on friends benchtop and stacked.
        [self stackLayout:NO];
        
    } else {
        
        // Only open book if book was in the center.
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
        if (CGRectContainsPoint(attributes.frame, CGPointMake(self.collectionView.contentOffset.x + (self.collectionView.bounds.size.width / 2.0),
                                                              self.collectionView.center.y))) {
            
            // Grab the book to open.
            CKBook *bookToOpen = nil;
            if (self.firstBenchtop && indexPath.section == 0) {
                bookToOpen = self.myBook;
            } else if (!self.firstBenchtop && indexPath.section == 1) {
                bookToOpen = [self.friendsBooks objectAtIndex:indexPath.row];
            }
            
            // Open book.
            [self openBook:bookToOpen indexPath:indexPath];
            
        } else {
            [self.collectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                animated:YES];
        }
        
    }
    
}

#pragma mark - UICollectionViewDataSource methods

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                   withReuseIdentifier:kLibraryHeaderId
                                                                                          forIndexPath:indexPath];
    NSInteger imageTag = 239;
    UIImageView *libraryImageView = (UIImageView *)[headerView viewWithTag:imageTag];
    if (!libraryImageView) {
        libraryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_library.png"]];
        libraryImageView.tag = imageTag;
        libraryImageView.frame = CGRectMake(floorf((headerView.bounds.size.width - libraryImageView.frame.size.width) / 2.0),
                                            floorf((headerView.bounds.size.height - libraryImageView.frame.size.height) / 2.0),
                                            libraryImageView.frame.size.width,
                                            libraryImageView.frame.size.height);
        libraryImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        [headerView addSubview:libraryImageView];
    }
    return headerView;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    // Nothing to show if not enabled.
    if (!self.enabled) {
        return 0;
    }
    
    // Normal operations.
    CKUser *currentUser = [CKUser currentUser];
    if ([currentUser isSignedIn]) {
        return self.friendsBooks ? 2 : 1;
    } else {
        return 2;
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    // Nothing to show if not enabled.
    if (!self.enabled) {
        return 0;
    }
    
    NSInteger numItems = 0;
    if (section == 0) {
        numItems = 1;   // My Book
    } else {
        CKUser *currentUser = [CKUser currentUser];
        if ([currentUser isSignedIn]) {
            numItems = [self.friendsBooks count];
        } else {
            numItems = 2; // Login book and some fake book.
        }
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if ([indexPath section] == 0) {
        cell = [self myBookCellForIndexPath:indexPath];
    } else {
        cell = [self otherBookCellsForIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.isDragging) {
        CGRect visibleRect = CGRectMake(scrollView.contentOffset.x,
                                        scrollView.contentOffset.y,
                                        scrollView.bounds.size.width,
                                        scrollView.bounds.size.height);
        
        NSIndexPath *nextSnapIndexPath = [self nextSnapIndexPath];
        UICollectionViewCell *nextSnapCell = [self.collectionView cellForItemAtIndexPath:nextSnapIndexPath];
        
        // If the next book is completely visible.
        // if (nextSnapCell && CGRectContainsRect(visibleRect, nextSnapCell.frame)) {
        // If the next book is 0.75 visible.
        if (nextSnapCell &&
            CGRectIntersection(visibleRect, nextSnapCell.frame).size.width > ([BenchtopBookCell cellSize].width * 0.75)) {
            if (!self.snapActivated) {
                NSLog(@"Snap activated for item %d", nextSnapIndexPath.item);
            }
            self.snapActivated = YES;
        } else {
            if (self.snapActivated) {
                NSLog(@"Snap deactivated for item %d", nextSnapIndexPath.item);
            }
            self.snapActivated = NO;
        }
        
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    // If snap was activated, then do not perform any let-go-restore animation.
    if (self.snapActivated) {
        *targetContentOffset = self.collectionView.contentOffset;
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (self.snapActivated) {
        [self snapDashboard];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if (self.snapActivated) {
        [self resetScrollView];
    }
}

#pragma mark - BookViewControllerDelegate methods

- (void)bookViewControllerCloseRequested {
    DLog();
    
    [self.bookViewController.view removeFromSuperview];
    BenchtopBookCell *bookCell = (BenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [bookCell openBook:NO];
    
    BenchtopLayout *layoutToToggle = nil;
    if (self.firstBenchtop) {
        layoutToToggle = [[BenchtopStackLayout alloc] initWithBenchtopDelegate:self];
    } else {
        layoutToToggle = [[BenchtopFlowLayout alloc] initWithBenchtopDelegate:self];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             [self.collectionView setCollectionViewLayout:layoutToToggle animated:NO];
                         }
                         completion:^(BOOL finished) {
                             self.selectedBook = nil;
                             self.openedIndexPath = nil;
                             [self showMenu:YES];
                             self.collectionView.userInteractionEnabled = YES;
                         }];
    });

}

#pragma mark - EventHelper methods

- (void)benchtopFreezeRequested:(NSNotification *)notification {
    BOOL freeze = [EventHelper benchFreezeForNotification:notification];
    [self freeze:freeze];
}

- (void)loginSuccessful:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
        [self loadDataToggleOnCompletion:NO];
    } else {
        self.collectionView.userInteractionEnabled = YES;
    }
}

- (void)bookOpened:(NSNotification *)notification {
    BOOL opened = [EventHelper openBookForNotification:notification];
    DLog(@"opened: %@", [NSString CK_stringForBoolean:opened]);
    if (opened) {
        
        BookViewController *bookViewController = [[BookViewController alloc] initWithBook:self.selectedBook delegate:self];
        [self.view addSubview:bookViewController.view];
        self.bookViewController = bookViewController;
        
    } else {
    }
}

- (void)editEvent:(NSNotification *)notification {
    BOOL editMode = [EventHelper editModeForNotification:notification];
    
    // Only respond to edit events, as disabling is handled by the buttons.
    if (editMode) {
        [self enableEditMode:editMode];
    }
}

#pragma mark - KVO methods.

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"] || [keyPath isEqualToString:@"contentSize"]) {
        
        // Update background parallax scrolling.
        [self updateBackgroundScrolling];
        
    } else if ([keyPath isEqualToString:@"collectionView.contentSize"]) {
        
        // Update cover picker.
        self.coverViewController.view.frame = CGRectMake(floorf((self.view.bounds.size.width - self.coverViewController.collectionView.contentSize.width) / 2.0),
                                                         self.coverViewController.view.frame.origin.y,
                                                         self.coverViewController.collectionView.contentSize.width,
                                                         self.coverViewController.view.frame.size.height);
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - MenuViewControllerDelegate methods

- (void)menuViewControllerSettingsRequested {
    DLog();
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:settingsViewController];
    [popoverController presentPopoverFromRect:self.menuViewController.settingsButton.frame
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
    self.settingsPopoverController = popoverController;
}

- (void)menuViewControllerStoreRequested {
    DLog();
}

- (void)menuViewControllerCancelRequested {

    // Revert to previous illustration/cover.
    BenchtopBookCell *cell = (BenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.myBook.illustration = self.illustrationViewController.illustration;
    self.myBook.cover = self.coverViewController.cover;
    [cell loadBook:self.myBook mine:YES force:YES];
    
    // Reload the illustration cover.
    [self.illustrationViewController changeCover:self.coverViewController.cover];

    [self enableEditMode:NO];
}

- (void)menuViewControllerDoneRequested {
    [self.myBook saveEventually];
    [self enableEditMode:NO];
}

#pragma mark - IllustrationViewControllerDelegate methods

- (void)illustrationSelected:(NSString *)illustration {
    
    // Force reload my book with the selected illustration.
    BenchtopBookCell *cell = (BenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.myBook.illustration = illustration;
    [cell loadBook:self.myBook mine:YES force:YES];
}

#pragma mark - CoverPickerViewControllerDelegate methods

- (void)coverPickerSelected:(NSString *)cover {
    
    // Force reload my book with the selected illustration.
    BenchtopBookCell *cell = (BenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.myBook.cover = cover;
    [cell loadBook:self.myBook mine:YES force:YES];
    
    // Reload the illustration covers.
    [self.illustrationViewController changeCover:cover];
}

#pragma mark - Private

- (void)toggleLayout {
    BenchtopLayout *layout = (BenchtopLayout *)self.collectionView.collectionViewLayout;
    [self stackLayout:[layout isKindOfClass:[BenchtopFlowLayout class]]];
}

- (void)stackLayout:(BOOL)stack {
    BenchtopLayout *layout = (BenchtopLayout *)self.collectionView.collectionViewLayout;
    
    // Return immediately if we are already on the required layout.
    if ((stack && [layout isKindOfClass:[BenchtopStackLayout class]])
        || (!stack && [layout isKindOfClass:[BenchtopFlowLayout class]])) {
        return;
    }
    
    BenchtopLayout *layoutToToggle = nil;
    if (stack) {
        layoutToToggle = [[BenchtopStackLayout alloc] initWithBenchtopDelegate:self];
    } else {
        layoutToToggle = [[BenchtopFlowLayout alloc] initWithBenchtopDelegate:self];
    }
    
    [UIView animateWithDuration:stack ? 0.6 : 0.4
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         [self.collectionView setCollectionViewLayout:layoutToToggle animated:NO];
                     }
                     completion:^(BOOL finished) {
                         self.collectionView.userInteractionEnabled = YES;
                     }];
}

- (NSIndexPath *)nextSnapIndexPath {
    NSIndexPath *nextSnapIndexPath = nil;
    if (self.firstBenchtop) {
        nextSnapIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    } else {
        nextSnapIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return nextSnapIndexPath;
}

- (void)snapDashboard {
    CGSize itemSize = [self benchtopItemSize];
    
    // Center on the next snap book.
    CGFloat requiredOffset = floorf((self.view.bounds.size.width - (itemSize.width * 3)) / 2.0) - floorf((self.view.bounds.size.width - itemSize.width) / 2.0);
    if (self.firstBenchtop) {
        NSUInteger bookSlotIndex = 3;
        requiredOffset += (itemSize.width * bookSlotIndex - 1);
    } else {
        requiredOffset -= itemSize.width;
    }
    
    CGPoint scrollToPoint = CGPointMake(requiredOffset, self.collectionView.contentOffset.y);
    
    // Works
    [self.collectionView setContentOffset:scrollToPoint animated:YES];
}

- (void)resetScrollView {
    
    // Invalidate layout so that it can reposition books.
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
    
    if (self.snapActivated) {
        self.snapActivated = NO;
        self.firstBenchtop = !self.firstBenchtop;
    }
    
    // Toggle the layout on snap back to the first benchtop.
    if (self.firstBenchtop && ![self stacked]) {
        [self performSelector:@selector(toggleLayout) withObject:nil afterDelay:0.0];
    }
    
}

- (void)initBackground {
    
    // Tiled background
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                      self.view.bounds.origin.y,
                                                                      self.view.bounds.size.width + kBackgroundAvailOffset,
                                                                      self.view.bounds.size.height)];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cook_dash_bg_tile.png"]];
    [self.view insertSubview:backgroundView belowSubview:self.collectionView];
    self.backgroundView = backgroundView;
    
    // Observe changes in contentSize and contentOffset.
    [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)updateBackgroundScrolling {
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGSize contentSize = self.collectionView.contentSize;
    CGRect backgroundFrame = self.backgroundView.frame;
    
    // kBackgroundAvailOffset 100 => -59.0
    // kBackgroundAvailOffset 50  => -30.0
    CGFloat backgroundOffset = self.firstBenchtop? 0.0 :-30;
    
    // Update backgroundWidth.
    backgroundFrame.size.width = contentSize.width + kBackgroundAvailOffset;
    
    // Update background parallax effect.
    if (self.firstBenchtop && contentOffset.x >= 0.0) {
        backgroundFrame.origin.x = floorf(-contentOffset.x * (kBackgroundAvailOffset / self.collectionView.bounds.size.width) + backgroundOffset);
    } else if (!self.firstBenchtop && contentOffset.x <= contentSize.width - self.collectionView.bounds.size.width) {
        backgroundFrame.origin.x = floorf(-contentOffset.x * (kBackgroundAvailOffset / self.collectionView.bounds.size.width) + backgroundOffset);
    }
    self.backgroundView.frame = backgroundFrame;
}

- (void)loadData {
    [self loadDataToggleOnCompletion:NO];
}

- (void)loadDataToggleOnCompletion:(BOOL)toggle {
    
    // Load my book.
    [self loadMyBook];
    
    // If signed in, start loading friends books.
    if ([[CKUser currentUser] isSignedIn]) {
        [self loadFriendsBooksToggleOnCompletion:toggle];
    }
}


- (void)loadMyBook {
    DLog(@"CURRENT USER: %@", [CKUser currentUser]);
    
    // This will be called twice - once from cache if exists, then from network.
    [CKBook bookForUser:[CKUser currentUser]
                success:^(CKBook *book) {
                    [self updateMyBook:book];
                }
                failure:^(NSError *error) {
                    DLog(@"Error: %@", [error localizedDescription]);
                }];
}

- (void)loadFriendsBooks {
    [self loadFriendsBooksToggleOnCompletion:NO];
}

- (void)loadFriendsBooksToggleOnCompletion:(BOOL)toggle {
    
    // Load friends books - this also does auto-follow in the background.
    [CKBook friendsBooksForUser:[CKUser currentUser]
                        success:^(NSArray *friendsBooks) {
                            self.friendsBooks = friendsBooks;
                            self.collectionView.userInteractionEnabled = YES;
                            
                            NSUInteger numSections = [self.collectionView numberOfSections];
                            if (numSections < 2) {
                                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:1]];
                            } else {
                                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
                            }
                            
                        }
                        failure:^(NSError *error) {
                            DLog(@"Error: %@", [error localizedDescription]);
                        }];
    
}

- (UICollectionViewCell *)myBookCellForIndexPath:(NSIndexPath *)indexPath {
    DLog();
    BenchtopBookCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kBookCellId
                                                                              forIndexPath:indexPath];
    if (self.myBook) {
        [cell loadBook:self.myBook mine:YES];
    } else {
        [cell loadBook:[CKBook myInitialBook] mine:YES];
    }
    return cell;
}

- (UICollectionViewCell *)otherBookCellsForIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCell *cell = nil;
    CKUser *user = [CKUser currentUser];
    if ([user isSignedIn]) {
        
        if (user.admin) {
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kBookCellId forIndexPath:indexPath];
        } else {
            
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kBookCellId forIndexPath:indexPath];
            if (self.friendsBooks) {
                CKBook *friendBook = [self.friendsBooks objectAtIndex:indexPath.row];
                [cell loadBook:friendBook];
            }
        }
        
    } else {
        if (indexPath.row == 0) {
            
            // Login book.
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kLoginCellId forIndexPath:indexPath];
            
        } else {
            
            // Fake books at the back.
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kBookCellId forIndexPath:indexPath];
            [cell loadBook:[CKBook defaultBook]];
            [cell loadAsPlaceholder];
        }
    }
    return cell;
}

- (void)updateMyBook:(CKBook *)book {
    self.myBook = book;
    BenchtopBookCell *cell = (BenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:
                                                      [NSIndexPath indexPathForItem:0 inSection:0]];
    [cell loadBook:book mine:YES];
}

- (BOOL)stacked {
    BenchtopLayout *layout = (BenchtopLayout *)self.collectionView.collectionViewLayout;
    return [layout isKindOfClass:[BenchtopStackLayout class]];
}

- (void)openBook:(CKBook *)book indexPath:(NSIndexPath *)indexPath {
    if (!book) {
        return;
    }
    
    // Get the book cell.
    BenchtopBookCell *bookCell = (BenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    // Remmeber the book to be opened.
    self.selectedBook = book;
    self.openedIndexPath = indexPath;
    
    // Hide the menu.
    [self showMenu:NO];
    
    // Open book.
    [bookCell openBook:YES];
    
    // Only part the books if we are in other books.
    BenchtopLayout *layoutToToggle = nil;
    if (indexPath.section == 0) {
        layoutToToggle = [[BenchtopStackLayout alloc] initWithBenchtopDelegate:self];
    } else {
        layoutToToggle = [[BenchtopPartingFlowLayout alloc] initWithBenchtopDelegate:self];
    }
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.collectionView setCollectionViewLayout:layoutToToggle animated:NO];
                     }
                     completion:^(BOOL finished) {
                         self.collectionView.userInteractionEnabled = NO;
                     }];
}

- (void)showMenu:(BOOL)show {
    if (!self.menuViewController) {
        self.menuViewController = [[MenuViewController alloc] initWithDelegate:self];
        self.menuViewController.view.alpha = 0.0;
        [self.view addSubview:self.menuViewController.view];
    }
    
    // Fade it in
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         self.menuViewController.view.alpha = show ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)enableEditMode:(BOOL)editMode {
    DLog(@"editMode: %@", [NSString CK_stringForBoolean:editMode]);
    
    // Ensure edit mode is not tapped repeatedly.
    if (editMode == self.editMode) {
        return;
    }
    self.editMode = editMode;
    
    CGAffineTransform illustrationTransform = CGAffineTransformIdentity;
    BenchtopLayout *layoutToToggle = nil;
    if (editMode) {
        
        // Edit mode layout that moves the other books out.
        layoutToToggle = [[BenchtopEditLayout alloc] initWithBenchtopDelegate:self];
        
        // Edit overlayview.
        UIImageView *editOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_overlay.png"]];
        editOverlayView.autoresizingMask = UIViewAutoresizingNone;
        editOverlayView.alpha = 0.0;
        [self.view insertSubview:editOverlayView belowSubview:self.menuViewController.view];
        self.editOverlayView = editOverlayView;
        
        // Prepare the illustration picker.
        IllustrationPickerViewController *illustrationViewController = [[IllustrationPickerViewController alloc] initWithIllustration:self.myBook.illustration cover:self.myBook.cover delegate:self];
        illustrationViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
                                                           self.view.bounds.size.height,
                                                           self.view.bounds.size.width,
                                                           illustrationViewController.view.frame.size.height);
        [illustrationViewController scrollToIllustration];
        [self.view insertSubview:illustrationViewController.view belowSubview:self.editOverlayView];
        self.illustrationViewController = illustrationViewController;
        illustrationTransform = CGAffineTransformMakeTranslation(0.0, - self.illustrationViewController.view.frame.size.height);
        
        // Prepare the cover picker.
        CoverPickerViewController *coverViewController = [[CoverPickerViewController alloc] initWithCover:self.myBook.cover delegate:self];
        coverViewController.view.frame = CGRectMake(0.0,
                                                    -coverViewController.view.frame.size.height,
                                                    coverViewController.view.frame.size.width,
                                                    coverViewController.view.frame.size.height);
        [self.view addSubview:coverViewController.view];
        [coverViewController addObserver:self forKeyPath:@"collectionView.contentSize" options:NSKeyValueObservingOptionNew context:NULL];
        self.coverViewController = coverViewController;
        UIEdgeInsets pickerInsets = UIEdgeInsetsMake(floorf((self.menuViewController.view.frame.size.height - coverViewController.view.frame.size.height) / 2.0), 100.0, 0.0, 100.0);
        
        // Change to the editMode layout
        [self.collectionView setCollectionViewLayout:layoutToToggle animated:YES];
        
        // Dispatch after delay.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            // Show illustrations.
            CGFloat bounceOffset = 10.0;
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationCurveEaseOut
                             animations:^{
                                 [self.menuViewController setEditMode:editMode animated:NO];
                                 self.editOverlayView.alpha = 1.0;
                                 self.coverViewController.view.transform = CGAffineTransformMakeTranslation(0.0, self.coverViewController.view.frame.size.height + pickerInsets.top);
                                 self.illustrationViewController.view.transform = CGAffineTransformMakeTranslation(0.0, -self.illustrationViewController.view.frame.size.height - bounceOffset);
                             }
                             completion:^(BOOL finished) {
                                 [UIView animateWithDuration:0.2
                                                       delay:0.0
                                                     options:UIViewAnimationCurveEaseIn
                                                  animations:^{
                                                      self.illustrationViewController.view.transform = CGAffineTransformMakeTranslation(0.0, -self.illustrationViewController.view.frame.size.height);
                                                  }
                                                  completion:^(BOOL finished) {
                                                  }];
                             }];
        });

    } else {
        
        layoutToToggle = [[BenchtopStackLayout alloc] initWithBenchtopDelegate:self];
        
        // Hide illustrations
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             [self.menuViewController setEditMode:editMode animated:NO];
                             self.editOverlayView.alpha = 0.0;
                             self.illustrationViewController.view.transform = CGAffineTransformIdentity;
                             self.coverViewController.view.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             [self.editOverlayView removeFromSuperview];
                             self.editOverlayView = nil;
                             [self.illustrationViewController.view removeFromSuperview];
                             self.illustrationViewController = nil;
                             [self.coverViewController removeObserver:self forKeyPath:@"collectionView.contentSize"];
                             [self.coverViewController.view removeFromSuperview];
                             self.coverViewController = nil;
                             
                         }];
        
        // Dispatch after delay.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.collectionView setCollectionViewLayout:layoutToToggle animated:YES];
        });

    }
}

- (NSArray *)partingIndexPathsForIndexPath:(NSIndexPath *)indexPath {
    return [[self.collectionView indexPathsForVisibleItems] select:^BOOL(NSIndexPath *currentIndexPath) {
        return ([currentIndexPath compare:indexPath] != NSOrderedSame);
    }];
}

@end
