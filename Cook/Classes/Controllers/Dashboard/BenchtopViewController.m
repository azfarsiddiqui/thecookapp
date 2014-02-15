//
//  PagingBenchtopViewController.m
//  CKPagingBenchtopDemo
//
//  Created by Jeff Tan-Ang on 8/06/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BenchtopViewController.h"
#import "PagingCollectionViewLayout.h"
#import "BenchtopBookCoverViewCell.h"
#import "SignUpBookCoverViewCell.h"
#import "EventHelper.h"
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
#import "CardViewHelper.h"
#import "CKNavigationController.h"
#import "CKBookManager.h"
#import "RootViewController.h"
#import "FollowReloadButtonView.h"
#import "NSString+Utilities.h"
#import "AnalyticsHelper.h"

@interface BenchtopViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
    UIGestureRecognizerDelegate, PagingCollectionViewLayoutDelegate, CKNotificationViewDelegate,
    BenchtopBookCoverViewCellDelegate, SignUpBookCoverViewCellDelegate, SignupViewControllerDelegate,
    CoverPickerViewControllerDelegate, IllustrationPickerViewControllerDelegate, NotificationsViewControllerDelegate,
    CKNavigationControllerDelegate, FollowReloadButtonViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundTextureView;
@property (nonatomic, strong) PagingBenchtopBackgroundView *pagingBenchtopView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *backdropScrollView;
@property (nonatomic, strong) CKNotificationView *notificationView;
@property (nonatomic, strong) UIImageView *overlayView;
@property (nonatomic, strong) UIImageView *vignetteView;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImage *signupBlurImage;
@property (nonatomic, strong) FollowReloadButtonView *followReloadView;

@property (nonatomic, strong) CoverPickerViewController *coverViewController;
@property (nonatomic, strong) IllustrationPickerViewController *illustrationViewController;
@property (nonatomic, strong) SignupViewController *signUpViewController;
@property (nonatomic, strong) NotificationsViewController *notificationsViewController;
@property (nonatomic, strong) CKNavigationController *cookNavigationController;

@property (nonatomic, strong) CKBook *myBook;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, strong) NSMutableArray *followBooks;
@property (nonatomic, strong) NSMutableDictionary *followBookUpdates;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL deleteMode;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL dashboardBooksLoading;
@property (nonatomic, assign) BOOL newUser;
@property (nonatomic, strong) NSString *preEditingBookName;
@property (nonatomic, strong) NSString *preEditingAuthorName;

@property (nonatomic, assign) CGPoint previousScrollPosition;
@property (nonatomic, assign) BOOL forwardDirection;

@property (nonatomic, strong) UIView *libraryIntroView;
@property (nonatomic, strong) UIView *settingsIntroView;
@property (nonatomic ,strong) UIView *updateIntroView;

@end

@implementation BenchtopViewController

#define kCellId             @"CellId"
#define kSignUpCellId       @"SignUpCellId"
#define kCellSize           CGSizeMake(300.0, 438.0)
#define kSideMargin         362.0
#define kMyBookSection      0
#define kFollowSection      1
#define kPagingRate         2.0
#define kBlendPageWidth     1024.0
#define kHasSeenUpdateIntro @"HasSeen1.3"
#define kHasSeenDashArrow   @"HasSeenArrows1.3"
#define kContentInsets      (UIEdgeInsets){ 30.0, 25.0, 50.0, 15.0 }

- (void)dealloc {
    [EventHelper unregisterFollowUpdated:self];
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
    [EventHelper unregisterThemeChange:self];
    [EventHelper unregisterDashFetch:self];
    
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
    
    self.currentUser = [CKUser currentUser];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initBackground];
    [self initCollectionView];
    [self initNotificationView];
    
    if ([CKUser isLoggedIn]) {
        [self loadBenchtop];
    }
    
    [EventHelper registerFollowUpdated:self selector:@selector(followUpdated:)];
    [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
    [EventHelper registerThemeChange:self selector:@selector(themeChanged:)];
    [EventHelper registerDashFetch:self selector:@selector(dashFetch:)];
    
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

- (void)loadBenchtop {
    [self loadBenchtopBackgroundFetch:NO];
}

- (void)loadBenchtopBackgroundFetch:(BOOL)isBackground {
    
    // Re-enable if it's not background.
    if (!isBackground) {
        [self enable:YES];
    }

    [self loadBooksBackgroundFetch:isBackground];
    [self.delegate benchtopLoaded];
}

- (void)showLoginViewSignUp:(BOOL)signUp {
    
    // Ignore in editMode.
    if (self.editMode) {
        return;
    }
    
    // Make sure we're on the front page.
    [self.collectionView setContentOffset:CGPointZero animated:YES];
    
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
                         if (!self.updateIntroView)
                         {
                             [self.delegate panEnabledRequested:YES];
                         }
                         completion();
                     }];
}

// Updates the book on the dash with the one that got refreshed via book loading.
- (void)refreshBook:(CKBook *)book {
    
    if ([book.objectId isEqualToString:self.myBook.objectId]) {
        DLog(@"Refreshed my book [%@]", book.objectId);
        self.myBook = book;
    } else {
        NSInteger followBookIndex = [self.followBooks findIndexWithBlock:^BOOL(CKBook *followBook) {
            return [followBook.objectId isEqualToString:book.objectId];
        }];
        if (followBookIndex != -1) {
            DLog(@"Refreshed follow book [%@]", book.objectId);
            [self.followBooks replaceObjectAtIndex:followBookIndex withObject:book];
        }
    }
    
}

