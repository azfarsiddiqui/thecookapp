//
//  StoreBookViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreBookViewController.h"
#import "CKBook.h"
#import "CKUser.h"
#import "CKBookCoverView.h"
#import "AppHelper.h"
#import "ViewHelper.h"
#import "BenchtopBookCoverViewCell.h"
#import "Theme.h"
#import "CKButtonView.h"
#import "CKUserProfilePhotoView.h"
#import "CKBookSummaryView.h"
#import <QuartzCore/QuartzCore.h>

@interface StoreBookViewController () <CKBookCoverViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, assign) id<StoreBookViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *bookContainerView;
@property (nonatomic, strong) CKBookSummaryView *bookSummaryView;
@property (nonatomic, strong) CKBookCoverView *bookCoverView;
@property (nonatomic, strong) CKButtonView *actionButtonView;
@property (nonatomic, assign) BOOL pendingAcceptance;
@property (nonatomic, assign) BOOL addMode;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) CGPoint originPoint;

@end

@implementation StoreBookViewController

#define kBookViewContentInsets  UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0)
#define kBookViewSize           CGSizeMake(740.0, 540.0)
#define kBookShadowAdjustment   10.0
#define kOverlayAlpha           0.5
#define kBookViewAlpha          0.7
#define kProfileNameGap         20.0
#define kNameStoryGap           20.0

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
    self.imageView.alpha = 0.0;
    self.bookContainerView.alpha = 0.0;
    
    CGFloat scale = [BenchtopBookCoverViewCell storeScale];
    CGSize size = [BenchtopBookCoverViewCell cellSize];
    
    // Book cover.
    CGRect bookFrame = CGRectMake(point.x - (size.width * 0.5), point.y - (size.height * 0.5), size.width, size.height);
    CKBookCoverView *bookCoverView = [[CKBookCoverView alloc] initWithFrame:bookFrame];
    bookCoverView.transform = CGAffineTransformMakeScale(scale, scale);
    [bookCoverView setCover:self.book.cover illustration:self.book.illustration];
    
    if (self.book.featured) {
        [bookCoverView setTitle:self.book.name author:nil caption:self.book.caption editable:NO];
    } else {
        [bookCoverView setTitle:self.book.name author:[self.book userName] caption:self.book.caption editable:[self.book editable]];
    }
    
    [self.view addSubview:bookCoverView];
    self.bookCoverView = bookCoverView;
    
    // Move the book to the center of the screen.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         bookCoverView.transform = CGAffineTransformIdentity;
                         bookCoverView.center = CGPointMake(self.view.center.x, self.view.center.y + kBookShadowAdjustment);
                     }
                     completion:^(BOOL finished) {
                         
                         // Slide book aside.
                         [UIView animateWithDuration:0.3
                                               delay:0.1
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.bookCoverView.frame = CGRectMake(self.bookContainerView.frame.origin.x + kBookViewContentInsets.left,
                                                                                    self.bookContainerView.frame.origin.y + kBookViewContentInsets.top + kBookShadowAdjustment,
                                                                                    self.bookCoverView.frame.size.width,
                                                                                    self.bookCoverView.frame.size.height);
                                              self.bookContainerView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                              self.animating = NO;
                                          }];
                         
                     }];
    
    // Transition the imageView in.
    self.imageView.alpha = 0.0;
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.imageView.alpha = kOverlayAlpha;
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
    
    // Background imageView.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:imageView];
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
    UIView *overlayView = [[UIView alloc] initWithFrame:bookContainerView.bounds];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = kBookViewAlpha;
    [bookContainerView addSubview:overlayView];
    
    // Close button.
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"btn_close.png"] target:self selector:@selector(closeTapped)];
    closeButton.frame = CGRectMake(15.0, 10.0, closeButton.frame.size.width, closeButton.frame.size.height);
    [bookContainerView addSubview:closeButton];
}

- (void)initBookSummaryView {
    
    CKBookSummaryView *bookSummaryView = [[CKBookSummaryView alloc] initWithBook:self.book];
    bookSummaryView.frame = CGRectMake(floorf((self.bookContainerView.bounds.size.width) / 2.0),
                                       kBookViewContentInsets.top - 5.0,
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
    CGFloat scale = [BenchtopBookCoverViewCell storeScale];
    
    // Transition book back to shelf.
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.bookContainerView.alpha = 0.0;
                         self.imageView.alpha = 0.0;
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
                                              [self.delegate storeBookViewControllerCloseRequested];
                                          }];
                     }];
    
}

