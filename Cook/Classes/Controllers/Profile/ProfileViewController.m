//
//  ProfileViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 4/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ProfileViewController.h"
#import "CKUser.h"
#import "ModalOverlayHelper.h"
#import "EventHelper.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "CKActivityIndicatorView.h"
#import "CKBookSummaryView.h"
#import "CKPhotoManager.h"
#import "CKStoreBookCoverView.h"
#import "AnalyticsHelper.h"

@interface ProfileViewController () <CKStoreBookCoverViewDelegate, CKBookSummaryViewDelegate>

@property (nonatomic, strong) CKUser *user;
@property (nonatomic, weak) id<ProfileViewControllerDelegate> delegate;
@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) UIView *summaryContainerView;
@property (nonatomic, strong) CKNavigationController *cookNavigationController;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL fullImageLoaded;
@property (nonatomic, strong) CKStoreBookCoverView *bookCoverView;
@property (nonatomic, assign) BOOL dataLoaded;

//Background handlers for modal view, can't use ckNavigationController's convenience methods
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundImageTopShadowView;

@end

@implementation ProfileViewController

#define kBookViewContentInsets  (UIEdgeInsets){ 50.0, 100.0, 50.0, 50.0 }
#define kBookViewSize           (CGSize){ 840.0, 614.0 }
#define kBookSummaryGap         20.0
#define kOverlayAlpha           0.5

- (id)initWithUser:(CKUser *)user {
    return [self initWithUser:user delegate:nil];
}

- (id)initWithUser:(CKUser *)user delegate:(id<ProfileViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.user = user;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    
    if (self.cookNavigationController) {
        self.backButton = [ViewHelper addBackButtonToView:self.view light:YES target:self selector:@selector(backTapped:)];
        
        // Inherits the black overlay of navigation controller.
        self.view.backgroundColor = [UIColor clearColor];
        
    } else {
        
        self.closeButton = [ViewHelper addCloseButtonToView:self.view light:YES target:self selector:@selector(closeTapped:)];
        
        // Register tap.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDismissed:)];
        [self.view addGestureRecognizer:tapGesture];
        
        // Register photo loading events.
        [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
        
        [self loadData];
    }
    
    [self.view addSubview:self.summaryContainerView];
}

#pragma mark - CKBookSummaryViewDelegate methods

- (void)bookSummaryViewBookIsFollowed {
    [self.bookCoverView showFollowed];
}

- (void)bookSummaryViewBookIsPrivate {
    [self.bookCoverView showLocked];
}

- (void)bookSummaryViewBookIsDownloadable {
    [self.bookCoverView showDownloadable];
}

#pragma mark - CKStoreBookCoverViewDelegate methods

- (void)storeBookCoverViewAddRequested {
    [self followTapped];
}

#pragma mark - CKNavigationControllerSupport methods

- (void)cookNavigationControllerViewWillAppear:(NSNumber *)boolNumber {
    if (![boolNumber boolValue]) {
        [self.activityView stopAnimating];
        [self.cookNavigationController hideContext];
    }
}

- (void)cookNavigationControllerViewAppearing:(NSNumber *)boolNumber {
    if (![boolNumber boolValue]) {
        self.backButton.alpha = 0.0;
        self.summaryContainerView.alpha = 0.0;
    }
}

- (void)cookNavigationControllerViewDidAppear:(NSNumber *)boolNumber {
    if ([boolNumber boolValue]) {
        [self loadData];
        
        // Register photo loading events.
        [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
        
        // Fade in the back button.
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.backButton.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        
        // Register photo loading events.
        [EventHelper unregisterPhotoLoading:self];
        
        [self.cookNavigationController hideContext];
    }
}

#pragma mark - Properties

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        _activityView.frame = (CGRect){
            floorf((self.summaryContainerView.bounds.size.width - _activityView.frame.size.width) / 2.0),
            floorf((self.summaryContainerView.bounds.size.height - _activityView.frame.size.height) / 2.0),
            _activityView.frame.size.width,
            _activityView.frame.size.height
        };
        _activityView.hidesWhenStopped = YES;
    }
    return _activityView;
}

