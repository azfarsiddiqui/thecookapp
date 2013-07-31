//
//  PagingBenchtopViewController.m
//  CKPagingBenchtopDemo
//
//  Created by Jeff Tan-Ang on 8/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "PagingBenchtopViewController.h"
#import "PagingCollectionViewLayout.h"
#import "BenchtopBookCoverViewCell.h"
#import "EventHelper.h"
#import "CKPagingView.h"
#import "CKNotificationView.h"
#import "NotificationsViewController.h"
#import "CKPopoverViewController.h"
#import "ViewHelper.h"
#import "CKBook.h"
#import "MRCEnumerable.h"
#import "CoverPickerViewController.h"
#import "IllustrationPickerViewController.h"
#import "PagingScrollView.h"
#import "PagingBenchtopBackgroundView.h"
#import "CKBookCover.h"

@interface PagingBenchtopViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    UIGestureRecognizerDelegate, PagingCollectionViewLayoutDelegate, CKPopoverViewControllerDelegate,
    CKNotificationViewDelegate, BenchtopBookCoverViewCellDelegate, CoverPickerViewControllerDelegate,
    IllustrationPickerViewControllerDelegate>

@property (nonatomic, strong) UIImageView *backgroundTextureView;
@property (nonatomic, strong) PagingBenchtopBackgroundView *pagingBenchtopView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *backdropScrollView;
@property (nonatomic, strong) CKPagingView *benchtopLevelView;
@property (nonatomic, strong) CKNotificationView *notificationView;
@property (nonatomic, strong) UIImageView *overlayView;
@property (nonatomic, strong) UIImageView *vignetteView;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) CKPopoverViewController *popoverViewController;
@property (nonatomic, strong) CoverPickerViewController *coverViewController;
@property (nonatomic, strong) IllustrationPickerViewController *illustrationViewController;

@property (nonatomic, strong) CKBook *myBook;
@property (nonatomic, strong) NSMutableArray *followBooks;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL deleteMode;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL editMode;

@property (nonatomic, assign) CGPoint previousScrollPosition;
@property (nonatomic, assign) BOOL forwardDirection;

@end

@implementation PagingBenchtopViewController

#define kCellId         @"CellId"
#define kCellSize       CGSizeMake(300.0, 438.0)
#define kSideMargin     362.0
#define kMyBookSection  0
#define kFollowSection  1
#define kPagingRate     2.0

- (id)init {
    if (self = [super init]) {
        self.allowDelete = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor whiteColor];
    [self initBackground];
    [self initCollectionView];
    [self initBenchtopLevelView];
    [self initNotificationView];
    
    if ([CKUser isLoggedIn]) {
        [self loadBenchtop:YES];
    }
    
    [EventHelper registerFollowUpdated:self selector:@selector(followUpdated:)];
    [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
}

#pragma mark - PagingBenchtopViewController methods

- (void)enable:(BOOL)enable {
    self.collectionView.userInteractionEnabled = enable;
    
    if ([CKUser isLoggedIn]) {
        self.benchtopLevelView.hidden = NO;
        self.notificationView.hidden = NO;
        [self updateBenchtopLevelView];
    } else {
        self.benchtopLevelView.hidden = YES;
        self.notificationView.hidden = YES;
    }
    
}

- (void)bookWillOpen:(BOOL)open {
    BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:self.selectedIndexPath];
    cell.bookCoverView.hidden = YES;
    [self showBookCell:cell show:!open];
}

