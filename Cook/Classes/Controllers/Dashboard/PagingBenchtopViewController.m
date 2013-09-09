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
#import "SignUpBookCoverViewCell.h"
#import "EventHelper.h"
#import "CKPagingView.h"
#import "CKNotificationView.h"
#import "ViewHelper.h"
#import "CKBook.h"
#import "MRCEnumerable.h"
#import "CoverPickerViewController.h"
#import "IllustrationPickerViewController.h"
#import "PagingScrollView.h"
#import "PagingBenchtopBackgroundView.h"
#import "CKBookCover.h"
#import "SignupViewController.h"
#import "ImageHelper.h"
#import "ModalOverlayHelper.h"
#import "NotificationsViewController.h"
#import "CKServerManager.h"

@interface PagingBenchtopViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    UIGestureRecognizerDelegate, PagingCollectionViewLayoutDelegate, CKNotificationViewDelegate,
    BenchtopBookCoverViewCellDelegate, SignUpBookCoverViewCellDelegate, SignupViewControllerDelegate,
    CoverPickerViewControllerDelegate, IllustrationPickerViewControllerDelegate, NotificationsViewControllerDelegate>

@property (nonatomic, strong) UIImageView *backgroundTextureView;
@property (nonatomic, strong) PagingBenchtopBackgroundView *pagingBenchtopView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *backdropScrollView;
@property (nonatomic, strong) CKPagingView *benchtopLevelView;
@property (nonatomic, strong) CKNotificationView *notificationView;
@property (nonatomic, strong) UIImageView *overlayView;
@property (nonatomic, strong) UIImageView *vignetteView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImage *signupBlurImage;

@property (nonatomic, strong) CoverPickerViewController *coverViewController;
@property (nonatomic, strong) IllustrationPickerViewController *illustrationViewController;
@property (nonatomic, strong) SignupViewController *signUpViewController;
@property (nonatomic, strong) NotificationsViewController *notificationsViewController;

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
#define kSignUpCellId   @"SignUpCellId"
#define kCellSize       CGSizeMake(300.0, 438.0)
#define kSideMargin     362.0
#define kMyBookSection  0
#define kFollowSection  1
#define kPagingRate     2.0
#define kBlendPageWidth 1024.0
#define kBlendMinAlpha  0.3
#define kBlendMaxAlpha  0.45

- (void)dealloc {
    [EventHelper unregisterFollowUpdated:self];
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
    [EventHelper unregisterThemeChange:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                                  object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification
                                                  object:[UIApplication sharedApplication]];
}

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
    [super viewDidAppear:animated];
    
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
    [EventHelper registerThemeChange:self selector:@selector(themeChanged:)];
    
    // Register for notification that app did enter background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeInactive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    
    // Register for notification that app did enter foreground
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)loadBenchtop:(BOOL)load {
    DLog(@"load [%@]", load ? @"YES" : @"NO");
    [self enable:load];
    
    if (load) {
        [self loadMyBook];
        [self loadFollowBooks];
    } else {
        
        self.myBook = nil;
        [self.followBooks removeAllObjects];
        self.followBooks = nil;
        
        [[self pagingLayout] markLayoutDirty];
        [self.collectionView reloadData];
    }
    
}

- (void)showLoginViewSignUp:(BOOL)signUp {
    
    // Ignore in editMode.
    if (self.editMode) {
        return;
    }
    
    // Disable benchtop.
    [self.delegate panEnabledRequested:NO];
    [self enable:NO];
    
    self.signUpViewController = [[SignupViewController alloc] initWithDelegate:self];
    self.signUpViewController.view.alpha = 0.0;
    [self.signUpViewController enableSignUpMode:signUp animated:NO];
    [self.view addSubview:self.signUpViewController.view];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.signUpViewController.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)hideLoginViewCompletion:(void (^)())completion {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.signUpViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.signUpViewController.view removeFromSuperview];
                         self.signUpViewController = nil;
                         
                         // Re-enable benchtop.
                         [self enable:YES];
                         [self.delegate panEnabledRequested:YES];
                         
                         completion();
                     }];
}


#pragma mark - PagingBenchtopViewController methods

