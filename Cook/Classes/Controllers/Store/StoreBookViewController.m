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
#import <QuartzCore/QuartzCore.h>

@interface StoreBookViewController () <CKBookCoverViewDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, assign) id<StoreBookViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *bookContainerView;
@property (nonatomic, strong) CKBookCoverView *bookCoverView;
@property (nonatomic, strong) CKButtonView *actionButtonView;
@property (nonatomic, assign) BOOL pendingAcceptance;
@property (nonatomic, assign) BOOL addMode;

@end

@implementation StoreBookViewController

#define kBookViewContentInsets  UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0)
#define kBookViewSize           CGSizeMake(740.0, 540.0)
#define kBookShadowAdjustment   10.0

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
    if (self.addMode) {
        [self initAddButton];
    } else {
        [self initFriendsButton];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDismissed:)];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - CKBookCoverViewDelegate methods

- (void)bookCoverViewEditRequested {
}

#pragma mark - CKButtonViewDelegate methods

- (void)buttonViewTapped {
    if ([self.book isPublic]) {
    } else {
    }
}

#pragma mark - Private methods

- (void)initBackground {
    
    // Background imageView.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.alpha = 0.8;
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
    bookContainerView.layer.borderColor = [[UIColor blackColor] CGColor];
    bookContainerView.layer.borderWidth = 3.0;
    [self.view addSubview:bookContainerView];
    self.bookContainerView = bookContainerView;
    
    // Black overlay.
    UIView *overlayView = [[UIView alloc] initWithFrame:bookContainerView.bounds];
    overlayView.backgroundColor = [UIColor blackColor];
    overlayView.alpha = 0.7;
    [bookContainerView addSubview:overlayView];
    
    // Close button.
    UIButton *closeButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"btn_close.png"] target:self selector:@selector(closeTapped)];
    closeButton.frame = CGRectMake(15.0, 10.0, closeButton.frame.size.width, closeButton.frame.size.height);
    [bookContainerView addSubview:closeButton];
    
    // Book cover.
    CGSize size = [BenchtopBookCoverViewCell cellSize];
    CKBookCoverView *bookCoverView = [[CKBookCoverView alloc] initWithFrame:CGRectMake(kBookViewContentInsets.left,
                                                                                       kBookViewContentInsets.top + kBookShadowAdjustment,
                                                                                       size.width,
                                                                                       size.height) delegate:self];
    [bookCoverView setCover:self.book.cover illustration:self.book.illustration];
    [bookCoverView setTitle:self.book.name author:[self.book userName] caption:self.book.caption editable:[self.book editable]];
    [bookContainerView addSubview:bookCoverView];
    self.bookCoverView = bookCoverView;
}

- (void)closeTapped {
    [self.delegate storeBookViewControllerCloseRequested];
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
    actionButtonView.frame = CGRectMake(self.bookCoverView.frame.origin.x + self.bookCoverView.frame.size.width + floorf((self.bookContainerView.bounds.size.width - self.bookCoverView.frame.origin.x - self.bookCoverView.frame.size.width - actionButtonView.frame.size.width) / 2.0),
                                        self.bookContainerView.bounds.size.height - kBookViewContentInsets.bottom - actionButtonView.frame.size.height,
                                        actionButtonView.frame.size.width,
                                        actionButtonView.frame.size.height);
    [self.bookContainerView addSubview:actionButtonView];
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
    [self.book addFollower:self.currentUser
                   success:^{
                       [self updateAddButtonText:@"Book Added" activity:NO enabled:NO];
                   }
                   failure:^(NSError *error) {
                       [self updateAddButtonText:@"Unable to Add" activity:NO enabled:NO];
                   }];
}

- (void)tapDismissed:(UITapGestureRecognizer *)tapGesture {
    CGPoint tappedPoint = [tapGesture locationInView:self.view];
    if (!CGRectContainsPoint(self.bookContainerView.frame, tappedPoint)) {
        [self closeTapped];
    }
}

@end
