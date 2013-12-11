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
#import "CardViewHelper.h"

@interface FriendsStoreCollectionViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation FriendsStoreCollectionViewController

- (void)loadData {
    
    if ([self.currentUser isSignedIn]) {
        [super loadData];
        [CKBook friendsBooksForUser:self.currentUser
                            success:^(NSArray *friendsSuggestedBooks) {
                                [self loadBooks:friendsSuggestedBooks];
                            }
                            failure:^(NSError *error) {
                                DLog(@"Error: %@", [error localizedDescription]);
                                [self showNoConnectionCardIfApplicableError:error];
                            }];
        
    } else {
        [self showSignInCard];
    }
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO FRIENDS" subtitle:@"USE SEARCH TO FIND PEOPLE YOU KNOW"
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

- (void)showSignInCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO FRIENDS" subtitle:@"SIGN IN TO ADD FRIENDS"
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

@end