- (void)enable:(BOOL)enable {
    [self enable:enable animated:NO];
}

- (void)enable:(BOOL)enable animated:(BOOL)animated {
    self.collectionView.userInteractionEnabled = enable;
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.notificationView.alpha = enable ? 1.0 : 0.0;
                         } completion:^(BOOL finished) {
                             [self updatePagingBenchtopView];
                         }];
    } else {
        self.notificationView.alpha = enable ? 1.0 : 0.0;
        [self updateBenchtopLevelViewAnimated:NO];
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
                self.collectionView.contentOffset.x - ((self.collectionView.bounds.size.width - kBlendPageWidth) / 2.0),
                self.backdropScrollView.contentOffset.y
            };
            
        } else  {
            
            self.backdropScrollView.contentOffset = (CGPoint) {
//                (self.collectionView.bounds.size.width - kBlendPageWidth) + self.collectionView.contentOffset.x * (kBlendPageWidth / 300.0),
                self.collectionView.contentOffset.x * (kBlendPageWidth / 300.0) - ((self.collectionView.bounds.size.width - kBlendPageWidth) / 2.0),
                self.backdropScrollView.contentOffset.y
            };
//            DLog(@"backdrop contentOffset %@", NSStringFromCGPoint(self.backdropScrollView.contentOffset));

        }
        
        [self processPagingFade];
        
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
    DLog(@"numItems [%d]", numItems);
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCoverViewCell *cell = nil;
    if (![CKUser isLoggedIn] && indexPath.section == kMyBookSection) {
        cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSignUpCellId forIndexPath:indexPath];
    } else {
        cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    }
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