#pragma mark - BenchtopViewController methods

- (void)enable:(BOOL)enable {
    [self enable:enable animated:NO];
}

- (void)enable:(BOOL)enable animated:(BOOL)animated {
    self.collectionView.userInteractionEnabled = enable;
    self.notificationView.userInteractionEnabled = enable;
    [self hideIntroViewsAsRequired];
}

- (void)bookAboutToClose
{
    //Hide cells right before close animation so they can fade in nicely
    //Part of the workaround for wierd device lock->missing cells issue
    [self showVisibleBooks:NO];
}

- (void)bookWillOpen:(BOOL)open {
    
    // Make sure book closes down on the book as indicated by selectedIndexPath.
    if (!open && self.selectedIndexPath) {
        [self scrollToBookAtIndexPath:self.selectedIndexPath animated:NO];
    }
    
    BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:self.selectedIndexPath];
    cell.bookCoverView.hidden = YES;
    [self showBookCell:cell show:!open];
    self.notificationView.alpha = open ? 0.0 : 1.0;
    
}

- (void)bookDidOpen:(BOOL)open {
    
    // Restore the bookCover.
    BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:self.selectedIndexPath];
    if (!open) {
        
        // Reset selectedIndexPath.
        self.selectedIndexPath = nil;
        
        cell.bookCoverView.hidden = NO;
        [cell.bookCoverView enable:YES];
        [self.delegate benchtopShowOtherViews];
    } else {
        [self clearUpdatesForBook:cell.bookCoverView.book];
        [cell.bookCoverView clearUpdates];
        
        // Reenable cells in dashboard to prevent wierd device lock->missing cells issue
        cell.bookCoverView.hidden = NO;
        [self showBookCell:cell show:YES];
        [self.delegate benchtopHideOtherViews];
    }
    
    // Enable panning based on book opened or not.
    [self.delegate panEnabledRequested:!open];
}

- (void)showVisibleBooks:(BOOL)show
{
    NSArray *visibleCells = [self.collectionView visibleCells];
    [visibleCells each:^(UICollectionViewCell *cell) {
        cell.alpha = show ? 1.0 : 0.0;
    }];
    self.notificationView.alpha = show ? 1.0 : 0.0;
    if (show) {
        [self.delegate benchtopShowOtherViews];
    } else {
        [self.delegate benchtopHideOtherViews];
    }
}

#pragma mark - FollowReloadButtonViewDelegate methods

- (void)followReloadButtonViewTapped {
    [self loadFollowBooks];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Update the backdrop.
    if (scrollView == self.collectionView) {
        
        [self synchronisePagingBenchtopView];
        
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
//    DLog(@"numItems [%d]", numItems);
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCoverViewCell *cell = nil;
    
    if (![self.currentUser isSignedIn] && indexPath.section == kMyBookSection) {
        cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kSignUpCellId forIndexPath:indexPath];
    } else {
        cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    }
    cell.delegate = self;
    
    if (indexPath.section == kMyBookSection) {
        [cell loadBook:self.myBook];
        
    } else if (indexPath.section == kFollowSection) {
        CKBook *book = [self.followBooks objectAtIndex:indexPath.item];
        
        if (![self.currentUser isSignedIn]) {
            [cell loadBook:book];
        } else if ([self.followBookUpdates objectForKey:book.objectId]) {
            [cell loadBook:book updates:[self updatesForBook:book]];
        } else {
            [cell loadBook:book updates:0 isNew:YES];
        }
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
        
        [self openBookAtIndexPath:indexPath];
        
    } else {
        
        // Scroll to the books.
        [self scrollToBookAtIndexPath:indexPath];
        
    }
    
}

#pragma mark - CKNavigationControllerDelegate methods

- (void)cookNavigationControllerCloseRequested {
    if (self.notificationsViewController) {
        [self showNotificationsOverlay:NO];
    }
}

#pragma mark - CKPagingCollectionViewLayoutDelegate methods

- (BOOL)pagingLayoutFollowsDidLoad {
    return (self.followBooks != nil);
}

- (void)pagingLayoutDidUpdate {
    
    // Update blurring backdrop only in non-edit mode.
    if (!self.editMode) {
        [self updatePagingBenchtopView];
    }
}

#pragma mark - CKNotificationViewDelegate methods

- (void)notificationViewTapped {
    
    if ([self.currentUser isSignedIn]) {
        [self showNotificationsOverlay:YES];
    }
    
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Recognise dismiss taps only when collectionView is disabled.
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
        
        // Update benchtop snapshot.
        [self snapshotBenchtop];
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
    self.myBook.name = self.preEditingBookName;
    self.myBook.author = self.preEditingAuthorName;
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
}

- (void)coverPickerSelected:(NSString *)cover {
    
    // Force reload my book with the selected illustration.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.name = cell.bookCoverView.nameValue;
    self.myBook.author = cell.bookCoverView.authorValue;
    self.myBook.cover = cover;
    [cell loadBook:self.myBook];
    
    // Reload the illustration covers.
    [self.illustrationViewController changeCover:cover];
}

#pragma mark - IllustrationPickerViewControllerDelegate methods

