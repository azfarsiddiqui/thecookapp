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
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *summaryContainerView;
@property (nonatomic, strong) CKNavigationController *cookNavigationController;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL fullImageLoaded;
@property (nonatomic, strong) CKStoreBookCoverView *bookCoverView;

@end

@implementation ProfileViewController

#define kBookViewContentInsets  (UIEdgeInsets){ 50.0, 100.0, 50.0, 50.0 }
#define kBookViewSize           (CGSize){ 840.0, 614.0 }
#define kBookSummaryGap         20.0

- (void)dealloc {
    [EventHelper unregisterPhotoLoading:self];
}

- (id)initWithUser:(CKUser *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    self.backButton = [ViewHelper addBackButtonToView:self.view light:NO target:self selector:@selector(backTapped:)];
    if (self.cookNavigationController) {
        self.backButton.alpha = 0.0;
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

- (BOOL)storeBookCoverViewFeaturedMode {
    return NO;
}

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
        self.imageView.alpha = 0.0;
    }
}

- (void)cookNavigationControllerViewDidAppear:(NSNumber *)boolNumber {
    if ([boolNumber boolValue]) {
        [self loadData];
        
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

#pragma mark - Private methods

- (void)initBackground {
    
    // Background container view.
    UIView *backgroundContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundContainerView];
    
    // Background imageView.
    UIOffset motionOffset = [ViewHelper standardMotionOffset];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = (CGRect) {
        backgroundContainerView.bounds.origin.x - motionOffset.horizontal,
        backgroundContainerView.bounds.origin.y - motionOffset.vertical,
        backgroundContainerView.bounds.size.width + (motionOffset.horizontal * 2.0),
        backgroundContainerView.bounds.size.height + (motionOffset.vertical * 2.0)
    };
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [backgroundContainerView addSubview:imageView];
    imageView.alpha = 0.0;
    self.imageView = imageView;
    
    // Motion effects.
    [ViewHelper applyDraggyMotionEffectsToView:self.imageView];
}

- (void)loadData {
    [self.activityView startAnimating];
    [self.view addSubview:self.activityView];
    
    [CKBook bookForUser:self.user
                success:^(CKBook *book){
                    self.book = book;
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
    CKBookSummaryView *bookSummaryView = [[CKBookSummaryView alloc] initWithBook:self.book storeMode:YES featuredMode:NO];
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

- (void)backTapped:(id)sender {
    [self.cookNavigationController popViewControllerAnimated:YES];
}

- (void)loadBookCoverPhotoImage {
    if ([self.book hasCoverPhoto]) {
        DLog(@"Loading book cover photo");
        
        CGSize size = self.imageView.bounds.size;
        if (self.cookNavigationController) {
            size = self.cookNavigationController.backgroundImageView.frame.size;
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
        [self.cookNavigationController loadBackgroundImage:image animation:^{
            self.view.backgroundColor = [UIColor clearColor];
        }];
    } else {
        self.imageView.image = image;
        if (self.imageView.alpha == 0.0) {
            
            // Fade it in.
            [UIView animateWithDuration:0.6
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.imageView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
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