- (void)notificationViewTapped {
    
    if ([CKUser isLoggedIn]) {
        [self showNotificationsOverlay:YES];
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

- (void)benchtopBookEditWillAppear:(BOOL)appear forCell:(UICollectionViewCell *)cell {
    [self.coverViewController enable:!appear];
}

- (void)benchtopBookEditDidAppear:(BOOL)appear forCell:(UICollectionViewCell *)cell {
    [self.coverViewController enable:!appear];
}

#pragma mark - SignUpBookCoverViewCellDelegate methods

- (void)signUpBookSignInRequestedForCell:(SignUpBookCoverViewCell *)cell {
    [self showLoginViewSignUp:NO];
}

- (void)signUpBookRegisterRequestedForCell:(SignUpBookCoverViewCell *)cell {
    [self showLoginViewSignUp:YES];
}


#pragma mark - SignupViewControllerDelegate methods

- (UIImage *)signupViewControllerSnapshotImageRequested {
    if (self.signupBlurImage) {
        return self.signupBlurImage;
    } else {
        return [ImageHelper blurredImageFromView:self.view];
    }
}

- (UIView *)signupViewControllerSnapshotRequested {
    return [self.view snapshotViewAfterScreenUpdates:YES];
}

- (void)signupViewControllerDismissRequested {
    [self hideLoginViewCompletion:^{
        // Nothing.
    }];
}

- (void)signupViewControllerFocused:(BOOL)focused {
    DLog();
}

- (void)signUpViewControllerModalRequested:(BOOL)modal {
    DLog();
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
    
    if (!self.myBook.guest) {
        [self.myBook saveInBackground];
    }
    
    [cell loadBook:self.myBook];
    [self enableEditMode:NO];
    [self updatePagingBenchtopView];
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

#pragma mark - NotificationsViewControllerDelegate methods

- (void)notificationsViewControllerDataLoaded {
    [self.notificationView clearBadge];
}

- (void)notificationsViewControllerDismissRequested {
    [self showNotificationsOverlay:NO];
}

- (UIImage *)notificationsViewControllerSnapshotImageRequested {
    if (self.signupBlurImage) {
        return self.signupBlurImage;
    } else {
        return [ImageHelper blurredImageFromView:self.view];
    }
}

#pragma mark - Properties

- (UIImageView *)vignetteView {
    if (!_vignetteView) {
        _vignetteView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_dash_background_vignette" type:@"png"]];
    }
    return _vignetteView;
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Background texture.
    UIImage *backgroundTextureImage = [ImageHelper imageFromDiskNamed:@"cook_dash_background" type:@"png"];
    
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
    backdropScrollView.scrollEnabled = NO;
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
    [collectionView registerClass:[SignUpBookCoverViewCell class] forCellWithReuseIdentifier:kSignUpCellId];
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
    self.vignetteView.center = self.view.center;
    self.vignetteView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.vignetteView aboveSubview:self.collectionView];
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
    notificationView.frame = CGRectMake(18.0, 33.0, notificationView.frame.size.width, notificationView.frame.size.height);
    [self.view addSubview:notificationView];
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
    [self updateBenchtopLevelViewAnimated:YES];
}

- (void)updateBenchtopLevelViewAnimated:(BOOL)animated {
    self.benchtopLevelView.hidden = NO;
    NSInteger level = [self.delegate currentBenchtopLevel];
    switch (level) {
        case 2:
            [self.benchtopLevelView setPage:0 animated:animated];
            break;
        case 1:
            [self.benchtopLevelView setPage:1 animated:animated];
            break;
        case 0:
            [self.benchtopLevelView setPage:2 animated:animated];
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
        UIImageView *overlayView = [[UIImageView alloc] initWithImage:[ImageHelper imageFromDiskNamed:@"cook_dash_background_whiteout" type:@"png"]];
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
                                               selectedImage:[UIImage imageNamed:@"cook_btns_remove_onpress.png"]
                                                      target:self
                                                    selector:@selector(deleteTapped:)];
        deleteButton.frame = CGRectMake(frame.origin.x - floorf(deleteButton.frame.size.width / 2.0) + 3.0,
                                        frame.origin.y - floorf(deleteButton.frame.size.height / 2.0) + 15.0,
                                        deleteButton.frame.size.width,
                                        deleteButton.frame.size.height);
        [overlayView addSubview:deleteButton];
        deleteButton.alpha = 0.0;
        self.deleteButton = deleteButton;
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

- (void)loadMyBook {
    
    CKUser *currentUser = [CKUser currentUser];
    if (currentUser) {
        
        // Load logged-in user's book.
        [CKBook fetchBookForUser:currentUser
                         success:^(CKBook *book) {
                             
                             // Could be called again via cache, or reloaded via login.
                             if (self.myBook) {
                                 
                                 // If it's the same book, just reload it.
                                 if ([self.myBook.objectId isEqual:book.objectId]) {
                                     
                                     // Update benchtop if book is of a different cover.
                                     BOOL changedCover = ![self.myBook.cover isEqualToString:book.cover];
                                     self.myBook = book;
                                     
                                     // Reload the book, then update the benchtop if cover has changed.
                                     BenchtopBookCoverViewCell *cell = [self myBookCell];
                                     [cell loadBook:book];
                                     
                                     // Update after myBook has been set.
                                     if (changedCover) {
                                         [self updatePagingBenchtopView];
                                     }
                                     
                                 } else {
                                     
                                     // Just reload the book.
                                     self.myBook = book;
                                     
                                     // Reload the book then update blended benchtop.
                                     [self.collectionView performBatchUpdates:^{
                                         [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]]];
                                     } completion:^(BOOL finished) {
                                         [self updatePagingBenchtopView];
                                     }];
                                     
                                 }
                                 
                             } else {
                                 
                                 [[self pagingLayout] markLayoutDirty];
                                 self.myBook = book;
                                 
                                 // Insert book then update blended benchtop.
                                 [self.collectionView performBatchUpdates:^{
                                     [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]]];
                                 } completion:^(BOOL finished) {
                                     // No need to reblend, as layoutDidGenerate will trigger it.
                                 }];
                             }
                             
                         }
                         failure:^(NSError *error) {
                             DLog(@"Error: %@", [error localizedDescription]);
                             
                             // No connection?
                             if ([[CKServerManager sharedInstance] noConnectionError:error]) {
                                 [ViewHelper showNoConnectionCard:YES view:self.view center:[self noConnectionCardCenter]];
                             }
                             
                         }];
    } else {
        
        // Load login book.
        [CKBook fetchGuestBookSuccess:^(CKBook *guestBook) {
            
            if (self.myBook) {
                self.myBook = guestBook;
                
                // Insert book then update blended benchtop.
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]]];
                } completion:^(BOOL finished) {
                    [self updatePagingBenchtopView];
                }];
                
            } else {
                
                [[self pagingLayout] markLayoutDirty];
                self.myBook = guestBook;
                
                // Insert book then update blended benchtop.
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]]];
                } completion:^(BOOL finished) {
                    
                    // No need to reblend, as layoutDidGenerate will trigger it.
                    
                    // First time launch.
                    if ([self.delegate respondsToSelector:@selector(benchtopFirstTimeLaunched)]) {
                        [self.delegate benchtopFirstTimeLaunched];
                    }
                    
                }];

            }
            
            // Sample a snapshot.
            [self snapshotBenchtop];
            
        } failure:^(NSError *error) {
            
            // No connection?
            if ([[CKServerManager sharedInstance] noConnectionError:error]) {
                [ViewHelper showNoConnectionCard:YES view:self.view center:[self noConnectionCardCenter]];
            }
        }];
        
    }
    
}

