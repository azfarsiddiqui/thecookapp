//
//  StoreBookViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreBookViewController.h"
#import "CKBook.h"
#import "CKBookCover.h"
#import "CKUser.h"
#import "CKBookCoverView.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "BenchtopBookCoverViewCell.h"
#import "Theme.h"
#import "CKButtonView.h"
#import "CKUserProfilePhotoView.h"
#import "CKBookSummaryView.h"
#import "EventHelper.h"
#import "NSString+Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "CKPhotoManager.h"
#import "CKActivityIndicatorView.h"
#import "AnalyticsHelper.h"

@interface StoreBookViewController () <CKBookCoverViewDelegate, CKBookSummaryViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) id<StoreBookViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageOverlayView;
@property (nonatomic, strong) UIView *bookContainerView;
@property (nonatomic, strong) CKBookSummaryView *bookSummaryView;
@property (nonatomic, strong) CKBookCoverView *bookCoverView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) BOOL addMode;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL updated;
@property (nonatomic, assign) CGPoint originPoint;
@property (nonatomic, assign) BOOL fullImageLoaded;
@property (nonatomic, strong) UIButton *bookActionButton;
@property (nonatomic, strong) CKActivityIndicatorView *bookActionActivityView;

@end

@implementation StoreBookViewController

#define kBookViewContentInsets  UIEdgeInsetsMake(50.0, 100.0, 50.0, 50.0)
#define kBookViewSize           CGSizeMake(840.0, 614.0)
#define kOverlayAlpha           0.5
#define kBookViewAlpha          0.7
#define kProfileNameGap         20.0
#define kNameStoryGap           20.0
#define kBookSummaryGap         20.0

- (void)dealloc {
    [EventHelper unregisterPhotoLoading:self];
}

- (id)initWithBook:(CKBook *)book addMode:(BOOL)addMode delegate:(id<StoreBookViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.addMode = addMode;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [[AppHelper sharedInstance] fullScreenFrame];
    [self initBackground];
    [self initBookView];
    [self initBookSummaryView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDismissed:)];
    [self.view addGestureRecognizer:tapGesture];
    
    // Register photo loading events.
    [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
}

- (void)transitionFromPoint:(CGPoint)point {
    self.animating = YES;
    self.originPoint = point;
    self.bookContainerView.alpha = 0.0;
    
    CGSize size = [CKBookCover coverImageSize];
    CGFloat scale = [self storeScale];
    
    // Book cover.
    CGRect bookFrame = (CGRect){
        point.x - (size.width * 0.5),
        point.y - (size.height * 0.5),
        size.width,
        size.height
    };
    
    self.bookCoverView = [[CKBookCoverView alloc] init];
    self.bookCoverView.frame = bookFrame;
    self.bookCoverView.transform = CGAffineTransformMakeScale(scale, scale);
    [self.bookCoverView loadBook:self.book editable:NO];
    
    // Featured book uses the author as the name.
    if (self.book.featured) {
        [self.bookCoverView setName:self.book.name author:[NSString CK_safeString:self.book.author defaultString:@""] editable:NO];
    }
    
    [self.view addSubview:self.bookCoverView];
    
    // Move the book to the center of the screen.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.bookCoverView.transform = CGAffineTransformIdentity;
                         self.bookCoverView.center = self.view.center;
                     }
                     completion:^(BOOL finished) {
                         
                         // Slide book aside.
                         [UIView animateWithDuration:0.3
                                               delay:0.1
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.bookCoverView.frame = CGRectMake(self.bookContainerView.frame.origin.x + kBookViewContentInsets.left,
                                                                                    self.bookCoverView.frame.origin.y,
                                                                                    self.bookCoverView.frame.size.width,
                                                                                    self.bookCoverView.frame.size.height);
                                              self.bookContainerView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              // Fade in the action button.
                                              CGRect actionButtonFrame = self.bookActionButton.frame;
                                              actionButtonFrame.origin = (CGPoint) {
                                                  floorf((self.bookCoverView.bounds.size.width - actionButtonFrame.size.width) / 2.0),
                                                  floorf((self.bookCoverView.bounds.size.height - actionButtonFrame.size.height) / 2.0)
                                              };
                                              self.bookActionButton.frame = actionButtonFrame;
                                              self.bookActionButton.alpha = 0.0;
                                              self.bookActionButton.enabled = NO;
                                              self.bookActionButton.userInteractionEnabled = NO;
                                              [self.bookCoverView addSubview:self.bookActionButton];
                                              
                                              // Start spinner.
                                              CGRect actionActivityFrame = self.bookActionActivityView.frame;
                                              actionActivityFrame.origin = (CGPoint) {
                                                  floorf((self.bookActionButton.bounds.size.width - actionActivityFrame.size.width) / 2.0),
                                                  floorf((self.bookActionButton.bounds.size.height - actionActivityFrame.size.height) / 2.0) - 5.0
                                              };
                                              self.bookActionActivityView.frame = actionActivityFrame;
                                              [self.bookActionButton addSubview:self.bookActionActivityView];
                                              [self.bookActionActivityView startAnimating];
                                              
                                              [UIView animateWithDuration:0.3
                                                                    delay:0.0
                                                                  options:UIViewAnimationCurveEaseIn
                                                               animations:^{
                                                                   self.bookActionButton.alpha = 1.0;
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   
                                                                   self.animating = NO;
                                                                   [self loadData];
                                                                   
                                                               }];
                                          }];
                         
                     }];
    
    // Transition the imageView overlay in.
    self.imageView.alpha = 0.0;
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.imageOverlayView.alpha = kOverlayAlpha;
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                     }];
}