- (UIView *)summaryContainerView {
    if (!_summaryContainerView) {
        _summaryContainerView = [[UIView alloc] initWithFrame:(CGRect){
            floorf((self.view.bounds.size.width - kBookViewSize.width) / 2.0),
            floorf((self.view.bounds.size.height - kBookViewSize.height) / 2.0),
            kBookViewSize.width,
            kBookViewSize.height
        }];
        _summaryContainerView.backgroundColor = [UIColor clearColor];
        _summaryContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        
        // Box overlay.
        UIImage *overlayImage = [[UIImage imageNamed:@"cook_dash_library_selected_bg.png"] resizableImageWithCapInsets:(UIEdgeInsets){ 36.0, 44.0, 52.0, 44.0 }];
        UIImageView *overlayView = [[UIImageView alloc] initWithFrame:_summaryContainerView.bounds];
        overlayView.image = overlayImage;
        [_summaryContainerView addSubview:overlayView];
    }
    return _summaryContainerView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        UIOffset motionOffset = [ViewHelper standardMotionOffset];
        _backgroundImageView = [[UIImageView alloc] initWithImage:nil];
        _backgroundImageView.frame = (CGRect) {
            self.view.bounds.origin.x - motionOffset.horizontal,
            self.view.bounds.origin.y - motionOffset.vertical,
            self.view.bounds.size.width + (motionOffset.horizontal * 2.0),
            self.view.bounds.size.height + (motionOffset.vertical * 2.0)
        };
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        
        // Motion effects.
        [ViewHelper applyDraggyMotionEffectsToView:_backgroundImageView];
    }
    return _backgroundImageView;
}

#pragma mark - Private methods

- (void)loadData {
    if (self.dataLoaded) {
        return;
    }
    
    [self.activityView startAnimating];
    [self.summaryContainerView addSubview:self.activityView];
    
    [CKBook bookForUser:self.user
                success:^(CKBook *book){
                    self.book = book;
                    self.dataLoaded = YES;
                    [self displayBook];
                }
                failure:^(NSError *error){
                    [self.activityView stopAnimating];
                    [self displayStatusMessage:@"UNABLE TO LOAD USER"];
                }];
}

- (void)displayBook {
    [self.activityView stopAnimating];
    
    // Book summary view.
    CKBookSummaryView *bookSummaryView = [[CKBookSummaryView alloc] initWithBook:self.book storeMode:YES];
    bookSummaryView.delegate = self;
    bookSummaryView.frame = CGRectMake(floorf((self.summaryContainerView.bounds.size.width) / 2.0) + kBookSummaryGap,
                                       87,
                                       bookSummaryView.frame.size.width,
                                       bookSummaryView.frame.size.height);
    bookSummaryView.alpha = 0.0;
    [self.summaryContainerView addSubview:bookSummaryView];
    
    // Book cover.
    self.bookCoverView = [[CKStoreBookCoverView alloc] init];
    self.bookCoverView.storeDelegate = self;
    [self.bookCoverView loadBook:self.book editable:NO];
    
    // Loading.
    [self.bookCoverView showActionButton:YES animated:YES];
    [self.bookCoverView showLoading:YES];
    
    // Position of book cover is center of screen but projected onto the book container view.
    CGPoint adjustedCenter = [self.view convertPoint:self.view.center toView:self.summaryContainerView];
    
    self.bookCoverView.frame = (CGRect){
        self.summaryContainerView.bounds.origin.x + kBookViewContentInsets.left,
        adjustedCenter.y - floorf(self.bookCoverView.frame.size.height / 2.0),
        self.bookCoverView.frame.size.width,
        self.bookCoverView.frame.size.height
    };
    self.bookCoverView.alpha = 0.0;
    [self.summaryContainerView addSubview:self.bookCoverView];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.bookCoverView.alpha = 1.0;
                         bookSummaryView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self loadBookCoverPhotoImage];
                     }];
}