- (void)illustrationSelected:(NSString *)illustration {
    
    // Force reload my book with the selected illustration.
    BenchtopBookCoverViewCell *cell = [self myBookCell];
    self.myBook.name = cell.bookCoverView.nameValue;
    self.myBook.author = cell.bookCoverView.authorValue;
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

// Overriden to hold the same reference in CKBookManager.
- (void)setMyBook:(CKBook *)myBook {
    _myBook = myBook;
    if (myBook) {
        [[CKBookManager sharedInstance] holdMyCurrentBook:myBook];
    }
}

- (FollowReloadButtonView *)followReloadView {
    if (!_followReloadView) {
        _followReloadView = [[FollowReloadButtonView alloc] initWithDelegate:self];
    }
    return _followReloadView;
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
}

- (void)initCollectionView {
    PagingCollectionViewLayout *pagingLayout = [[PagingCollectionViewLayout alloc] initWithDelegate:self];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:pagingLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delaysContentTouches = NO;
    
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
    
    // Follow books activity view on first follow book location.
    self.followReloadView.frame = (CGRect){
        self.collectionView.bounds.size.width - 62.0 + floorf(([BenchtopBookCoverViewCell cellSize].width - self.followReloadView.frame.size.width) / 2.0),
        floorf((self.collectionView.bounds.size.height - self.followReloadView.frame.size.height) / 2.0),
        self.followReloadView.frame.size.width,
        self.followReloadView.frame.size.height
    };
    self.followReloadView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.collectionView addSubview:self.followReloadView];
}

- (void)initNotificationView {
    CKNotificationView *notificationView = [[CKNotificationView alloc] initWithDelegate:self];
    notificationView.frame = CGRectMake(18.0, 33.0, notificationView.frame.size.width, notificationView.frame.size.height);
    [self.view addSubview:notificationView];
    self.notificationView = notificationView;
    self.notificationView.hidden = ![self.currentUser isSignedIn];
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
                
                if ([self isCenterBookAtIndexPath:indexPath]) {
                    
                    // Enable delete only in the center.
                    if ([self.currentUser isSignedIn]) {
                        [self enableDeleteMode:YES indexPath:indexPath];
                    }
                    
                } else {
                    
                    // Else just scroll there.
                    [self scrollToBookAtIndexPath:indexPath];
                }
                
            }
        }
    }
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    [self.delegate panToBenchtopForSelf:self];
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
                         self.libraryIntroView.alpha = enable ? 0.0 : 1.0;
                         self.settingsIntroView.alpha = enable ? 0.0 : 1.0;
                         
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

- (void)loadBooks {
    [self loadBooksBackgroundFetch:NO];
}

- (void)loadBooksBackgroundFetch:(BOOL)backgroundFetch {
    [self loadBooksBackgroundFetch:backgroundFetch completion:nil];
}

- (void)loadBooksBackgroundFetch:(BOOL)backgroundFetch completion:(void (^)())completion {
    
    // Hide any no connection messages.
    [[CardViewHelper sharedInstance] hideNoConnectionCardInView:self.view];
    
    // Load my book and follow books.
    [self loadMyBookBackgroundFetch:backgroundFetch];
    [self loadDashboardBooksBackgroundFetch:backgroundFetch completion:completion];
}

- (void)loadMyBookBackgroundFetch:(BOOL)backgroundFetch {
    
    // Bypass background fetch.
    if (backgroundFetch) {
        return;
    }
    
    CKUser *currentUser = [CKUser currentUser];
    if (currentUser) {
        
        // Signed in, attempt to load from cache. We ignore actual book from the network as dashboardBooks handles that.
        [CKBook dashboardBookForUser:currentUser
                             success:^(CKBook *book, BOOL hasCachedResult) {
                                 
                                 // Only process if we have no book set.
                                 if (!self.myBook) {
                                     
                                     NSInteger existingRows = [self.collectionView numberOfItemsInSection:kMyBookSection];
                                     
                                     // Existing user logging in fresh from new install (cache miss).
                                     [[self pagingLayout] markLayoutDirty];
                                     self.myBook = book;
                                     
                                     // Insert book then update blended benchtop.
                                     [self.collectionView performBatchUpdates:^{
                                         
                                         NSIndexPath *myBookIndexPath = [NSIndexPath indexPathForItem:0 inSection:kMyBookSection];
                                         if (existingRows > 0) {
                                             [self reloadBookAtIndexPath:myBookIndexPath];
                                         } else {
                                             [self.collectionView insertItemsAtIndexPaths:@[myBookIndexPath]];
                                         }
                                         
                                     } completion:^(BOOL finished) {
                                         
                                     }];
                                     
                                 }
                                 
                             }
                             failure:^(NSError *error) {
                                 DLog(@"Error: %@", [error localizedDescription]);
                             }];
    } else {
        
        // Load login book.
        [CKBook dashboardGuestBookSuccess:^(CKBook *guestBook) {
            
            // Logged out and log back in.
            if (self.myBook) {
                self.myBook = guestBook;
                
                // Reload book then update blended benchtop.
                NSInteger existingRows = [self.collectionView numberOfItemsInSection:kMyBookSection];
                [[self pagingLayout] markLayoutDirty];
                [self.collectionView performBatchUpdates:^{
                    
                    NSIndexPath *myBookIndexPath = [NSIndexPath indexPathForItem:0 inSection:kMyBookSection];
                    if (existingRows > 0) {
                        [self reloadBookAtIndexPath:myBookIndexPath];
                    } else {
                        [self.collectionView insertItemsAtIndexPaths:@[myBookIndexPath]];
                    }
                    
                } completion:^(BOOL finished) {
                    
                    // Show the arrows again.
                    [self flashIntros];
                    
                }];
                
            } else {
                
                [[self pagingLayout] markLayoutDirty];
                self.myBook = guestBook;
                
                // Insert book then update blended benchtop.
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]]];
                } completion:^(BOOL finished) {
                    
                    // First time launch.
                    if ([self.delegate respondsToSelector:@selector(benchtopFirstTimeLaunched)]) {
                        [self.delegate benchtopFirstTimeLaunched];
                        [self flashIntros];
                    }
                    
                }];
                
            }
            
        } failure:^(NSError *error) {
            
            // Only show no connection card if non-background fetch mode.
            if (!backgroundFetch) {
                if ([[CKServerManager sharedInstance] noConnectionError:error]) {
                    [[CardViewHelper sharedInstance] showNoConnectionCard:YES view:self.view center:[self noConnectionCardCenter]];
                }
            }
            
        }];
        
    }
}