- (void)bookDidOpen:(BOOL)open {
    
    // Restore the bookCover.
    if (!open) {
        BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:self.selectedIndexPath];
        cell.bookCoverView.hidden = NO;
    }
    
    // Enable panning based on book opened or not.
    [self.delegate panEnabledRequested:!open];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Update the backdrop.
    if (scrollView == self.collectionView) {
        
        // Keep track of direction of scroll.
        self.forwardDirection = scrollView.contentOffset.x > self.previousScrollPosition.x;
        self.previousScrollPosition = scrollView.contentOffset;
        
        if (scrollView.contentOffset.x < 0) {
            
            self.backdropScrollView.contentOffset = (CGPoint) {
                self.collectionView.contentOffset.x,
                self.backdropScrollView.contentOffset.y
            };
            
        } else  {
            
            self.backdropScrollView.contentOffset = (CGPoint) {
                self.collectionView.contentOffset.x * (self.collectionView.bounds.size.width / 300.0),
                self.backdropScrollView.contentOffset.y
            };

        }
                
    } else if (scrollView == self.backdropScrollView) {
        
        CGPoint contentOffset = self.backdropScrollView.contentOffset;
        self.backgroundTextureView.center = (CGPoint) {
            contentOffset.x + floorf(self.backdropScrollView.bounds.size.width / 2.0),
            self.backgroundTextureView.center.y
        };
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView == self.collectionView) {
        if (!decelerate) {
            [self snapToNearestBook];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [self snapToNearestBook];
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    switch (section) {
        case kMyBookSection:
            numItems = self.myBook ? 1 : 0;
            break;
        case kFollowSection:
            numItems = [self.followBooks count];
            break;
        default:
            break;
    }
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                             forIndexPath:indexPath];
    cell.delegate = self;
    
    if (indexPath.section == kMyBookSection) {
        [cell loadBook:self.myBook];
        
    } else if (indexPath.section == kFollowSection) {
        CKBook *book = [self.followBooks objectAtIndex:indexPath.item];
        [cell loadBook:book];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // No book opening in edit mode.
    if (self.editMode) {
        return;
    }
    
    // Only open book if book was in the center.
    if ([self isCenterBookAtIndexPath:indexPath]) {
        
        self.selectedIndexPath = indexPath;
        [self openBookAtIndexPath:indexPath];
        
    } else {
        
        // Scroll to the books.
        [self scrollToBookAtIndexPath:indexPath];
        
    }
    
}

#pragma mark - CKPagingCollectionViewLayoutDelegate methods

- (void)pagingLayoutDidUpdate {
    
    // Update blurring backdrop only in non-edit mode.
    if (!self.editMode) {
        [self updatePagingBenchtopView];
        
    }
}

#pragma mark - CKNotificationViewDelegate methods

- (void)notificationViewTapped:(CKNotificationView *)notifyView {
    DLog();
    [notifyView clear];
    
    NotificationsViewController *notificationsViewController = [[NotificationsViewController alloc] init];
    CKPopoverViewController *popoverViewController = [[CKPopoverViewController alloc] initWithContentViewController:notificationsViewController
                                                                                                           delegate:self];
    [popoverViewController showInView:self.view direction:CKPopoverViewControllerLeft atPoint:CGPointMake(notifyView.frame.origin.x + notifyView.frame.size.width,
                                                                                                          notifyView.frame.origin.y + floorf(notifyView.frame.size.height / 2.0))];
    self.popoverViewController = popoverViewController;
}

- (UIView *)notificationItemViewForIndex:(NSInteger)itemIndex {
    return nil;
}

- (void)notificationView:(CKNotificationView *)notifyView tappedForItemIndex:(NSInteger)itemIndex {
    [notifyView clear];
}

#pragma mark - CKPopoverViewControllerDelegate methods

- (void)popoverViewController:(CKPopoverViewController *)popoverViewController willAppear:(BOOL)appear {
    if (appear) {
        [self enable:NO];
    }
}

- (void)popoverViewController:(CKPopoverViewController *)popoverViewController didAppear:(BOOL)appear {
    if (!appear) {
        self.popoverViewController = nil;
        [self enable:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Recognise taps only when collectionView is disabled.
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return (!self.collectionView.userInteractionEnabled);
    }
    
    return YES;
}

#pragma mark - BenchtopBookCoverViewCellDelegate methods

- (void)benchtopBookEditTappedForCell:(UICollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if ([self isCenterBookAtIndexPath:indexPath]) {
        [self enableEditMode:YES];
    } else {
        [self scrollToBookAtIndexPath:indexPath];
    }
}

#pragma mark - CoverPickerViewControllerDelegate methods

- (void)coverPickerCancelRequested {
    
    // Revert to previous illustration/cover.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.illustration = self.illustrationViewController.illustration;
    self.myBook.cover = self.coverViewController.cover;
    [cell loadBook:self.myBook];
    
    // Reload the illustration cover.
    [self.illustrationViewController changeCover:self.coverViewController.cover];
    
    [self enableEditMode:NO];
}

- (void)coverPickerDoneRequested {
    
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.name = cell.bookCoverView.nameValue;
    self.myBook.author = cell.bookCoverView.authorValue;
    [self.myBook saveInBackground];
    
    [cell loadBook:self.myBook];
    [self enableEditMode:NO];
}

- (void)coverPickerSelected:(NSString *)cover {
    
    // Force reload my book with the selected illustration.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.cover = cover;
    [cell loadBook:self.myBook];
    
    // Reload the illustration covers.
    [self.illustrationViewController changeCover:cover];
}

#pragma mark - IllustrationPickerViewControllerDelegate methods

- (void)illustrationSelected:(NSString *)illustration {
    
    // Force reload my book with the selected illustration.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.illustration = illustration;
    [cell loadBook:self.myBook];
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Background texture.
    UIImage *backgroundTextureImage = [UIImage imageNamed:@"cook_dash_background.png"];
    
    UIScrollView *backdropScrollView = [[UIScrollView alloc] initWithFrame:(CGRect){
        self.view.bounds.origin.x,
        floorf((self.view.bounds.size.height - backgroundTextureImage.size.height) / 2.0),
        self.view.bounds.size.width,
        backgroundTextureImage.size.height
    }];
    
    // Important to peek past bounds.
    backdropScrollView.clipsToBounds = NO;
    
    backdropScrollView.delegate = self;
    backdropScrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    backdropScrollView.backgroundColor = [UIColor whiteColor];
    backdropScrollView.scrollEnabled = YES;
    backdropScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:backdropScrollView];
    self.backdropScrollView = backdropScrollView;
    
    // Add the texture.
    self.backgroundTextureView = [[UIImageView alloc] initWithImage:backgroundTextureImage];
    self.backgroundTextureView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    self.backgroundTextureView.frame = (CGRect) {
        floorf((self.backdropScrollView.bounds.size.width - self.backgroundTextureView.frame.size.width) / 2.0),
        floorf((self.backdropScrollView.bounds.size.height - self.backgroundTextureView.frame.size.height) / 2.0),
        self.backgroundTextureView.frame.size.width,
        self.backgroundTextureView.frame.size.height
    };
    [self.backdropScrollView addSubview:self.backgroundTextureView];
    
    // Add motion effects on the scrollview.
    [ViewHelper applyMotionEffectsToView:self.backdropScrollView];
    
    // Toolbar blurring.
//    UIToolbar *toolbarOverlay = [[UIToolbar alloc] initWithFrame:self.view.bounds];
//    toolbarOverlay.userInteractionEnabled = NO;
//    toolbarOverlay.translucent = YES;
//    [self.view addSubview:toolbarOverlay];
}

- (void)initCollectionView {
    PagingCollectionViewLayout *pagingLayout = [[PagingCollectionViewLayout alloc] initWithDelegate:self];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:pagingLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    
    // TODO CAUSES JERKY MOVEMENTS
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    [collectionView registerClass:[BenchtopBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // Register a long press
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [collectionView addGestureRecognizer:longPressGesture];
    
    // Register tap to dismiss.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    // Vignette overlay to go over the collectionView.
    UIImageView *vignetteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_background_vignette.png"]];
    vignetteView.center = self.view.center;
    vignetteView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:vignetteView aboveSubview:self.collectionView];
    self.vignetteView = vignetteView;
}

- (void)initBenchtopLevelView {
    CKPagingView *benchtopLevelView = [[CKPagingView alloc] initWithNumPages:3 startPage:1 type:CKPagingViewTypeVertical];
    benchtopLevelView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    benchtopLevelView.frame = CGRectMake(30.0,
                                         floorf((self.view.bounds.size.height - benchtopLevelView.frame.size.height) / 2.0),
                                         benchtopLevelView.frame.size.width,
                                         benchtopLevelView.frame.size.height);
    [self.view addSubview:benchtopLevelView];
    self.benchtopLevelView = benchtopLevelView;
}

- (void)initNotificationView {
    CKNotificationView *notificationView = [[CKNotificationView alloc] initWithDelegate:self];
    notificationView.frame = CGRectMake(13.0, 50.0, notificationView.frame.size.width, notificationView.frame.size.height);
    [self.view addSubview:notificationView];
    [notificationView setNotificationItems:nil];
    self.notificationView = notificationView;
}

- (PagingCollectionViewLayout *)pagingLayout {
    return (PagingCollectionViewLayout *)self.collectionView.collectionViewLayout;
}

- (void)longPressed:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPressGesture locationInView:self.collectionView]];
        
        if (indexPath != nil) {
            
            // Delete mode when in Follow section.
            if (indexPath.section == kFollowSection) {
                
                // Scroll to center, then enable delete mode.
                [self scrollToBookAtIndexPath:indexPath];
                [self enableDeleteMode:YES indexPath:indexPath];
            }
        }
    }
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    [self.delegate panToBenchtopForSelf:self];
}

