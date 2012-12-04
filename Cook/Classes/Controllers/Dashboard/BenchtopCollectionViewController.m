//
//  CKViewController.m
//  CKBookCoverViewDemo
//
//  Created by Jeff Tan-Ang on 21/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "BenchtopCollectionViewController.h"
#import "BenchtopCollectionFlowLayout.h"
#import "BenchtopBookCoverViewCell.h"
#import "CKUser.h"
#import "CKBook.h"
#import "CKLoginView.h"
#import "EventHelper.h"

@interface BenchtopCollectionViewController () <CKLoginViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) CKBook *myBook;
@property (nonatomic, strong) NSMutableArray *followBooks;
@property (nonatomic, strong) CKLoginView *loginView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation BenchtopCollectionViewController

#define kCellId         @"BenchtopCellId"
#define kMySection      0
#define kFollowSection  1

- (void)dealloc {
    [EventHelper unregisterFollowUpdated:self];
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[BenchtopCollectionFlowLayout alloc] init]]) {
        [EventHelper registerFollowUpdated:self selector:@selector(followUpdated:)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBackground];
    [self initLoginView];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[BenchtopBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)enable:(BOOL)enable {
    if (enable) {
        
        // Start loading my book if not there already.
        NSInteger numMyBooks = [self.collectionView numberOfItemsInSection:kMySection];
        if (numMyBooks == 0) {
            [self loadMyBook];
        }
        
        // Load following books if not there already.
        if ([self.followBooks count] == 0) {
            [self loadFollowBooks];
        }
        
    }
}

- (void)bookWillOpen:(BOOL)open {
    
    // Hide the bookCover.
    if (open) {
        BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        cell.bookCoverView.hidden = YES;
    }
}

- (void)bookDidOpen:(BOOL)open {
    
    // Restore the bookCover.
    if (!open) {
        BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        cell.bookCoverView.hidden = NO;
    }
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPath = indexPath;
    
    if (indexPath.section == kMySection) {
        
        [self openBookAtIndexPath:indexPath];
        
    } else if (indexPath.section == kFollowSection) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil otherButtonTitles:@"Unfollow", @"Open", nil];
        actionSheet.delegate = self;
        [actionSheet showFromRect:cell.frame inView:collectionView animated:YES];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [BenchtopBookCoverViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == kMySection) {
        return UIEdgeInsetsMake(155.0, 362.0, 155.0, 0.0);
    } else {
        return UIEdgeInsetsMake(155.0, 300.0, 155.0, 362.0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self.followBooks count] == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    switch (section) {
        case kMySection:
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                               forIndexPath:indexPath];
    if (indexPath.section == kMySection) {
        [cell loadBook:self.myBook];
    } else if (indexPath.section == kFollowSection) {
        CKBook *book = [self.followBooks objectAtIndex:indexPath.item];
        [cell loadBook:book];
    }
    
    return cell;
}

#pragma mark - CKLoginViewDelegate

- (void)loginViewTapped {
    
    // Spin the facebook button.
    [self.loginView loginStarted];
    
    // Dispatch login after one second.
    [self performSelector:@selector(performLogin) withObject:nil afterDelay:1.0];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"Item %d", buttonIndex);
    switch (buttonIndex) {
        case 0:
            [self unfollowBookAtIndexPath:self.selectedIndexPath];
            break;
        case 1:
            [self openBookAtIndexPath:self.selectedIndexPath];
            break;
        default:
            break;
    }
}


#pragma mark - Private methods

- (void)initBackground {
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_bg_whole.png"]];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, backgroundView.frame.size.width, backgroundView.frame.size.height);
    self.view.clipsToBounds = NO;
    [self.view insertSubview:backgroundView belowSubview:self.collectionView];
    self.backgroundView = backgroundView;
}

- (void)initLoginView {
    CKUser *currentUser = [CKUser currentUser];
    
    CKLoginView *loginView = [[CKLoginView alloc] initWithDelegate:self];
    loginView.frame = CGRectMake(floorf((self.view.bounds.size.width - loginView.frame.size.width) / 2.0),
                                 self.view.bounds.size.height - loginView.frame.size.height - 60.0,
                                 loginView.frame.size.width,
                                 loginView.frame.size.height);
    loginView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    loginView.hidden = [currentUser isSignedIn];
    [self.view addSubview:loginView];
    self.loginView = loginView;
}

- (void)loadMyBook {
    [CKBook bookForUser:[CKUser currentUser]
                success:^(CKBook *book) {
                    
                    if (self.myBook) {
                        
                        [self.collectionView performBatchUpdates:^{
                            
                            // There is an existing book, so we swap it out first.
                            self.myBook = nil;
                            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:kMySection]]];
                            
                        } completion:^(BOOL finished) {
                            
                            // Now reinsert the new book.
                            self.myBook = book;
                            [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:kMySection]]];
                        }];
                        
                        
                    } else {
                        self.myBook = book;
                        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:kMySection]]];
                    }
                    
                }
                failure:^(NSError *error) {
                    DLog(@"Error: %@", [error localizedDescription]);
                }];
}

- (void)loadFollowBooks {
    [CKBook followBooksForUser:[CKUser currentUser]
                       success:^(NSArray *books) {
                           self.followBooks = [NSMutableArray arrayWithArray:books];
                           if ([books count] > 0) {
                               NSInteger numSections = [self.collectionView numberOfSections];
                               if (numSections > 1) {
                                   [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
                               } else {
                                   [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
                               }
                           }
                       }
                       failure:^(NSError *error) {
                           DLog(@"Error: %@", [error localizedDescription]);
                       }];
}

- (void)performLogin {
    
    // Now tries and log the user in.
    [CKUser loginWithFacebookCompletion:^{
        
        CKUser *user = [CKUser currentUser];
        if (user.admin) {
            [self.loginView loginAdminDone];
        } else {
            [self.loginView loginLoadingFriends:[user numFollows]];
        }
        
        [self informLoginSuccessful:YES];
        
    } failure:^(NSError *error) {
        DLog(@"Error logging in: %@", [error localizedDescription]);
        
        // Reset the facebook button.
        [self.loginView loginFailed];
        
        [self informLoginSuccessful:NO];
    }];
}

- (void)informLoginSuccessful:(BOOL)success {
    
    // Remove the login view.
    self.loginView.hidden = success;
    
    [self loadMyBook];
    
    // Inform login successful.
    [EventHelper postLoginSuccessful:success];
    
}

- (void)openBookAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate openBookRequestedForBook:self.myBook];
}

- (void)unfollowBookAtIndexPath:(NSIndexPath *)indexPath {
    
    CKBook *book = [self.followBooks objectAtIndex:indexPath.item];
    CKUser *currentUser = [CKUser currentUser];
    
    // Kick off the immediate removal of the book onscreen.
    [self.followBooks removeObjectAtIndex:indexPath.item];
    [self.collectionView performBatchUpdates:^{
        if ([self.followBooks count] == 0) {
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
        } else {
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kFollowSection]];
        }
    } completion:^(BOOL finished) {
    }];
    
    // Unfollow in the background, then inform listeners of the update.
    [book removeFollower:currentUser
                 success:^{
                     [EventHelper postFollowUpdated];
                 } failure:^(NSError *error) {
                     DLog(@"Unable to unfollow.");
                 }];
    
}

- (void)followUpdated:(NSNotification *)notification {
    [self loadFollowBooks];
}

@end