#pragma mark - CKBookSummaryViewDelegate methods

- (void)bookSummaryViewBookFollowed {
    
    self.updated = YES;
    
    // Automatically close.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self closeTapped];
    });

}

- (void)bookSummaryViewBookIsFollowed {
    [self.bookActionActivityView stopAnimating];
    [self.bookActionButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_added.png"] forState:UIControlStateNormal];
    self.bookActionButton.userInteractionEnabled = NO;
    self.bookActionButton.enabled = YES;
}

- (void)bookSummaryViewBookIsPrivate {
    [self.bookActionActivityView stopAnimating];
    [self.bookActionButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_private.png"] forState:UIControlStateNormal];
    self.bookActionButton.userInteractionEnabled = NO;
    self.bookActionButton.enabled = YES;
}

- (void)bookSummaryViewBookIsDownloadable {
    [self.bookActionActivityView stopAnimating];
    [self.bookActionButton addTarget:self action:@selector(followTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.bookActionButton.userInteractionEnabled = YES;
    self.bookActionButton.enabled = YES;
}


#pragma mark - CKBookCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
    
}

#pragma mark - Properties

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped)];
    }
    return _closeButton;
}

- (UIButton *)bookActionButton {
    if (!_bookActionButton && ![self.book isOwner]) {
        _bookActionButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_addtodash.png"]
                                          selectedImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_addtodash_onpress.png"]
                                                 target:nil selector:nil];
    }
    return _bookActionButton;
}

- (CKActivityIndicatorView *)bookActionActivityView {
    if (!_bookActionActivityView) {
        _bookActionActivityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
    }
    return _bookActionActivityView;
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Background container view.
    UIView *backgroundContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundContainerView];
    
    // Image black overlay.
    UIView *imageOverlayView = [[UIView alloc] initWithFrame:backgroundContainerView.bounds];
    imageOverlayView.alpha = 0.0;
    imageOverlayView.backgroundColor = [UIColor blackColor];
    [backgroundContainerView addSubview:imageOverlayView];
    self.imageOverlayView = imageOverlayView;
    
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

