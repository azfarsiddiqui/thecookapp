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

@interface StoreBookViewController () <CKBookCoverViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, assign) id<StoreBookViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageOverlayView;
@property (nonatomic, strong) UIView *bookContainerView;
@property (nonatomic, strong) CKBookSummaryView *bookSummaryView;
@property (nonatomic, strong) CKBookCoverView *bookCoverView;
@property (nonatomic, strong) CKButtonView *actionButtonView;
@property (nonatomic, assign) BOOL pendingAcceptance;
@property (nonatomic, assign) BOOL addMode;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL updated;
@property (nonatomic, assign) CGPoint originPoint;

@end

@implementation StoreBookViewController

#define kBookViewContentInsets  UIEdgeInsetsMake(50.0, 100.0, 50.0, 50.0)
#define kBookViewSize           CGSizeMake(840.0, 614.0)
#define kOverlayAlpha           0.5
#define kBookViewAlpha          0.7
#define kProfileNameGap         20.0
#define kNameStoryGap           20.0
#define kBookSummaryGap         20.0

- (id)initWithBook:(CKBook *)book addMode:(BOOL)addMode delegate:(id<StoreBookViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.addMode = addMode;
        self.delegate = delegate;
        self.currentUser = [CKUser currentUser];
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
    CKBookCoverView *bookCoverView = [[CKBookCoverView alloc] init];
    bookCoverView.frame = bookFrame;
    bookCoverView.transform = CGAffineTransformMakeScale(scale, scale);
    [bookCoverView setCover:self.book.cover illustration:self.book.illustration];
    
    if (self.book.featured) {
        [bookCoverView setName:self.book.name author:[NSString CK_safeString:self.book.author defaultString:@""] editable:NO];
    } else {
        [bookCoverView setName:self.book.name author:[self.book userName] editable:[self.book editable]];
    }
    
    [self.view addSubview:bookCoverView];
    self.bookCoverView = bookCoverView;
    
    // Move the book to the center of the screen.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         bookCoverView.transform = CGAffineTransformIdentity;
                         bookCoverView.center = self.view.center;
                     }
                     completion:^(BOOL finished) {
                         
                         // Slide book aside.
                         [UIView animateWithDuration:0.3
                                               delay:0.1
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.bookCoverView.frame = CGRectMake(self.bookContainerView.frame.origin.x + kBookViewContentInsets.left,
                                                                                    bookCoverView.frame.origin.y,
                                                                                    self.bookCoverView.frame.size.width,
                                                                                    self.bookCoverView.frame.size.height);
                                              self.bookContainerView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              self.animating = NO;
                                              [self loadData];
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

#pragma mark - CKBookCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
    
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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:backgroundContainerView.bounds];
    imageView.backgroundColor = [UIColor clearColor];
    [backgroundContainerView addSubview:imageView];
    self.imageView = imageView;
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
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_book_icon_close_white.png"] target:self selector:@selector(closeTapped)];
    closeButton.frame = CGRectMake(10.0, 8.0, closeButton.frame.size.width, closeButton.frame.size.height);
    [bookContainerView addSubview:closeButton];
}

- (void)initBookSummaryView {
    
    CKBookSummaryView *bookSummaryView = [[CKBookSummaryView alloc] initWithBook:self.book storeMode:YES];
    bookSummaryView.frame = CGRectMake(floorf((self.bookContainerView.bounds.size.width) / 2.0) + kBookSummaryGap,
                                       87,
                                       bookSummaryView.frame.size.width,
                                       bookSummaryView.frame.size.height);
    [self.bookContainerView addSubview:bookSummaryView];
    self.bookSummaryView = bookSummaryView;
    
    // Action button.
    if (self.addMode) {
        [self initAddButton];
    } else {
        [self initFriendsButton];
    }
}