- (void)updateBenchtopLevelView {
    self.benchtopLevelView.hidden = NO;
    NSInteger level = [self.delegate currentBenchtopLevel];
    switch (level) {
        case 2:
            [self.benchtopLevelView setPage:0];
            break;
        case 1:
            [self.benchtopLevelView setPage:1];
            break;
        case 0:
            [self.benchtopLevelView setPage:2];
            break;
        default:
            break;
    }
}

- (BenchtopBookCoverViewCell *)myBookCell {
    return [self bookCellAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]];
}

- (BenchtopBookCoverViewCell *)bookCellAtIndexPath:(NSIndexPath *)indexPath {
    return (BenchtopBookCoverViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)enableDeleteMode:(BOOL)enable indexPath:(NSIndexPath *)indexPath {
    
    BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:indexPath];
    [cell enableDeleteMode:enable];
    
    if (enable) {
        
        // Tell root VC to disable panning.
        [self.delegate panEnabledRequested:NO];
        
        // Dim overlay view.
        UIImageView *overlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_background_whiteout.png"]];
        overlayView.center = self.view.center;
        overlayView.alpha = 0.0;
        overlayView.userInteractionEnabled = YES;
        [self.view addSubview:overlayView];
        self.overlayView = overlayView;
        
        // Register gestures to dimiss.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteDismissedByTap:)];
        [overlayView addGestureRecognizer:tapGesture];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(deleteDismissedByPan:)];
        [overlayView addGestureRecognizer:panGesture];
        
        // Remember the cell to be deleted.
        self.selectedIndexPath = indexPath;
        
        // Position the delete button.
        CGRect frame = [self.collectionView convertRect:cell.frame toView:overlayView];
        UIButton *deleteButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_btns_remove.png"]
                                                      target:self
                                                    selector:@selector(deleteTapped:)];
        deleteButton.frame = CGRectMake(frame.origin.x - floorf(deleteButton.frame.size.width / 2.0) + 3.0,
                                        frame.origin.y - floorf(deleteButton.frame.size.height / 2.0) + 15.0,
                                        deleteButton.frame.size.width,
                                        deleteButton.frame.size.height);
        [overlayView addSubview:deleteButton];
        deleteButton.alpha = 0.0;
        self.deleteButton = deleteButton;
        
        // Watch the cell frame.
        [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
    } else {
        
        // Remove observer.
        [self.collectionView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         [self.delegate deleteModeToggled:enable];
                         
                         // Fade the edit overlay.
                         self.overlayView.alpha = enable ? 1.0 : 0.0;
                         
                         // Fade the delete button.
                         self.deleteButton.alpha = enable ? 1.0 : 0.0;
                         
                         // Fade the icons away.
                         self.notificationView.alpha = enable ? 0.0 : 1.0;
                         self.benchtopLevelView.alpha = enable ? 0.0 : 1.0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         // Remember delete mode.
                         self.deleteMode = enable;
                         
                         if (!enable) {
                             [self.overlayView removeFromSuperview];
                             [self.deleteButton removeFromSuperview];
                             self.overlayView = nil;
                             self.deleteButton = nil;
                             self.selectedIndexPath = nil;
                             
                             // Tell root VC to re-enable panning.
                             [self.delegate panEnabledRequested:YES];
                             
                         }
                         
                     }];
}

