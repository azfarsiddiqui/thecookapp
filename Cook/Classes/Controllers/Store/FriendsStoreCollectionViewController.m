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
    [[CardViewHelper sharedInstance] showCardText:NSLocalizedString(@"NO FRIENDS", nil)
                                         subtitle:NSLocalizedString(@"USE SEARCH TO FIND PEOPLE YOU KNOW", nil)
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

- (void)showSignInCard {
    [[CardViewHelper sharedInstance] showCardText:NSLocalizedString(@"NO FRIENDS", nil)
                                         subtitle:NSLocalizedString(@"SIGN IN TO ADD FRIENDS", nil)
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

@end