- (void)loadFollowBooks {
    [self loadDashboardBooksBackgroundFetch:NO];
}

- (void)loadDashboardBooksBackgroundFetch:(BOOL)backgroundFetch {
    [self loadDashboardBooksBackgroundFetch:backgroundFetch completion:nil];
}

- (void)loadDashboardBooksBackgroundFetch:(BOOL)backgroundFetch completion:(void (^)())completion {
    
    // Hide any no connection messages.
    [[CardViewHelper sharedInstance] hideNoConnectionCardInView:self.view];
    
   // Enable pan to Settings and Store except when update screen is active
    if (self.updateIntroView.alpha == 0.0) {
        [self.delegate panEnabledRequested:YES];
    }
    
    if (self.dashboardBooksLoading) {
        DLog(@"Follow books loading in progress, returning.");
        return;
    }
    self.dashboardBooksLoading = YES;
    DLog(@"Loading dashboard books, backgroundFetch[%@]", [NSString CK_stringForBoolean:backgroundFetch]);
    
    // Existing number of follow books.
    NSInteger existingNumFollows = [self.collectionView numberOfItemsInSection:kFollowSection];
    
    // Spin the spinner if there were no books.
    if (existingNumFollows == 0) {
        [self.followReloadView enableActivity:YES];
    }
    
    // Get all dashboard books.
    [CKBook dashboardBooksForUser:self.currentUser success:^(CKBook *myBook, NSArray *followBooks, NSDictionary *followBookUpdates) {
        
        // Stop spinner but don't show reload button.
        [self.followReloadView enableActivity:NO hideReload:YES];
        
        // My book.
        if (self.currentUser) {
            self.myBook = myBook;
        }
        
        // Followed books.
        self.followBooks = [NSMutableArray arrayWithArray:followBooks];
        self.followBookUpdates = [NSMutableDictionary dictionaryWithDictionary:followBookUpdates];
        NSArray *indexPathsForFollowBooksToInsert = [self indexPathsForFollowBooks];
        
        [[self pagingLayout] markLayoutDirty];
        [self.collectionView performBatchUpdates:^{
            
            // My book.
            if (self.currentUser && self.myBook) {
                NSIndexPath *myBookIndexPath = [NSIndexPath indexPathForItem:0 inSection:kMyBookSection];
                NSInteger existingNumMyBooks = [self.collectionView numberOfItemsInSection:kMyBookSection];
                if (existingNumMyBooks > 0) {
                    [self reloadBookAtIndexPath:myBookIndexPath];
                } else {
                    [self.collectionView insertItemsAtIndexPaths:@[myBookIndexPath]];
                }
            }
            
            // Follow books.
            if (existingNumFollows > 0) {
                [self reloadFollowBooksSkipMyBook:YES];
            } else {
                [self.collectionView insertItemsAtIndexPaths:indexPathsForFollowBooksToInsert];
            }
            
        } completion:^(BOOL finished) {
            
            // Mark as not loading follow books anymore.
            self.dashboardBooksLoading = NO;
            
            if (completion != nil) {
                completion();
            }
            
        }];

    } failure:^(NSError *error) {
        DLog(@"Error: %@", [error localizedDescription]);
        
        // Show reload.
        [self.followReloadView enableActivity:NO];
        
        // Only show no connection card if non-background fetch mode.
        if (!backgroundFetch) {
            if ([[CKServerManager sharedInstance] noConnectionError:error]) {
                [[CardViewHelper sharedInstance] showNoConnectionCard:YES view:self.view center:[self noConnectionCardCenter]];
            }
        }
        
        // Mark as not loading follow books anymore.
        self.dashboardBooksLoading = NO;
        
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
    
    // Remember the original state of the book before editing.
    self.preEditingAuthorName = myBookCell.bookCoverView.authorValue;
    self.preEditingBookName = myBookCell.bookCoverView.nameValue;
    
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
                         
                         // Hide the intro views.
                         self.libraryIntroView.alpha = enable ? 0.0 : 1.0;
                         self.settingsIntroView.alpha = enable ? 0.0 : 1.0;
                         
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
                             
                             // Clear the editing na
                             self.preEditingAuthorName = nil;
                             self.preEditingBookName = nil;
                             
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
        // Do nothing on delete.
    }];
    
    // Unfollow in the background, then inform listeners of the update.
    [book removeFollower:currentUser
                 success:^{
                     
                     [AnalyticsHelper trackEventName:kEventBookDelete];
                     [EventHelper postFollow:NO book:book];
                     
                     // Clear the book updates.
                     [self.followBookUpdates removeObjectForKey:book.objectId];
                     
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
    
    // Cannot open guest or disabled book.
    if (book.guest || book.disabled) {
        return;
    }
    
    // Remember selected book's indexPath.
    self.selectedIndexPath = indexPath;
    
    CGFloat bookScale = 0.98;
    BenchtopBookCoverViewCell *cell = [self bookCellAtIndexPath:indexPath];
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [cell.bookCoverView enable:NO animated:NO];
                         cell.transform = CGAffineTransformMakeScale(bookScale, bookScale);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              cell.transform = CGAffineTransformIdentity;
                                          }
                                          completion:^(BOOL finished){
                                              CGPoint centerPoint = cell.contentView.center;
                                              [self.delegate openBookRequestedForBook:book centerPoint:centerPoint];
                                              if ([self.followBookUpdates objectForKey:book.objectId] == nil) {
                                                  [self.followBookUpdates setObject:@0 forKey:book.objectId];
                                              }
                                          }];
                     }];
    
}

