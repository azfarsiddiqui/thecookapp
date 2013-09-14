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
#import "ViewHelper.h"

@interface FriendsStoreCollectionViewController ()

@end

@implementation FriendsStoreCollectionViewController

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    if (friendsBook) {
        return YES;
    } else {
        return [super updateForFriendsBook:friendsBook];
    }
}

- (void)loadData {
    [super loadData];
    [CKBook friendsBooksForUser:[CKUser currentUser]
                         success:^(NSArray *featuredBooks) {
                             [self loadBooks:featuredBooks];
                         }
                         failure:^(NSError *error) {
                             DLog(@"Error: %@", [error localizedDescription]);
                             [self showNoConnectionCardIfApplicableError:error];
                         }];
}

- (BOOL)addMode {
    return YES;
}

- (void)showNoBooksCard {
    [ViewHelper showCardText:@"NO FRIENDS" subtitle:@"USE SEARCH TO FIND PEOPLE YOU KNOW"
                        view:self.collectionView show:YES center:self.collectionView.center];
}

@end
