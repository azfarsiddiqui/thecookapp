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
#import "SocialMediaActionHeader.h"
#import "StoreFlowLayout.h"
#import "StoreBookCoverViewCell.h"

@interface FriendsStoreCollectionViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation FriendsStoreCollectionViewController

#define kFacebookSection 1
#define kHeaderIdentifier @"SocialHeader"

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    if (friendsBook) {
        return YES;
    } else {
        return [super updateForFriendsBook:friendsBook];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[SocialMediaActionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderIdentifier];
}

- (void)loadData {
    [super loadData];
    [CKBook friendsBooksForUser:[CKUser currentUser]
                         success:^(NSArray *featuredBooks) {
                             self.books = [NSMutableArray arrayWithArray:featuredBooks];
                             [self fetchFacebookFriendBooks];
                         }
                         failure:^(NSError *error) {
                             DLog(@"Error: %@", [error localizedDescription]);
                             [self showNoConnectionCardIfApplicableError:error];
                         }];
}

- (void)signInFacebook {
    CKUser *currentUser = [CKUser currentUser];
    if (!currentUser.facebookId)
    {
        [CKUser attachFacebookToCurrentUserWithSuccess:^{
            [self fetchFacebookFriendBooks];
        } failure:^(NSError *error) {
            [self errorInFriendFetchWithMessage:@"There was an error in signing into Facebook"];
        }];
    } else
    {
        [self fetchFacebookFriendBooks];
    }
}

- (void)fetchFacebookFriendBooks {
    [CKBook suggestedBooksForUser:[CKUser currentUser] success:^(NSArray *results) {
        //Mark books as suggested
        [results enumerateObjectsUsingBlock:^(CKBook *book, NSUInteger idx, BOOL *stop) {
            book.status = kBookStatusFBSuggested;
        }];
        //Add results to self.books and load
        [self.books addObjectsFromArray:results];
        [self loadBooks:self.books];
    } failure:^(NSError *error) {
        [self errorInFriendFetchWithMessage:@"There was an error in getting your friends from Facebook"];
    }];
}

- (BOOL)featuredMode {
    return NO;
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO FRIENDS" subtitle:@"USE SEARCH TO FIND PEOPLE YOU KNOW"
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

- (void)errorInFriendFetchWithMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - CollectionView delegate and datasource method overrides

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    //Hide first section header, other sections are attach to Facebook
    if (section == kStoreSection)
    {
        return CGSizeZero;
    }
    else
        return CGSizeMake(self.collectionView.frame.size.width - 240, self.collectionView.frame.size.height);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (![CKUser currentUser].facebookId && [self.books count] == 0)
        return 2; //Only show sign-in to facebook section header if not Facebook and no friends
    else
        return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (section == kStoreSection)
        return [self.books count];
    else
        return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SocialMediaActionHeader *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderIdentifier forIndexPath:indexPath];
    headerView.completionBlock = ^{
        [self signInFacebook];
        //Check if already signed in, do a refresh of friends books if so
    };
    return headerView;
}

@end