- (void)scrollToBookAtIndexPath:(NSIndexPath *)indexPath {
    [self scrollToBookAtIndexPath:indexPath animated:YES];
}

- (void)scrollToBookAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    CGPoint requiredOffset = CGPointZero;
    CGSize cellSize = [BenchtopBookCoverViewCell cellSize];
    if (indexPath.section == kFollowSection) {
        requiredOffset.x += floorf(kSideMargin + (cellSize.width * 2.0) + (indexPath.item * cellSize.width) - (self.collectionView.bounds.size.width / 2.0) + (cellSize.width / 2.0));
    }
    
    [self.collectionView setContentOffset:requiredOffset animated:animated];
}

- (void)followUpdated:(NSNotification *)notification {
    
    CKBook *book = [EventHelper bookFollowForNotification:notification];
    BOOL follow = [EventHelper followForNotification:notification];
    if (follow) {
        
        if (![self.followBooks detect:^BOOL(CKBook *existingBook) {
            return [book.objectId isEqualToString:existingBook.objectId];
        }]) {
            
            [[self pagingLayout] markLayoutDirty];
            [[self pagingLayout] enableFollowMode:YES];
            
            // Prepend to the followed books.
            [self.followBooks insertObject:book atIndex:0];
            
            [self.collectionView performBatchUpdates:^{
                
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kFollowSection]]];
                
            } completion:^(BOOL finished) {
                
                // If the book was opened, bump the index of the selectecIndexPath.
                if (self.selectedIndexPath) {
                    self.selectedIndexPath = [NSIndexPath indexPathForItem:self.selectedIndexPath.item + 1
                                                                 inSection:self.selectedIndexPath.section];
                    
                    // Make sure book is centered.
                    [self scrollToBookAtIndexPath:self.selectedIndexPath animated:NO];
                }
                
                [[self pagingLayout] enableFollowMode:NO];
                [self.collectionView reloadData];
            }]; 
        }
    }
}

- (void)loggedIn:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    self.newUser = [EventHelper loginSuccessfulNewUserForNotification:notification];
    
    if (success) {
        
        // Clear blur image.
        self.signupBlurImage = nil;
        
        // Delete current book then reload.
        [self deleteMyBookCompletion:^{
            
            // If we have sign in page, then hide it and perform insertion animation.
            if (self.signUpViewController) {
                
                [self hideLoginViewCompletion:^{
                    [self deleteFollowBooks];
                    [self loadBooks];
                }];
                
            } else {
                [self deleteFollowBooks];
                [self loadBooks];
            }
            
        }];
        
        // Show notification view.
        self.notificationView.hidden = NO;
        
        // Reset the current user.
        self.currentUser = [CKUser currentUser];
        
    }
}

- (void)loggedOut:(NSNotification *)notification {
    
    // Clear the current user
    self.currentUser = nil;
    self.newUser = NO;
    
    // Hide notification view.
    self.notificationView.hidden = YES;
    
    // Reload benchtop.
    [self clearDashCompletion:^{
        
        [self.delegate benchtopLoggedOutCompletion:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView setContentOffset:CGPointZero animated:NO];
                [self loadBooks];
            });
                
        }];
        
    }];
        
}

- (void)themeChanged:(NSNotification *)notification {
    [self updatePagingBenchtopView];
}

- (void)dashFetch:(NSNotification *)notification {
    BOOL backgroundMode = [EventHelper isBackgroundForDashFetch:notification];
    [self loadBenchtopBackgroundFetch:backgroundMode];
}