- (void)initBookView {
    
    // Container view.
    UIView *bookContainerView = [[UIView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - kBookViewSize.width) / 2.0),
                                                                         floorf((self.view.bounds.size.height - kBookViewSize.height) / 2.0),
                                                                         kBookViewSize.width,
                                                                         kBookViewSize.height)];
    bookContainerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bookContainerView];
    self.bookContainerView = bookContainerView;
    
    // Black overlay.
    UIImage *overlayImage = [[UIImage imageNamed:@"cook_dash_library_selected_bg.png"] resizableImageWithCapInsets:(UIEdgeInsets){ 36.0, 44.0, 52.0, 44.0 }];
    UIImageView *overlayView = [[UIImageView alloc] initWithFrame:bookContainerView.bounds];
    overlayView.image = overlayImage;
    [bookContainerView addSubview:overlayView];
    
    // Close button.
    self.closeButton.frame = CGRectMake(42.0, 35.0, self.closeButton.frame.size.width, self.closeButton.frame.size.height);
    [bookContainerView addSubview:self.closeButton];
}

- (void)initBookSummaryView {
    
    CKBookSummaryView *bookSummaryView = [[CKBookSummaryView alloc] initWithBook:self.book storeMode:YES addMode:self.addMode];
    bookSummaryView.delegate = self;
    bookSummaryView.frame = CGRectMake(floorf((self.bookContainerView.bounds.size.width) / 2.0) + kBookSummaryGap,
                                       87,
                                       bookSummaryView.frame.size.width,
                                       bookSummaryView.frame.size.height);
    [self.bookContainerView addSubview:bookSummaryView];
    self.bookSummaryView = bookSummaryView;
}

- (void)closeTapped {
    
    if (self.animating) {
        return;
    }
    
    self.animating = YES;
    CGFloat scale = [self storeScale];
    
    // Transition book back to shelf.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bookActionButton.alpha = 0.0;
                         self.bookContainerView.alpha = 0.0;
                         self.imageView.alpha = 0.0;
                         self.imageOverlayView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         
                         // Transition book back to shelf.
                         [UIView animateWithDuration:0.3
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.bookCoverView.center = self.originPoint;
                                              self.bookCoverView.transform = CGAffineTransformMakeScale(scale, scale);
                                          }
                                          completion:^(BOOL finished) {
                                              self.animating = NO;
                                              
                                              if (self.updated) {
                                                  [self.delegate storeBookViewControllerUpdatedBook:self.book];
                                              }
                                              [self.delegate storeBookViewControllerCloseRequested];
                                          }];
                     }];
    
}

- (void)tapDismissed:(UITapGestureRecognizer *)tapGesture {
    if (self.animating) {
        return;
    }
    
    CGPoint tappedPoint = [tapGesture locationInView:self.view];
    if (!CGRectContainsPoint(self.bookContainerView.frame, tappedPoint)) {
        [self closeTapped];
    }
}

- (void)loadData {
    if ([self.book hasCoverPhoto]) {
        [[CKPhotoManager sharedInstance] imageForBook:self.book size:self.imageView.bounds.size];
    }
}

- (void)loadImage:(UIImage *)image {
    
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

- (CGFloat)storeScale {
    CGSize storeSize = [CKBookCover mediumImageSize];
    CGSize size = [CKBookCover coverImageSize];
    CGFloat scale = storeSize.width / size.width;
    return scale;
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

- (void)followTapped:(id)sender {
    
    CKUser *currentUser = [CKUser currentUser];
    if (currentUser) {
        
        // Spin.
        [self.bookActionActivityView startAnimating];
        self.bookActionButton.userInteractionEnabled = NO;
        self.bookActionButton.enabled = NO;
        
        // Weak reference so we don't have retain cycles.
        __weak typeof(self) weakSelf = self;
        [self.book addFollower:currentUser
                       success:^{
                           [AnalyticsHelper trackEventName:@"Added to Bench" params:nil];
                           [weakSelf bookSummaryViewBookIsFollowed];
                           [EventHelper postFollow:YES book:weakSelf.book];
                           [weakSelf bookSummaryViewBookFollowed];
                       }
                       failure:^(NSError *error) {
                           [weakSelf.bookActionActivityView stopAnimating];
                           [weakSelf.bookActionButton setBackgroundImage:[UIImage imageNamed:@"cook_dash_library_selected_btn_addtodash.png"]
                                                                forState:UIControlStateNormal];
                           weakSelf.bookActionButton.userInteractionEnabled = NO;
                           weakSelf.bookActionButton.enabled = NO;
                       }];
    }
}

@end
