//
//  CKBenchtopViewController.m
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 9/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBenchtopViewController.h"
#import "CKBenchtopStackLayout.h"
#import "CKBenchtopFlowLayout.h"
#import "CKBenchtopBookCell.h"
#import "CKBenchtopLayout.h"
#import "CKUser.h"
#import "CKBook.h"
#import "CKLoginBookCell.h"
#import "RecipeListViewController.h"
#import "BookViewController.h"
#import "EventHelper.h"

@interface CKBenchtopViewController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) BOOL firstBenchtop;
@property (nonatomic, assign) BOOL snapActivated;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) CKBook *myBook;
@property (nonatomic, strong) NSArray *friendsBooks;

@end

@implementation CKBenchtopViewController

#define kBookCellId                 @"BookCell"
#define kLoginCellId                @"LoginCell"
#define kBackgroundAvailOffset      50.0
#define kNumFriendsMaxStack         2

- (void)dealloc {
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterBenchtopFreeze:self];
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset"];
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[CKBenchtopStackLayout alloc] initWithBenchtopDelegate:self]]) {
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
    
    [self.collectionView registerClass:[CKBenchtopBookCell class] forCellWithReuseIdentifier:kBookCellId];
    [self.collectionView registerClass:[CKLoginBookCell class] forCellWithReuseIdentifier:kLoginCellId];
    
    // Register for events.
    [EventHelper registerBenchtopFreeze:self selector:@selector(benchtopFreezeRequested:)];
    [EventHelper registerLoginSucessful:self selector:@selector(loginSuccessful:)];
}

- (void)viewDidAppear:(BOOL)animated {
    //[self loadData];
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
                        
                         [self.collectionView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
                         [self loadData];
                     }];
    
}

- (void)freeze:(BOOL)freeze {
    self.collectionView.userInteractionEnabled = !freeze;
}

#pragma mark - CKBenchtopDelegate methods

- (BOOL)onMyBenchtop {
    return self.firstBenchtop;
}

- (CGSize)benchtopItemSize {
    return [CKBenchtopBookCell cellSize];
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

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKBenchtopBookCell *cell = (CKBenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    // Ignore if the cell is not enabled.
    if (![cell enabled]) {
        return;
    }
    DLog(@"didSelectItemAtIndexPath: %@", indexPath);
    
    if (!self.firstBenchtop) {
        [collectionView scrollToItemAtIndexPath:indexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:YES];
        
    } else {
        //bookview
        BookViewController *bookViewVC = [[BookViewController alloc] initWithBook:self.myBook];
        [self presentViewController:bookViewVC animated:YES completion:^{
        }];
    }
    
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!self.enabled) {
        return 0;
    }
    
    return 2;   // My Book + Login/Friends
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    if (!self.enabled) {
        return 0;
    }
    
    if (section == 0) {
        numItems = 1;   // My Book
    } else {
        CKUser *currentUser = [CKUser currentUser];
        if ([currentUser isSignedIn]) {
            numItems += MIN([currentUser numFollows], kNumFriendsMaxStack);
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
        
        if (nextSnapCell && CGRectContainsRect(visibleRect, nextSnapCell.frame)) {
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

#pragma mark - KVO methods.

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    // Update background parallax scrolling.
    if ([keyPath isEqualToString:@"contentOffset"] || [keyPath isEqualToString:@"contentSize"]) {
        [self updateBackgroundScrolling];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private

- (void)toggleLayout {
    CKBenchtopLayout *layoutToToggle = nil;
    
    // Select the first cell.
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]
                                      animated:NO
                                scrollPosition:UICollectionViewScrollPositionNone];
    
    if ([self.collectionView.collectionViewLayout isKindOfClass:[CKBenchtopFlowLayout class]]) {
        layoutToToggle = [[CKBenchtopStackLayout alloc] initWithBenchtopDelegate:self];
    } else {
        layoutToToggle = [[CKBenchtopFlowLayout alloc] initWithBenchtopDelegate:self];
    }
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         [self.collectionView setCollectionViewLayout:layoutToToggle animated:NO];
                     }
                     completion:^(BOOL finished) {
                         [layoutToToggle layoutCompleted];
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
    
    // Toggle the layout
    if ([[CKUser currentUser] isSignedIn]) {
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
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ff_dash_bg_tile.png"]];
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
    
    // Load my book.
    [self loadMyBook];
    
    // If signed in, start loading friends books.
    if ([[CKUser currentUser] isSignedIn]) {
        [self loadFriendsBooks];
    }
}

- (void)loadMyBook {
    
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
    
    // Load friends books - this also does auto-follow in the background.
    [CKBook friendsBooksForUser:[CKUser currentUser]
                        success:^(NSArray *friendsBooks) {
                            self.friendsBooks = friendsBooks;
                            [self.collectionView reloadData];
                            
                            // Inform layout complete.
                            CKBenchtopLayout *layout = (CKBenchtopLayout *)self.collectionView.collectionViewLayout;
                            [layout layoutCompleted];
                            
                        }
                        failure:^(NSError *error) {
                            DLog(@"Error: %@", [error localizedDescription]);
                        }];
    
}

- (UICollectionViewCell *)myBookCellForIndexPath:(NSIndexPath *)indexPath {
    CKBenchtopBookCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kBookCellId
                                                                              forIndexPath:indexPath];
    if (self.myBook) {
        [cell loadBook:self.myBook];
    }
    return cell;
}

- (UICollectionViewCell *)otherBookCellsForIndexPath:(NSIndexPath *)indexPath {
    CKBenchtopBookCell *cell = nil;
    CKUser *user = [CKUser currentUser];
    if ([user isSignedIn]) {
        
        if ([user isAdmin]) {
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
            [cell loadAsPlaceholder];
        }
    }
    return cell;
}

- (void)updateMyBook:(CKBook *)book {
    self.myBook = book;
    CKBenchtopBookCell *cell = (CKBenchtopBookCell *)[self.collectionView cellForItemAtIndexPath:
                                                      [NSIndexPath indexPathForItem:0 inSection:0]];
    [cell loadBook:book];
}

- (void)benchtopFreezeRequested:(NSNotification *)notification {
    BOOL freeze = [EventHelper benchFreezeForNotification:notification];
    self.collectionView.userInteractionEnabled = !freeze;
}

- (void)loginSuccessful:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
       
        // Load friends book objects.
        [CKBook friendsBooksForUser:[CKUser currentUser]
                            success:^(NSArray *books) {
                                
                                // Keep a reference of the friends books to reload the collection view with.
                                self.friendsBooks = books;
                                
                                // Reveal the login book cell.
                                CKLoginBookCell *loginBookCell = (CKLoginBookCell *)[self.collectionView cellForItemAtIndexPath:
                                                                                     [NSIndexPath indexPathForItem:0 inSection:1]];
                                
                                [loginBookCell revealWithCompletion:^{
                                    [self.collectionView reloadData];
                                    [self toggleLayout];
                                }];
                            }
                            failure:^(NSError *error) {
                            }];
        
    } else {
        self.collectionView.userInteractionEnabled = YES;
    }
}

@end
