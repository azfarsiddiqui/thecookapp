//
//  SuggestedStoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "SuggestedStoreCollectionViewController.h"
#import "CKBook.h"
#import "CKUser.h"
#import "CardViewHelper.h"
#import "CKContentContainerCell.h"
#import "FacebookSuggestButtonView.h"
#import "MRCEnumerable.h"
#import "ViewHelper.h"

@interface SuggestedStoreCollectionViewController () <UICollectionViewDelegateFlowLayout,
    FacebookSuggestButtonViewDelegate>

@property (nonatomic, strong) FacebookSuggestButtonView *facebookButtonView;
@property (nonatomic, assign) BOOL facebookConnected;

@end

@implementation SuggestedStoreCollectionViewController

#define kFacebookCellId     @"FacebookCellId"

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[CKContentContainerCell class] forCellWithReuseIdentifier:kFacebookCellId];
}

- (void)loadData {
    
    if ([self.currentUser isFacebookUser]) {
        [super loadData];
        [CKBook facebookSuggestedBooksForUser:self.currentUser
                                      success:^(NSArray *suggestedBooks) {
                                          [self loadBooks:suggestedBooks];
                                      }
                                      failure:^(NSError *error) {
                                          DLog(@"Error: %@", [error localizedDescription]);
                                          [self showNoConnectionCardIfApplicableError:error];
                                      }];
        
    } else if ([self.currentUser isSignedIn] && FBSession.activeSession.isOpen) {
        
        // Only fetch when signed in.
        [self fetchFacebookFriends];
    }
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO SUGGESTIONS"
                                         subtitle:@"USE SEARCH TO FIND PEOPLE YOU KNOW"
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

- (void)isLoggedIn {
    [super isLoggedIn];
    
    // Make sure we reload to remove FB+ if applicable.
    [self.collectionView reloadData];
}

- (void)isLoggedOut {
    [super isLoggedOut];
    
    if (self.facebookConnected) {
        [FBSession.activeSession closeAndClearTokenInformation];
        self.facebookConnected = NO;
    }
    
    [self.collectionView reloadData];
}

#pragma mark - FacebookSuggestionButtonViewDelegate methods

- (void)facebookSuggestButtonViewTapped {
    [self.facebookButtonView enableActivity:YES];
    [self connectAndFetchFacebookFriends];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([self showFacebookFetchIcon]) {
        return 1;
    } else {
        return [super collectionView:collectionView numberOfItemsInSection:section];
    }
    
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {

    CGSize headerSize = CGSizeZero;

    if ([self showFacebookFetchIcon]) {
        
        headerSize = (CGSize) {
            floorf((collectionView.bounds.size.width - self.facebookButtonView.frame.size.width) / 2.0) - floorf(self.facebookButtonView.frame.size.width / 2.0) + 18,
            0.0
        };
    }

    return headerSize;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self showFacebookFetchIcon]) {
        return NO;
    } else {
        return YES;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self showFacebookFetchIcon]) {
        return self.facebookButtonView.frame.size;
    } else {
        return [StoreBookCoverViewCell cellSize];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if ([self showFacebookFetchIcon]) {
        
        CKContentContainerCell *facebookCell = (CKContentContainerCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kFacebookCellId
                                                                                                                   forIndexPath:indexPath];
        [facebookCell configureContentView:self.facebookButtonView];
        cell = facebookCell;
        
    } else {
        cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Properties

- (FacebookSuggestButtonView *)facebookButtonView {
    if (!_facebookButtonView) {
        _facebookButtonView = [[FacebookSuggestButtonView alloc] initWithDelegate:self];
    }
    return _facebookButtonView;
}

#pragma mark - Private methods

- (void)connectAndFetchFacebookFriends {
    
    if (FBSession.activeSession.isOpen) {
        [self fetchFacebookFriends];
    } else {
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (session.isOpen) {
                                              [self fetchFacebookFriends];
                                          } else if (status == FBSessionStateClosedLoginFailed) {
                                              [self handleFacebookError:error];
                                          }
                                      }];
    }
}

- (void)fetchFacebookFriends {
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection,
                                                                  NSDictionary *jsonDictionary, NSError *error) {
        
        [self.facebookButtonView enableActivity:NO];
        
        if (!error) {
            
            // Mark as facebook connected and remove the FB icon.
            self.facebookConnected = YES;
            [self.collectionView reloadData];
            [super loadData];
            
            // Grab the facebook ids of friends.
            NSArray *friendIds = [[jsonDictionary objectForKey:@"data"] collect:^id(NSDictionary<FBGraphUser> *friendData) {
                return [friendData objectForKey:@"id"];
            }];
            
            // Now call our endpoint to check Cook accounts for facebook Ids.
            [CKBook facebookSuggestedBooksForFacebookIds:friendIds
                                                 success:^(NSArray *suggestedBooks) {
                                                     [self loadBooks:suggestedBooks];
                                                 }
                                                 failure:^(NSError *error) {
                                                     DLog(@"Error: %@", [error localizedDescription]);
                                                     [self showNoConnectionCardIfApplicableError:error];
                                                 }];
        } else {
            [self handleFacebookError:error];
        }
        
    }];
}

- (void)handleFacebookError:(NSError *)error {
    DLog(@"Error: %@", [error localizedDescription]);
    if ([CKUser isFacebookPermissionsError:error]) {
        [ViewHelper alertWithTitle:@"Permission Required" message:@"Go to iPad Settings > Facebook and turn on for Cook"];
    } else {
        [ViewHelper alertWithTitle:@"Couldn't Connect" message:nil];
    }
    [self.facebookButtonView enableActivity:NO];
}

- (BOOL)showFacebookFetchIcon {
    return ([self.currentUser isSignedIn] && !self.facebookConnected && ![self.currentUser isFacebookUser]);
}

@end
