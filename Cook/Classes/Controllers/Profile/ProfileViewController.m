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
@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundOverlayView;
@property (nonatomic, strong) UIView *topShadowView;

@end

@implementation ProfileViewController

#define kBookViewContentInsets  (UIEdgeInsets){ 50.0, 100.0, 50.0, 50.0 }
#define kBookViewSize           (CGSize){ 840.0, 614.0 }
#define kBookSummaryGap         20.0
#define kOverlayAlpha           0.5

- (id)initWithUser:(CKUser *)user {
    if (self = [super init]) {
        self.user = user;
        self.isModal = NO;
    }
    return self;
}

// Modal appearance only
- (void)showOverlayOnViewController:(UIViewController *)parentController {
    self.isModal = YES;
    [parentController.view addSubview:self.view];
    [self displayOverlay:YES completion:^(BOOL finished) {
        [self loadData];
    }];
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor clearColor];
    
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    self.backButton = [ViewHelper addBackButtonToView:self.view light:YES target:self selector:@selector(backTapped:)];
    if (self.cookNavigationController || self.isModal) {
        self.backButton.alpha = 0.0;
    }
    if (self.isModal) {
        self.summaryContainerView.alpha = 0.0;
    }
    [self.view addSubview:self.summaryContainerView];
    
    // Register photo loading events.
    [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
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
        _activityView.center = self.view.center;
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
        
        // Box overlay.
        UIImage *overlayImage = [[UIImage imageNamed:@"cook_dash_library_selected_bg.png"] resizableImageWithCapInsets:(UIEdgeInsets){ 36.0, 44.0, 52.0, 44.0 }];
        UIImageView *overlayView = [[UIImageView alloc] initWithFrame:_summaryContainerView.bounds];
        overlayView.image = overlayImage;
        [_summaryContainerView addSubview:overlayView];
    }
    return _summaryContainerView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        self.closeButton.frame = CGRectMake(self.backButton.frame.origin.x, self.backButton.frame.origin.y, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
        self.closeButton.alpha = 0.0;
        [self.view addSubview:self.closeButton];
    }
    return _closeButton;
}

- (UIView *)backgroundOverlayView {
    if (!_backgroundOverlayView) {
        _backgroundOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundOverlayView.alpha = 0.0;
        _backgroundOverlayView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_backgroundOverlayView];
        [self.view sendSubviewToBack:_backgroundOverlayView];
    }
    return _backgroundOverlayView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backgroundImageView.alpha = 0.0;
        [self.view addSubview:_backgroundImageView];
        [self.view insertSubview:_backgroundImageView aboveSubview:_backgroundOverlayView];
    }
    return _backgroundImageView;
}

#pragma mark - Private methods

- (void)loadData {
    if (self.dataLoaded) {
        return;
    }
    
    [self.activityView startAnimating];
    [self.view addSubview:self.activityView];
    
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
    
    self.backgroundImageView.alpha = 0.0;
    
    [UIView animateWithDuration:0.4
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
    if (self.closeBlock)
        self.closeBlock(YES);
    [self.cookNavigationController popViewControllerAnimated:YES];
}

//For modal display only
- (void)displayOverlay:(BOOL)doShow completion:(void (^)(BOOL finished))completionBlock {
    // Transition the imageView overlay in.
    self.closeButton.alpha = doShow ? 0.0 : 1.0;
//    self.topShadowView.alpha = doShow ? 0.0 : 1.0;
    if (doShow) {
        [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
    } else {
        [EventHelper unregisterPhotoLoading:self];
    }
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.backgroundOverlayView.alpha = doShow ? kOverlayAlpha : 0.0;
                         self.summaryContainerView.alpha = doShow ? 1.0 : 0.0;
                         self.closeButton.alpha = doShow ? 1.0 : 0.0;
                         self.backgroundImageView.alpha = doShow ? 1.0: 0.0;
                     }
                     completion:^(BOOL finished) {
                         //Init topSahdowView after backgroundView initialised
                         self.topShadowView = [ViewHelper topShadowViewForView:self.view subtle:NO];
                         self.topShadowView.alpha = 0.0;
                         [self.view insertSubview:self.topShadowView aboveSubview:_backgroundImageView];
                         
                         if (completionBlock) {
                             completionBlock(finished);
                         }
                     }];
}

- (void)closeTapped:(id)sender {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        [self.bookCoverView showActionButton:NO animated:NO];
        self.summaryContainerView.alpha = 0.0;
        self.backgroundImageView.alpha = 0.0;
        [self displayOverlay:NO completion:nil];
//        self.imageOverlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.closeBlock)
            self.closeBlock(YES);
    }];
}

- (void)loadBookCoverPhotoImage {
    if ([self.book hasCoverPhoto]) {
        DLog(@"Loading book cover photo");
        
        if (self.cookNavigationController || self.isModal) {
            CGSize size;
            if (self.cookNavigationController)
                size = self.cookNavigationController.backgroundImageView.bounds.size;
            else if (self.isModal)
                size = self.view.bounds.size;
            [[CKPhotoManager sharedInstance] imageForBook:self.book size:size];
        }
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
    if (self.isModal) {
        self.backgroundImageView.image = image;
        
        if (self.backgroundImageView.alpha == 0.0) {
            
            // Fade it in.
            [UIView animateWithDuration:0.6
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 if (self.isModal) {
                                     self.topShadowView.alpha = 1.0;
                                 }
                                 self.backgroundImageView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
    }
    if (self.cookNavigationController) {
        [self.cookNavigationController loadBackgroundImage:image];
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
                           [AnalyticsHelper trackEventName:@"Added to Bench" params:nil];
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


@end