//For display from NavigationController only
- (void)backTapped:(id)sender {
    [self.cookNavigationController popViewControllerAnimated:YES];
}

- (void)closeTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(profileViewControllerCloseRequested)]) {
        [EventHelper unregisterPhotoLoading:self];
        [self.delegate profileViewControllerCloseRequested];
    }
}

- (void)loadBookCoverPhotoImage {
    if ([self.book hasCoverPhoto]) {
        DLog(@"Loading book cover photo");
        
        CGSize size = CGSizeZero;
        if (self.cookNavigationController) {
            size = self.cookNavigationController.backgroundImageView.bounds.size;
        } else {
            size = self.backgroundImageView.bounds.size;
        }
        [[CKPhotoManager sharedInstance] imageForBook:self.book size:size];
    }
}

- (void)photoLoadingReceived:(NSNotification *)notification {
    NSString *photoName = [[CKPhotoManager sharedInstance] photoNameForBook:self.book];
    NSString *name = [EventHelper nameForPhotoLoading:notification];
    BOOL thumb = [EventHelper thumbForPhotoLoading:notification];
    if ([photoName isEqualToString:name]) {
        
        // If full image is not loaded yet, then set and keep waiting for it.
        if (!self.fullImageLoaded) {
            if ([EventHelper hasImageForPhotoLoading:notification]) {
                UIImage *image = [EventHelper imageForPhotoLoading:notification];
                [self loadImage:image];
                self.fullImageLoaded = !thumb;
            }
        }
    }
}

- (void)loadImage:(UIImage *)image {
    if (self.cookNavigationController) {
        [self.cookNavigationController loadBackgroundImage:image];
    } else {
        [self loadBackgroundImage:image];
    }
}

- (void)followTapped {
    
    CKUser *currentUser = [CKUser currentUser];
    if (currentUser) {
        
        // Spin.
        [self.bookCoverView showLoading:YES];
        
        // Weak reference so we don't have retain cycles.
        __weak typeof(self) weakSelf = self;
        [self.book addFollower:currentUser
                       success:^{
                           [AnalyticsHelper trackEventName:kEventBookAdd params:nil];
                           [weakSelf.bookCoverView showFollowed];
                           [EventHelper postFollow:YES book:weakSelf.book];
                       }
                       failure:^(NSError *error) {
                           [weakSelf.bookCoverView showLoading:NO];
                           [weakSelf.bookCoverView showAdd];
                           [weakSelf.bookCoverView enable:NO interactable:NO];
                       }];
    }
}

- (void)tapDismissed:(UITapGestureRecognizer *)tapGesture {
    CGPoint tappedPoint = [tapGesture locationInView:self.view];
    if (!CGRectContainsPoint(self.summaryContainerView.frame, tappedPoint)) {
        [self closeTapped:nil];
    }
}

#pragma mark - Background image with motion effects.

- (void)loadBackgroundImage:(UIImage *)backgroundImage {
    
    if (!self.backgroundImageView.superview) {
        self.backgroundImageView.alpha = 0.0;
        [self.view addSubview:self.backgroundImageView];
        [self.view sendSubviewToBack:self.backgroundImageView];
    }
    
    if (!self.backgroundImageTopShadowView) {
        self.backgroundImageTopShadowView = [ViewHelper topShadowViewForView:self.backgroundImageView];
        [self.backgroundImageView addSubview:self.backgroundImageTopShadowView];
    }
    
    if (self.backgroundImageView.image) {
        
        // Just replace over the top if there was a prior image (thumbnail).
        self.backgroundImageView.alpha = 1.0;
        self.backgroundImageView.image = backgroundImage;
        
    } else {
        
        // Fade it in.
        self.backgroundImageView.alpha = 0.0;
        self.backgroundImageView.image = backgroundImage;
        [UIView animateWithDuration:0.6
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.backgroundImageView.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

@end