- (void)updatePagingBenchtopView {
    DLog();
    
    // No blending in edit mode.
    if (self.editMode) {
        return;
    }
    
    // Create a new blended benchtop with the current layout.
    PagingBenchtopBackgroundView *pagingBenchtopView = [self createPagingBenchtopBackgroundView];
    
    if ([self.pagingBenchtopView isEqual:pagingBenchtopView]) {
        [self synchronisePagingBenchtopView];
        [self snapshotBenchtop];
    } else {
        
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
                
                // Magic blend numbers to achieve as best blending as possible between the two.
                pagingBenchtopView.alpha = 0.4;
                self.pagingBenchtopView.alpha = 0.5;
                [self.backdropScrollView insertSubview:pagingBenchtopView belowSubview:self.pagingBenchtopView];
                
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     pagingBenchtopView.alpha = [PagingBenchtopBackgroundView maxBlendAlpha];
                                     self.pagingBenchtopView.alpha = 0.0;
                                 }
                                 completion:^(BOOL finished) {
                                     [self.pagingBenchtopView removeFromSuperview];
                                     self.pagingBenchtopView = pagingBenchtopView;
                                     [self synchronisePagingBenchtopView];
                                     [self snapshotBenchtop];
                                 }];
                
            } else {
                self.pagingBenchtopView = pagingBenchtopView;
                self.pagingBenchtopView.alpha = 0.0;
                [self.backdropScrollView insertSubview:self.pagingBenchtopView belowSubview:self.backgroundTextureView];
                [self synchronisePagingBenchtopView];
                
                [UIView animateWithDuration:0.4
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     self.pagingBenchtopView.alpha = [PagingBenchtopBackgroundView maxBlendAlpha];
                                 }
                                 completion:^(BOOL finished) {
                                     [self snapshotBenchtop];
                                 }];
            }
            
        }];
    }
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
    NSInteger numFollowBooks = self.followBooks ? [self.followBooks count] : 1;
    
    PagingBenchtopBackgroundView *pagingBenchtopView = [[PagingBenchtopBackgroundView alloc] initWithFrame:(CGRect){
        0.0,
        0.0,
        kBlendPageWidth * (numMyBook + 1 + (numFollowBooks == 0 ? 1 : numFollowBooks)),
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
            
            
            if ([self pagingLayoutFollowsDidLoad]) {
                if (numFollowBooks > 0) {
                    
                    for (NSInteger followIndex = 0; followIndex < numFollowBooks; followIndex++) {
                        
                        CKBook *book = [self.followBooks objectAtIndex:followIndex];
                        UIColor *bookColour = [CKBookCover themeBackdropColourForCover:book.cover];
                        
                        // Add the next book colour at the gap.
                        if (followIndex == 0) {
                            
                            // Extract components to reset alpha
                            CGFloat red, green, blue, alpha;
                            [bookColour getRed:&red green:&green blue:&blue alpha:&alpha];
                            [pagingBenchtopView addColour:bookColour];
                            
                        }
                        
                        [pagingBenchtopView addColour:bookColour];
                    }
                    
                }
            }
            
        }
    }
    
    // Initialise as max alpha.
    pagingBenchtopView.alpha = [PagingBenchtopBackgroundView maxBlendAlpha];
    
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
                         self.libraryIntroView.alpha = show ? 1.0 : 0.0;
                         self.settingsIntroView.alpha = show ? 1.0 : 0.0;
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
            fadeAlpha = MAX([PagingBenchtopBackgroundView minBlendAlpha], fadeAlpha);
            fadeAlpha = MIN(fadeAlpha, [PagingBenchtopBackgroundView maxBlendAlpha]);

//            DLog(@"FADE ALPHA %f", fadeAlpha);
            self.pagingBenchtopView.alpha = fadeAlpha;
            
        }
    }
}

- (void)showNotificationsOverlay:(BOOL)show {
    [self.delegate panEnabledRequested:!show];
    if (show) {
        self.notificationsViewController = [[NotificationsViewController alloc] initWithDelegate:self];
        self.cookNavigationController = [[CKNavigationController alloc] initWithRootViewController:self.notificationsViewController
                                                                                          delegate:self];
        [ModalOverlayHelper showModalOverlayForViewController:self.cookNavigationController show:YES
                                                    animation:^{
                                                        self.notificationView.alpha = 0.0;
                                                        self.libraryIntroView.alpha = 0.0;
                                                        self.settingsIntroView.alpha = 0.0;
                                                    } completion:nil];
    } else {
        
        [ModalOverlayHelper hideModalOverlayForViewController:self.cookNavigationController
                                                    animation:^{
                                                        self.notificationView.alpha = 1.0;
                                                        self.libraryIntroView.alpha = 1.0;
                                                        self.settingsIntroView.alpha = 1.0;
                                                    } completion:^{
                                                        self.notificationsViewController = nil;
                                                        self.cookNavigationController = nil;
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
    [self snapshotBenchtopCompletion:nil];
}

- (void)snapshotBenchtopCompletion:(void (^)())completion {
    
    if (![self.currentUser isSignedIn] || ([self.currentUser isSignedIn] && ![self hasSeenUpdateIntro])) {
        [ImageHelper blurredImageFromView:self.view completion:^(UIImage *blurredImage) {
            self.signupBlurImage = blurredImage;
            if (completion != nil) {
                completion();
            }
        }];
    }
}

- (void)flashIntrosIfRequired {
    if (![self hasSeenDashArrows]) {
        [self flashIntros];
        [self markHasSeenDashArrows];
    }
}

- (void)flashIntros {
    CGFloat shiftOffset = 0.0;
    
    if (!self.libraryIntroView.superview) {
        self.libraryIntroView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_intro_popover_library.png"]];
        UITapGestureRecognizer *libraryTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(libraryIntroTapped)];
        [self.libraryIntroView addGestureRecognizer:libraryTapGesture];
        self.libraryIntroView.userInteractionEnabled = NO;
        self.libraryIntroView.alpha = 0.0;
        self.libraryIntroView.transform = CGAffineTransformMakeTranslation(0.0, -shiftOffset);
        CGRect libraryFrame = self.libraryIntroView.frame;
        libraryFrame.origin.x = floorf((self.view.bounds.size.width - libraryFrame.size.width) / 2.0);
        libraryFrame.origin.y = 31.0;
        self.libraryIntroView.frame = libraryFrame;
        [self.view addSubview:self.libraryIntroView];
    }
    
    if (!self.settingsIntroView.superview) {
        self.settingsIntroView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_intro_popover_setup.png"]];
        UITapGestureRecognizer *settingsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingsIntroTapped)];
        [self.settingsIntroView addGestureRecognizer:settingsTapGesture];
        self.settingsIntroView.userInteractionEnabled = NO;
        self.settingsIntroView.alpha = 0.0;
        self.settingsIntroView.transform = CGAffineTransformMakeTranslation(0.0, shiftOffset);
        CGRect settingsFrame = self.settingsIntroView.frame;
        settingsFrame.origin.x = floorf((self.view.bounds.size.width - settingsFrame.size.width) / 2.0);
        settingsFrame.origin.y = self.view.bounds.size.height - settingsFrame.size.height - 13.0;
        self.settingsIntroView.frame = settingsFrame;
        [self.view addSubview:self.settingsIntroView];
        
    }
    
    [UIView animateWithDuration:0.3
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.libraryIntroView.alpha = 1.0;
                         self.libraryIntroView.transform = CGAffineTransformIdentity;
                         self.settingsIntroView.alpha = 1.0;
                         self.settingsIntroView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         self.libraryIntroView.userInteractionEnabled = YES;
                         self.settingsIntroView.userInteractionEnabled = YES;
                     }];
}