- (void)loadFollowBooks {
    [self loadFollowBooksReload:NO];
}

- (void)loadFollowBooksReload:(BOOL)reload {
    
    [CKBook fetchFollowBooksSuccess:^(NSArray *followBooks) {
        self.followBooks = [NSMutableArray arrayWithArray:followBooks];
        NSArray *indexPathsToInsert = [self indexPathsForFollowBooks];
        
        if (reload) {
            [[self pagingLayout] markLayoutDirty];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
        } else {
            [[self pagingLayout] markLayoutDirty];
            [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
        }
        
        // Sample a snapshot.
        [self snapshotBenchtop];
        
    } failure:^(NSError *error) {
        DLog(@"Error: %@", [error localizedDescription]);
        
        // No connection?
        if ([[CKServerManager sharedInstance] noConnectionError:error]) {
            [ViewHelper showNoConnectionCard:YES view:self.view center:[self noConnectionCardCenter]];
        }
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
    [myBookCell enableEditMode:enable];
    
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
                         
                         if (enable) {
                             
                             // Clear the blended benchtop.
                             [self clearPagingBenchtopView];
                             
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
    
    [[self pagingLayout] markLayoutDirty];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexPath.item inSection:indexPath.section]]];
    } completion:^(BOOL finished) {
    }];
    
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
    
    // Cannot open guest book.
    if (book.guest) {
        return;
    }
    
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
        
        [self hideLoginViewCompletion:^{
            [self loadMyBook];
            [self loadFollowBooksReload:YES];
        }];
        
        // Clear the sign up image.
        self.signupBlurImage = nil;
        
    }
}

- (void)loggedOut:(NSNotification *)notification {
    
    // Reload benchtop.
    [self loadMyBook];
    [self loadFollowBooksReload:YES];
}

- (void)themeChanged:(NSNotification *)notification {
    [self updatePagingBenchtopView];
}

- (void)updatePagingBenchtopView {
    DLog();
    
    // Create a new blended benchtop with the current layout.
    PagingBenchtopBackgroundView *pagingBenchtopView = [self createPagingBenchtopBackgroundView];
    
    // Blend it and update the benchtop.
    [pagingBenchtopView blendWithCompletion:^{
        
        // Updates contentSize to new blended benchtop.
        self.backdropScrollView.contentSize = pagingBenchtopView.frame.size;
        self.backdropScrollView.contentOffset = (CGPoint){
            -((self.collectionView.bounds.size.width - kBlendPageWidth) / 2.0),
            0.0
        };
        
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
                                 self.pagingBenchtopView.alpha = kBlendMaxAlpha;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        
    }];
    
}

- (void)clearPagingBenchtopView {
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.pagingBenchtopView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.pagingBenchtopView removeFromSuperview];
                         self.pagingBenchtopView = nil;
                     }];
}