- (void)deleteDismissedByTap:(UITapGestureRecognizer *)tapGesture {
    [self enableDeleteMode:NO indexPath:self.selectedIndexPath];
}

- (void)deleteDismissedByPan:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self enableDeleteMode:NO indexPath:self.selectedIndexPath];
    }
}

- (void)deleteTapped:(id)sender {
    [self unfollowBookAtIndexPath:self.selectedIndexPath];
    [self enableDeleteMode:NO indexPath:self.selectedIndexPath];
}

- (void)loadBenchtop:(BOOL)load {
    [self enable:load];
    
    if (load) {
        [self loadMyBook];
        [self loadFollowBooks];
    } else {
        self.myBook = nil;
        [self.followBooks removeAllObjects];
        self.followBooks = nil;
        [self.collectionView reloadData];
    }
    
}

- (void)loadMyBook {
    CKUser *currentUser = [CKUser currentUser];
    [CKBook fetchBookForUser:currentUser
                     success:^(CKBook *book) {
                         
                         if (self.myBook) {
                             
                             // Update benchtop if book is of a different cover.
                             BOOL changedCover = ![self.myBook.cover isEqualToString:book.cover];
                             
                             // Reload the book.
                             self.myBook = book;
                             BenchtopBookCoverViewCell *myBookCell = [self myBookCell];
                             [myBookCell loadBook:book];
                             
                             // Update after myBook has been set.
                             if (changedCover) {
                                 [self updatePagingBenchtopView];
                             }
                             
                         } else {
                             self.myBook = book;
                             [[self pagingLayout] markLayoutDirty];
                             [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]]];
                         }
                         
                     }
                     failure:^(NSError *error) {
                         DLog(@"Error: %@", [error localizedDescription]);
                     }];
}