- (void)flashUpdateIntro {
    
    if (!self.updateIntroView.superview) {
        self.updateIntroView = [[UIView alloc] initWithFrame:self.view.frame];
        self.updateIntroView.alpha = 0.0;
        
        // Blurred imageView to be hidden to start off with.
        UIImageView *blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        blurredImageView.image = self.signupBlurImage;
        blurredImageView.userInteractionEnabled = NO;
        [self.updateIntroView addSubview:blurredImageView];
        
        UIImageView *introImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_updatescreen_13"]];
        introImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        introImageView.userInteractionEnabled = NO;
        [self.updateIntroView addSubview:introImageView];
        
        // Top-left close button.
        UIButton *closeButton = [ViewHelper closeButtonLight:NO target:self selector:@selector(closeIntroTapped)];
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        closeButton.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top,
            closeButton.frame.size.width,
            closeButton.frame.size.height
        };
        [self.updateIntroView addSubview:closeButton];
        
        // Bottom Find out More and Continue buttons.
        UIButton *moreButton = [self updateIntroButtonWithText:@"FIND OUT MORE" textAlpha:0.7 target:self selector:@selector(updateIntroMoreTapped)];
        UIButton *continueButton = [self updateIntroButtonWithText:@"CONTINUE" textAlpha:0.7 target:self selector:@selector(updateIntroContinueTapped)];
        CGFloat buttonOffsetFromBottom = 145.0;
        CGFloat buttonOffset = -16.0;
        CGFloat buttonGap = 117.0;
        CGFloat requiredWidth = moreButton.frame.size.width + buttonGap + continueButton.frame.size.width;
        moreButton.frame = (CGRect){
            floorf((self.view.bounds.size.width - requiredWidth) / 2.0) + buttonOffset,
            self.view.bounds.size.height - buttonOffsetFromBottom,
            moreButton.frame.size.width,
            moreButton.frame.size.height
        };
        continueButton.frame = (CGRect){
            moreButton.frame.origin.x + moreButton.frame.size.width + buttonGap,
            self.view.bounds.size.height - buttonOffsetFromBottom,
            continueButton.frame.size.width,
            continueButton.frame.size.height
        };
        [self.updateIntroView addSubview:moreButton];
        [self.updateIntroView addSubview:continueButton];
        
        [self.view addSubview:self.updateIntroView];
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.updateIntroView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             self.signupBlurImage = nil;
                             [self.delegate panEnabledRequested:NO];
                             [self markHasSeenUpdateIntro];
                         }];
    }
}

- (void)libraryIntroTapped {
    if ([self.delegate respondsToSelector:@selector(benchtopPeekRequestedForStore)]) {
        [self.delegate benchtopPeekRequestedForStore];
    }
}

- (void)settingsIntroTapped {
    if ([self.delegate respondsToSelector:@selector(benchtopPeekRequestedForSettings)]) {
        [self.delegate benchtopPeekRequestedForSettings];
    }
}

- (void)closeIntroTapped {
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        self.updateIntroView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.delegate panEnabledRequested:YES];
        [self.updateIntroView removeFromSuperview];
    }];
}

- (void)hideIntroView:(UIView *)introView completion:(void (^)())completion {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         introView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [introView removeFromSuperview];
                     }];
}

- (void)hideIntroViewsAsRequired {
    
    if (self.libraryIntroView.superview && [self.delegate benchtopInLibrary]) {
        [ViewHelper removeViewWithAnimation:self.libraryIntroView completion:^{
            self.libraryIntroView = nil;
        }];
    }
    
    if (self.settingsIntroView.superview && [self.delegate benchtopInSettings]) {
        [ViewHelper removeViewWithAnimation:self.settingsIntroView completion:^{
            self.settingsIntroView = nil;
        }];
    }
}

- (void)synchronisePagingBenchtopView {
    
    // Keep track of direction of scroll.
    self.forwardDirection = self.collectionView.contentOffset.x > self.previousScrollPosition.x;
    self.previousScrollPosition = self.collectionView.contentOffset;
    
    if (self.collectionView.contentOffset.x < 0) {
        
        self.backdropScrollView.contentOffset = (CGPoint) {
            self.collectionView.contentOffset.x - ((self.collectionView.bounds.size.width - kBlendPageWidth) / 2.0),
            self.backdropScrollView.contentOffset.y
        };
        
    } else if (self.collectionView.contentOffset.x > self.collectionView.contentSize.width - self.collectionView.bounds.size.width) {
        
        self.backdropScrollView.contentOffset = (CGPoint) {
            (self.backdropScrollView.contentSize.width - self.backdropScrollView.bounds.size.width) + (self.collectionView.contentOffset.x - self.collectionView.contentSize.width + self.collectionView.bounds.size.width),
            self.backdropScrollView.contentOffset.y
        };
    
    } else  {
        
        self.backdropScrollView.contentOffset = (CGPoint) {
            self.collectionView.contentOffset.x * (kBlendPageWidth / 300.0) - ((self.collectionView.bounds.size.width - kBlendPageWidth) / 2.0),
            self.backdropScrollView.contentOffset.y
        };
        
    }
    
    [self processPagingFade];

}

