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

@interface SuggestedStoreCollectionViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation SuggestedStoreCollectionViewController

- (void)loadData {
    
    // TODO
    [self loadBooks:@[]];
    return;
    
    if ([[CKUser currentUser] isSignedIn]) {
        [super loadData];
        [CKBook facebookSuggestedBooksForUser:[CKUser currentUser]
                                      success:^(NSArray *suggestedBooks) {
                                          [self loadBooks:suggestedBooks];
                                      }
                                      failure:^(NSError *error) {
                                          DLog(@"Error: %@", [error localizedDescription]);
                                          [self showNoConnectionCardIfApplicableError:error];
                                      }];
    }
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO SUGGESTIONS" subtitle:@"USE SEARCH TO FIND PEOPLE YOU KNOW"
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

@end