- (void)loadFollowBooks {
    [self loadFollowBooksReload:NO];
}

- (void)loadFollowBooksReload:(BOOL)reload {
    CKUser *currentUser = [CKUser currentUser];
    [CKBook followBooksForUser:currentUser
                       success:^(NSArray *books) {
                           self.followBooks = [NSMutableArray arrayWithArray:books];
                           NSArray *indexPathsToInsert = [self indexPathsForFollowBooks];
                           
                           if (reload) {
                               [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
                           } else {
                               [[self pagingLayout] markLayoutDirty];
                               [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
                           }
                       }
                       failure:^(NSError *error) {
                           DLog(@"Error: %@", [error localizedDescription]);
                       }];
}

- (NSArray *)indexPathsForFollowBooks {
    return [self.followBooks collectWithIndex:^id(CKBook *book, NSUInteger bookIndex) {
        return [NSIndexPath indexPathForItem:bookIndex inSection:kFollowSection];
    }];
}

- (void)enableEditMode:(BOOL)enable {
    
    // Ignore if we're already animating.
    if (self.animating) {
        return;
    }
    
    // Ignore if we're already in editMode.
    if (self.editMode && enable) {
        return;
    }
    
    self.animating = YES;
    self.editMode = enable;
    self.collectionView.scrollEnabled = !enable;
    
    if (enable) {
        
        // Cover
        CoverPickerViewController *coverViewController = [[CoverPickerViewController alloc] initWithCover:self.myBook.cover delegate:self];
        coverViewController.view.frame = CGRectMake(0.0,
                                                    -coverViewController.view.frame.size.height,
                                                    self.view.bounds.size.width,
                                                    coverViewController.view.frame.size.height);
        [self.view addSubview:coverViewController.view];
        self.coverViewController = coverViewController;
        
        // Illustration.
        IllustrationPickerViewController *illustrationViewController = [[IllustrationPickerViewController alloc] initWithIllustration:self.myBook.illustration cover:self.myBook.cover delegate:self];
        illustrationViewController.view.frame = CGRectMake(0.0,
                                                           self.view.bounds.size.height,
                                                           self.view.bounds.size.width,
                                                           illustrationViewController.view.frame.size.height);
        [self.view addSubview:illustrationViewController.view];
        self.illustrationViewController = illustrationViewController;
        
    }
    
    BenchtopBookCoverViewCell *myBookCell = [self myBookCell];
    
    CGFloat bounceOffset = 20.0;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Tell the layout to go into edit mode.
                         [[self pagingLayout] enableEditMode:enable];
                         // [self.collectionView reloadItemsAtIndexPaths:[self indexPathsForFollowBooks]];
                         [[self pagingLayout] invalidateLayout];
                         
                         // Slide up collectionView.
                         self.collectionView.transform = enable ? CGAffineTransformMakeTranslation(0.0, -50.0) : CGAffineTransformIdentity;
                         
                         // Inform delegate
                         [self.delegate editBookRequested:enable];
                         
                         // Hide the icons.
                         self.notificationView.alpha = enable ? 0.0 : 1.0;
                         self.benchtopLevelView.alpha = enable ? 0.0 : 1.0;
                         
                         // Slide down the cover picker.
                         self.coverViewController.view.transform = enable ? CGAffineTransformMakeTranslation(0.0, self.coverViewController.view.frame.size.height) : CGAffineTransformIdentity;
                         
                         // Slide up illustration picker with bounce.
                         self.illustrationViewController.view.transform = enable ? CGAffineTransformMakeTranslation(0.0, -self.illustrationViewController.view.frame.size.height - bounceOffset) : CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         
                         // Enable edit mode on book cell.
                         [myBookCell enableEditMode:enable];
                         
                         if (enable) {
                             
                             [UIView animateWithDuration:0.3
                                                   delay:0.0
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  
                                                  // Restore illustration picker after bounce.
                                                  self.illustrationViewController.view.transform = CGAffineTransformTranslate(self.illustrationViewController.view.transform, 0.0, bounceOffset);
                                              } completion:^(BOOL finished) {
                                                  self.animating = NO;
                                                  
                                                  
                                              }];
                         } else {
                             
                             self.animating = NO;
                             [self.coverViewController.view removeFromSuperview];
                             [self.illustrationViewController.view removeFromSuperview];
                             self.coverViewController = nil;
                             self.illustrationViewController = nil;
                         }
                     }];
}