- (void)initAddButton {
    [self initActionButtonWithSelector:@selector(addTapped:)];
    [self updateAddButtonText:@"Add Book" activity:YES enabled:NO];
    
    [self.book isFollowedByUser:self.currentUser
                        success:^(BOOL followed) {
                            if (followed) {
                                [self updateAddButtonText:@"Already Added" activity:NO enabled:NO];
                            } else {
                                [self updateAddButtonText:@"Add Book" activity:NO enabled:YES];
                            }
                        }
                        failure:^(NSError *error) {
                            [self updateAddButtonText:@"Add Book" activity:NO enabled:NO];
                        }];
}

- (void)initFriendsButton {
    [self initActionButtonWithSelector:@selector(requestTapped:)];
    [self updateRequestButtonText:@"Send Friend Request" activity:YES enabled:NO];
    
    [self.currentUser checkIsFriendsWithUser:self.book.user
                                  completion:^(BOOL alreadySent, BOOL alreadyConnected, BOOL pendingAcceptance) {
                                      if (alreadyConnected) {
                                          [self updateRequestButtonText:@"Already Friends" activity:NO enabled:NO];
                                      } else if (pendingAcceptance) {
                                          self.pendingAcceptance = pendingAcceptance;
                                          [self updateRequestButtonText:@"Accept Friend Request" activity:NO enabled:YES];
                                      } else if (alreadySent) {
                                          [self updateRequestButtonText:@"Already Requested" activity:NO enabled:NO];
                                      } else {
                                          [self updateRequestButtonText:@"Send Friend Request" activity:NO enabled:YES];
                                      }
                                  } failure:^(NSError *error) {
                                      [self updateRequestButtonText:@"Send Friend Request" activity:NO enabled:NO];
                                  }];
}

- (void)initActionButtonWithSelector:(SEL)selector {
    CKButtonView *actionButtonView = [[CKButtonView alloc] initWithTarget:self action:selector];
    actionButtonView.frame = CGRectMake(floorf((self.bookSummaryView.bounds.size.width - actionButtonView.frame.size.width) / 2.0),
                                        self.bookSummaryView.bounds.size.height - actionButtonView.frame.size.height - 16.0,
                                        actionButtonView.frame.size.width,
                                        actionButtonView.frame.size.height);
    [self.bookSummaryView addSubview:actionButtonView];
    self.actionButtonView = actionButtonView;
}

- (void)updateAddButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled {
    [self updateAddButtonText:text activity:activity enabled:enabled selector:nil];
}

- (void)updateAddButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled selector:(SEL)selector {
    UIImage *iconImage = [UIImage imageNamed:@"cook_dash_library_profile_icon_addtodash.png"];
    [self.actionButtonView setText:[text uppercaseString] activity:activity icon:iconImage enabled:enabled selector:selector];
}

- (void)updateRequestButtonText:(NSString *)text activity:(BOOL)activity enabled:(BOOL)enabled {
    UIImage *iconImage = [UIImage imageNamed:@"cook_dash_library_profile_icon_friendrequest.png"];
    [self.actionButtonView setText:[text uppercaseString] activity:activity icon:iconImage enabled:enabled];
}

- (void)requestTapped:(id)sender {
    if (self.pendingAcceptance) {
        [self updateRequestButtonText:@"AcceptingFriend Request" activity:YES enabled:NO];
    } else {
        [self updateRequestButtonText:@"Sending Friend Request" activity:YES enabled:NO];
    }
    [self.currentUser requestFriend:self.book.user
                         completion:^{
                             if (self.pendingAcceptance) {
                                 [self updateRequestButtonText:@"Friend Request Accepted" activity:NO enabled:NO];
                             } else {
                                 [self updateRequestButtonText:@"Friend Request Sent" activity:NO enabled:NO];
                             }
                         }
                            failure:^(NSError *error) {
                                [self updateRequestButtonText:@"Unable to Send" activity:NO enabled:NO];
                            }];
}

- (void)addTapped:(id)sender {
    [self updateAddButtonText:@"Adding Book" activity:YES enabled:NO];
    
    // Weak reference so we don't have retain cycles.
    __weak typeof(self) weakSelf = self;
    [self.book addFollower:self.currentUser
                   success:^{
                       [weakSelf updateAddButtonText:@"Book Added" activity:NO enabled:NO];
                   }
                   failure:^(NSError *error) {
                       [weakSelf updateAddButtonText:@"Unable to Add" activity:NO enabled:NO];
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

@end