- (PagingBenchtopBackgroundView *)createPagingBenchtopBackgroundView {
    
    NSInteger numMyBook = [self.collectionView numberOfItemsInSection:kMyBookSection];
    NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
    
    PagingBenchtopBackgroundView *pagingBenchtopView = [[PagingBenchtopBackgroundView alloc] initWithFrame:(CGRect){
        self.backdropScrollView.bounds.origin.x,
        self.backdropScrollView.bounds.origin.y,
//        self.collectionView.bounds.size.width * (numMyBook + 1 + numFollowBooks),
        kBlendPageWidth * (numMyBook + 1 + numFollowBooks),
        self.backgroundTextureView.frame.size.height
    } pageWidth:kBlendPageWidth];
    
    // Loop through and add colours.
    NSInteger numSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numSections; section++) {
        
        if (section == kMyBookSection) {
            
            if (self.myBook) {
                [pagingBenchtopView addColour:[CKBookCover themeBackdropColourForCover:self.myBook.cover]];
            }
            
        } else if (section == kFollowSection) {
            
            // Add white for gap.
            // [pagingBenchtopView addColour:[UIColor colorWithRed:255 green:0 blue:255 alpha:0.5]];
            // [pagingBenchtopView addColour:[UIColor whiteColor]];
            
            NSInteger numFollowBooks = [self.collectionView numberOfItemsInSection:kFollowSection];
            for (NSInteger followIndex = 0; followIndex < numFollowBooks; followIndex++) {
                
                CKBook *book = [self.followBooks objectAtIndex:followIndex];
                UIColor *bookColour = [CKBookCover themeBackdropColourForCover:book.cover];
                
                // Add the next book colour at the gap.
                if (followIndex == 0) {
                    
                    // Extract components to reset alpha
                    CGFloat red, green, blue, alpha;
                    [bookColour getRed:&red green:&green blue:&blue alpha:&alpha];
                    // [pagingBenchtopView addColour:[UIColor colorWithRed:red green:green blue:blue alpha:0.1]];
                    
                    [pagingBenchtopView addColour:bookColour];
                }
                
                [pagingBenchtopView addColour:bookColour];
            }
            
        }
    }
    
    // Initialise as max alpha.
    pagingBenchtopView.alpha = kBlendMaxAlpha;
    
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

- (void)processPagingFade {
    
    CGRect visibleFrame = [ViewHelper visibleFrameForCollectionView:self.collectionView];
    CGPoint visibleCenter = (CGPoint){ CGRectGetMidX(visibleFrame), CGRectGetMidY(visibleFrame) };
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:visibleCenter];
    if (indexPath) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            
            CGFloat distance = ABS(cell.center.x - visibleCenter.x);
            CGFloat effectiveDistance = 300.0 / 2.0;
            CGFloat fadeAlpha = 1.0 - MIN(distance, effectiveDistance) / effectiveDistance;
//            fadeAlpha = MAX(0.5, fadeAlpha);
            fadeAlpha = MAX(kBlendMinAlpha, fadeAlpha);
            fadeAlpha = MIN(fadeAlpha, kBlendMaxAlpha);

//            DLog(@"FADE ALPHA %f", fadeAlpha);
            self.pagingBenchtopView.alpha = fadeAlpha;
            
        }
    }
}

- (void)showNotificationsOverlay:(BOOL)show {
    [self.delegate panEnabledRequested:!show];
    if (show) {
        self.notificationsViewController = [[NotificationsViewController alloc] initWithDelegate:self];
        [ModalOverlayHelper showModalOverlayForViewController:self.notificationsViewController show:YES
                                                    animation:^{
                                                        [self enable:NO animated:YES];
                                                    } completion:nil];
    } else {
        [ModalOverlayHelper hideModalOverlayForViewController:self.notificationsViewController
                                                    animation:^{
                                                        [self enable:YES animated:NO];
                                                    } completion:^{
                                                        self.notificationsViewController = nil;
                                                    }];
    }
    
}

- (CGPoint)noConnectionCardCenter {
    return (CGPoint) {
        floorf(self.view.bounds.size.width / 2.0),
        100.0
    };
}

- (void)didBecomeInactive {
    DLog();
}

- (void)didBecomeActive {
    DLog();
}

- (void)snapshotBenchtop {
    [ImageHelper blurredImageFromView:self.view completion:^(UIImage *blurredImage) {
        self.signupBlurImage = blurredImage;
    }];
}

@end