- (void)closeTapped {
    
    self.animating = YES;
    CGFloat scale = [self storeScale];
    
    // Transition book back to shelf.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
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

- (void)initAddButton {
    NSString *buttonText = @"ADD TO BENCH";
    [self initActionButtonWithSelector:@selector(addTapped:)];
    [self updateAddButtonText:buttonText activity:YES enabled:NO];
    
    if (self.currentUser) {
        [self.book isFollowedByUser:self.currentUser
                            success:^(BOOL followed) {
                                if (followed) {
                                    [self updateAddButtonText:@"BOOK ON BENCH" activity:NO enabled:NO];
                                } else {
                                    [self updateAddButtonText:buttonText activity:NO enabled:YES];
                                }
                            }
                            failure:^(NSError *error) {
                                [self updateAddButtonText:buttonText activity:NO enabled:NO];
                            }];
    } else {
        [self updateAddButtonText:@"PLEASE SIGN IN" activity:NO enabled:NO];
    }
}

- (void)initFriendsButton {
    NSString *friendRequestText = @"ADD FRIEND";
    
    [self initActionButtonWithSelector:@selector(requestTapped:)];
    [self updateRequestButtonText:friendRequestText activity:YES enabled:NO];
    
    [self.currentUser checkIsFriendsWithUser:self.book.user
                                  completion:^(BOOL alreadySent, BOOL alreadyConnected, BOOL pendingAcceptance) {
                                      if (alreadyConnected) {
                                          [self updateRequestButtonText:@"ALREADY FRIENDS" activity:NO enabled:NO];
                                      } else if (pendingAcceptance) {
                                          self.pendingAcceptance = pendingAcceptance;
                                          [self updateRequestButtonText:@"ADD FRIEND" activity:NO enabled:YES];
                                      } else if (alreadySent) {
                                          [self updateRequestButtonText:@"REQUESTED" activity:NO enabled:NO];
                                      } else {
                                          [self updateRequestButtonText:friendRequestText activity:NO enabled:YES];
                                      }
                                  } failure:^(NSError *error) {
                                      [self updateRequestButtonText:friendRequestText activity:NO enabled:NO];
                                  }];
}

- (void)initActionButtonWithSelector:(SEL)selector {
    CKButtonView *actionButtonView = [[CKButtonView alloc] initWithTarget:self action:selector];
    actionButtonView.frame = CGRectMake(floorf((self.bookSummaryView.bounds.size.width - actionButtonView.frame.size.width) / 2.0),
                                        self.bookSummaryView.bounds.size.height - actionButtonView.frame.size.height,
                                        actionButtonView.frame.size.width,
                                        actionButtonView.frame.size.height);
    [self.bookSummaryView addSubview:actionButtonView];
    self.actionButtonView = actionButtonView;
}

- (void)updateAddButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled {
    [self updateAddButtonText:text activity:activity enabled:enabled target:nil selector:nil];
}

- (void)updateAddButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled target:(id)target selector:(SEL)selector {
    UIImage *iconImage = [UIImage imageNamed:@"cook_dash_library_selected_icon_addtodash.png"];
    [self.actionButtonView setText:[text uppercaseString] activity:activity icon:iconImage enabled:enabled target:target selector:selector];
}

- (void)updateRequestButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled {
    UIImage *iconImage = [UIImage imageNamed:@"cook_dash_library_selected_icon_friend.png"];
    [self.actionButtonView setText:[text uppercaseString] activity:activity icon:iconImage enabled:enabled];
}

- (void)requestTapped:(id)sender {
    if (self.pendingAcceptance) {
        [self updateRequestButtonText:@"ACCEPTING" activity:YES enabled:NO];
    } else {
        [self updateRequestButtonText:@"SENDING" activity:YES enabled:NO];
    }
    [self.currentUser requestFriend:self.book.user
                         completion:^{
                             if (self.pendingAcceptance) {
                                 [self updateRequestButtonText:@"ACCEPTED" activity:NO enabled:NO];
                             } else {
                                 [self updateRequestButtonText:@"REQUESTED" activity:NO enabled:NO];
                             }
                         }
                            failure:^(NSError *error) {
                                [self updateRequestButtonText:@"UNABLE TO SEND" activity:NO enabled:NO];
                            }];
}

- (void)addTapped:(id)sender {
    [self updateAddButtonText:@"ADD TO BENCH" activity:YES enabled:NO];
    
    // Weak reference so we don't have retain cycles.
    __weak typeof(self) weakSelf = self;
    [self.book addFollower:self.currentUser
                   success:^{
                       [weakSelf updateAddButtonText:@"BOOK ON BENCH" activity:NO enabled:NO];
                       weakSelf.updated = YES;
                       [EventHelper postFollow:YES friends:NO];
                   }
                   failure:^(NSError *error) {
                       [weakSelf updateAddButtonText:@"UNABLE TO ADD" activity:NO enabled:NO];
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
    
    [[CKPhotoManager sharedInstance] imageForParseFile:[self.book.user parseCoverPhotoFile]
                                                  size:self.imageView.bounds.size name:@"profileCover"
                                              progress:^(CGFloat progressRatio) {
                                              } completion:^(UIImage *image, NSString *name) {
                                                  
                                                  // Set the image and prepare for fade-in.
                                                  self.imageView.image = image;
                                                  self.imageView.alpha = 0.0;
                                                  
                                                  // Fade it in.
                                                  [UIView animateWithDuration:0.6
                                                                        delay:0.0
                                                                      options:UIViewAnimationOptionCurveEaseIn
                                                                   animations:^{
                                                                       self.imageView.alpha = 1.0;
                                                                   }
                                                                   completion:^(BOOL finished) {
                                                                   }];
                                                  
                                              }];
}

- (CGFloat)storeScale {
    CGSize storeSize = [CKBookCover mediumImageSize];
    CGSize size = [CKBookCover coverImageSize];
    CGFloat scale = storeSize.width / size.width;
    return scale;
}

@end
