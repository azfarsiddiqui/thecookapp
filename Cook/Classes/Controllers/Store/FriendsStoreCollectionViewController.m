//
//  FriendsStoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 30/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "FriendsStoreCollectionViewController.h"
#import "CKBook.h"
#import "CKUser.h"
#import "EventHelper.h"
#import "CardViewHelper.h"
#import "MRCEnumerable.h"
#import "CKBookCoverView.h"
#import "ViewHelper.h"
#import "AppHelper.h"
#import "StoreFlowLayout.h"
#import "StoreBookCoverViewCell.h"
#import "CKContentContainerCell.h"
#import "FacebookSuggestButtonView.h"

@interface FriendsStoreCollectionViewController () <UICollectionViewDelegateFlowLayout, FacebookSuggestButtonViewDelegate>

@property (nonatomic, strong) FacebookSuggestButtonView *facebookButtonView;

@end

@implementation FriendsStoreCollectionViewController

#define kFacebookCellId     @"FacebookCellId"

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    if (friendsBook) {
        return YES;
    } else {
        return [super updateForFriendsBook:friendsBook];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[CKContentContainerCell class] forCellWithReuseIdentifier:kFacebookCellId];
}

- (void)loadData {
    
    if ([[CKUser currentUser] isSignedIn]) {
        [super loadData];
        [CKBook friendsAndSuggestedBooksForUser:[CKUser currentUser]
                                        success:^(NSArray *friendsSuggestedBooks) {
                                            [self loadBooks:friendsSuggestedBooks];
                                        }
                                        failure:^(NSError *error) {
                                            DLog(@"Error: %@", [error localizedDescription]);
                                            [self showNoConnectionCardIfApplicableError:error];
                                        }];
    }
}

- (void)insertBooks {
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithArray:[self.books collectWithIndex:^id(CKBook *book, NSUInteger index) {
        return [NSIndexPath indexPathForItem:index inSection:0];
    }]];
    
    if (self.books && ![[CKUser currentUser] isFacebookUser]) {
        [insertIndexPaths addObject:[NSIndexPath indexPathForItem:[insertIndexPaths count] inSection:0]];
    }
    
    [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
}

- (void)signInFacebook {
    CKUser *currentUser = [CKUser currentUser];
    if (![currentUser isFacebookUser]) {
        [CKUser attachFacebookToCurrentUserWithSuccess:^{
            
            [self.facebookButtonView enableActivity:NO];
            [self unloadDataCompletion:^{
                [self loadData];
            }];
            
        } failure:^(NSError *error) {
            [self.facebookButtonView enableActivity:NO];
            [self errorInFriendFetchWithTitle:@"Couldn't Add" message:@"Facebook account has already been registered."];
        }];
    }
}

- (void)showNoBooksCard {
    CKUser *currentUser = [CKUser currentUser];
    if ([currentUser isFacebookUser]) {
        [[CardViewHelper sharedInstance] showCardText:@"NO FRIENDS" subtitle:@"USE SEARCH TO FIND PEOPLE YOU KNOW"
                                                 view:self.collectionView show:YES center:self.collectionView.center];
    }
}

- (void)errorInFriendFetchWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - FacebookSuggestionButtonViewDelegate methods

- (void)facebookSuggestButtonViewTapped {
    [self.facebookButtonView enableActivity:YES];
    [self signInFacebook];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = [super collectionView:collectionView numberOfItemsInSection:section];
    
    // Extra facebook button if not linked to facebook.
    CKUser *currentUser = [CKUser currentUser];
    if (self.dataLoaded && currentUser && ![currentUser isFacebookUser]) {
        numItems += 1;
    }
    
    return numItems;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize headerSize = CGSizeZero;
    
    CKUser *currentUser = [CKUser currentUser];
    if (self.dataLoaded && ([self.books count] == 0) && ![currentUser isFacebookUser]) {
        headerSize = (CGSize) {
            floorf((collectionView.bounds.size.width - self.facebookButtonView.frame.size.width) / 2.0) - floorf(self.facebookButtonView.frame.size.width / 2.0) + 18,
            0.0
        };
    }
    
    return headerSize;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == [self.books count]) {
        return NO;
    } else {
        return YES;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == [self.books count]) {
        return self.facebookButtonView.frame.size;
    } else {
        return [StoreBookCoverViewCell cellSize];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    if (indexPath.item == [self.books count]) {
        
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

@end