- (NSInteger)updatesForBook:(CKBook *)book {
    return [[self.followBookUpdates objectForKey:book.objectId] integerValue];
}

- (void)clearUpdatesForBook:(CKBook *)book {
    [self.followBookUpdates setObject:@0 forKey:book.objectId];
}

- (UIButton *)updateIntroButtonWithText:(NSString *)text target:(id)target selector:(SEL)selector {
    return [self updateIntroButtonWithText:text textAlpha:1.0 target:target selector:selector];
}

- (UIButton *)updateIntroButtonWithText:(NSString *)text textAlpha:(CGFloat)textAlpha target:(id)target selector:(SEL)selector {

    // Soft shadow.
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05];
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    shadow.shadowBlurRadius = 3.0;
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Regular" size:24.0],
                                     NSForegroundColorAttributeName : [UIColor colorWithWhite:255 alpha:textAlpha],
                                     NSShadowAttributeName : shadow
                                     };
    NSAttributedString *textDisplay = [[NSAttributedString alloc] initWithString:text attributes:textAttributes];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setAttributedTitle:textDisplay forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    if (target && [target respondsToSelector:selector]) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    [button sizeToFit];
    return button;
}

- (void)updateIntroMoreTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://blog.thecookapp.com"]];
}

- (void)updateIntroContinueTapped {
    [self closeIntroTapped];
}

- (void)deleteMyBookCompletion:(void (^)())completion {
    if (self.myBook) {
        
        // Clear model.
        self.myBook = nil;
        
        // Clear UI.
        [[self pagingLayout] markLayoutDirty];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]]];
        } completion:^(BOOL finished) {
            completion();
        }];
        
    } else {
        if (completion != nil) {
            completion();
        }
    }
}

- (void)deleteFollowBooks {
    [self deleteFollowBooksCompletion:nil];
}

- (void)deleteFollowBooksCompletion:(void (^)())completion {
    
    if ([self.followBooks count] > 0) {
        
        // Assemble IPs to delete.
        NSArray *indexPathsToDelete = [self.followBooks collectWithIndex:^(CKBook *book, NSUInteger bookIndex) {
            return [NSIndexPath indexPathForItem:bookIndex inSection:kFollowSection];
        }];
        
        // Clear model.
        [self.followBooks removeAllObjects];
        self.followBooks = nil;
        
        // Clear UI.
        [[self pagingLayout] markLayoutDirty];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
        } completion:^(BOOL finished) {
            
            if (completion != nil) {
                completion();
            }
            
        }];
        
    }
    
}

- (void)clearDashCompletion:(void (^)())completion {
    
    NSMutableArray *indexPathsToDelete = [NSMutableArray new];
    
    // My book.
    if (self.myBook) {
        [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:0 inSection:kMyBookSection]];
        self.myBook = nil;
    }
    
    // Follow books.
    if ([self.followBooks count] > 0) {
        
        // Assemble IPs to delete.
        [indexPathsToDelete addObjectsFromArray:[self.followBooks collectWithIndex:^(CKBook *book, NSUInteger bookIndex) {
            return [NSIndexPath indexPathForItem:bookIndex inSection:kFollowSection];
        }]];
        
        // Clear model.
        [self.followBooks removeAllObjects];
        self.followBooks = nil;
    }

    // Clear UI.
    if ([indexPathsToDelete count] > 0) {
        [[self pagingLayout] markLayoutDirty];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
        } completion:^(BOOL finished) {
            if (completion != nil) {
                completion();
            }
            
        }];
    }
    
}

- (BOOL)hasSeenDashArrows {
    return ([[NSUserDefaults standardUserDefaults] objectForKey:kHasSeenDashArrow] != nil);
}

- (void)markHasSeenDashArrows {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kHasSeenDashArrow];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasSeenUpdateIntro {
    return ([[NSUserDefaults standardUserDefaults] objectForKey:kHasSeenUpdateIntro] != nil);
}

- (void)markHasSeenUpdateIntro {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kHasSeenUpdateIntro];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showUpdateNotesIfRequired {
    if (self.currentUser && !self.newUser && ![self hasSeenUpdateIntro]) {
        [self snapshotBenchtopCompletion:^{
            [self flashUpdateIntro];
        }];
    } else if (self.newUser) {
        
        // New user doesn't need to use update intro.
        [self markHasSeenUpdateIntro];
    }
}

- (void)reloadBookAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell && indexPath.section == kMyBookSection && self.myBook ) {
        [cell loadBook:self.myBook];
    } else if (cell && indexPath.section == kFollowSection && [self.followBooks count] > indexPath.item) {
        CKBook *followBook = [self.followBooks objectAtIndex:indexPath.item];
        [cell loadBook:followBook updates:[self updatesForBook:followBook]];
    }
}

- (void)reloadFollowBooks {
    [self reloadFollowBooksSkipMyBook:NO];
}

- (void)reloadFollowBooksSkipMyBook:(BOOL)skipMyBook {
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    if (skipMyBook) {
        visibleIndexPaths = [visibleIndexPaths reject:^BOOL(NSIndexPath *indexPath) {
            return (indexPath.section == kMyBookSection);
        }];
    }
    [visibleIndexPaths each:^(NSIndexPath *indexPath) {
        [self reloadBookAtIndexPath:indexPath];
    }];
    
}

@end