- (void)unfollowBookAtIndexPath:(NSIndexPath *)indexPath {
    
    CKBook *book = [self.followBooks objectAtIndex:indexPath.item];
    CKUser *currentUser = [CKUser currentUser];
    
    // Kick off the immediate removal of the book onscreen.
    [self.followBooks removeObjectAtIndex:indexPath.item];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
    
    // Unfollow in the background, then inform listeners of the update.
    BOOL isFriendsBook = [book isThisMyFriendsBook];
    [book removeFollower:currentUser
                 success:^{
                     [EventHelper postFollow:NO friends:isFriendsBook];
                 } failure:^(NSError *error) {
                     DLog(@"Unable to unfollow.");
                 }];
    
}

- (BOOL)isCenterBookAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    return (CGRectContainsPoint(attributes.frame,
                                CGPointMake(self.collectionView.contentOffset.x + (self.collectionView.bounds.size.width / 2.0),
                                            self.collectionView.center.y)));
}

- (void)openBookAtIndexPath:(NSIndexPath *)indexPath {
    CKBook *book = (indexPath.section == kMyBookSection) ? self.myBook : [self.followBooks objectAtIndex:indexPath.item];
    BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:indexPath];
    CGPoint centerPoint = cell.contentView.center;
    [self.delegate openBookRequestedForBook:book centerPoint:centerPoint];
}

- (void)scrollToBookAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:YES];
}

- (void)followUpdated:(NSNotification *)notification {
    BOOL follow = [EventHelper followForNotification:notification];
    if (follow) {
        [self loadFollowBooksReload:YES];
    }
}

- (void)loggedIn:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
        [self loadBenchtop:YES];
    }
}

- (void)loggedOut:(NSNotification *)notification {
    [self loadBenchtop:NO];
}

- (void)updatePagingBenchtopView {
    
    // Create a new blended benchtop with the current layout.
    PagingBenchtopBackgroundView *pagingBenchtopView = [self createPagingBenchtopBackgroundView];
    
    // Blend it and update the benchtop.
    [pagingBenchtopView blendWithCompletion:^{
        
        // Updates contentSize to new blended benchtop.
        self.backdropScrollView.contentSize = pagingBenchtopView.frame.size;
        
        // Move it below the existing one.
        if (self.pagingBenchtopView) {
            [self.backdropScrollView insertSubview:pagingBenchtopView belowSubview:self.pagingBenchtopView];
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.pagingBenchtopView.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [self.pagingBenchtopView removeFromSuperview];
                                 self.pagingBenchtopView = pagingBenchtopView;
                             }];
            
        } else {
            self.pagingBenchtopView = pagingBenchtopView;
            self.pagingBenchtopView.alpha = 0.0;
            [self.backdropScrollView insertSubview:self.pagingBenchtopView belowSubview:self.backgroundTextureView];
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.pagingBenchtopView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        
    }];
    
}

- (PagingBenchtopBackgroundView *)createPagingBenchtopBackgroundView {
    NSInteger numMyBook = [self.collectionView numberOfItemsInSection:kMyBookSection];
    NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
    
    PagingBenchtopBackgroundView *pagingBenchtopView = [[PagingBenchtopBackgroundView alloc] initWithFrame:(CGRect){
        self.backdropScrollView.bounds.origin.x,
        self.backdropScrollView.bounds.origin.y,
        self.collectionView.bounds.size.width * (numMyBook + 1 + numFollowBooks),
        self.backgroundTextureView.frame.size.height
    }];
    
    // Loop through and add colours.
    NSInteger numSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numSections; section++) {
        
        if (section == kMyBookSection) {
            
            if (self.myBook) {
                [pagingBenchtopView addColour:[CKBookCover backdropColourForCover:self.myBook.cover]];
            }
            
        } else if (section == kFollowSection) {
            
            // Add white for gap.
            [pagingBenchtopView addColour:[UIColor whiteColor]];
            
            NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
            for (NSInteger followIndex = 0; followIndex < numFollowBooks; followIndex++) {
                
                CKBook *book = [self.followBooks objectAtIndex:followIndex];
                [pagingBenchtopView addColour:[CKBookCover backdropColourForCover:book.cover]];
            }
            
        }
    }
    
    return pagingBenchtopView;
}

- (void)snapToNearestBook {
    PagingCollectionViewLayout *layout = [self pagingLayout];
    CGRect gap = [layout frameForGap];
    CGPoint visibleCenter = (CGPoint){
        self.collectionView.contentOffset.x + (self.collectionView.bounds.size.width / 2.0),
        self.collectionView.center.y
    };
    
    // Are we resting on the empty gap, then snap to nearest book given direction of scroll.
    if (CGRectContainsPoint(gap, visibleCenter)) {
        
        if (self.forwardDirection && [self.collectionView numberOfItemsInSection:kFollowSection] > 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kFollowSection]
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        } else if (!self.forwardDirection && [self.collectionView numberOfItemsInSection:kMyBookSection] > 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }

    }
}

- (void)showBookCell:(BenchtopBookCoverViewCell *)cell show:(BOOL)show {
    
    // Get a reference to all the visible cells.
    NSArray *visibleCells = [self.collectionView visibleCells];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.notificationView.alpha = show ? 1.0 : 0.0;
                         self.benchtopLevelView.alpha = show ? 1.0 : 0.0;
                         cell.shadowView.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.7, 0.7);
                         
                         // Fade in/out cells.
                         [visibleCells each:^(UICollectionViewCell *cell) {
                             cell.alpha = show ? 1.0 : 0.0;
                         }];
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
