//
//  SuggestedStoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "SuggestedStoreCollectionViewController.h"
#import "CKBook.h"
#import "CardViewHelper.h"

@interface SuggestedStoreCollectionViewController ()

@end

@implementation SuggestedStoreCollectionViewController

- (void)loadData {
    [super loadData];
    [CKBook suggestedBooksForUser:[CKUser currentUser]
                         success:^(NSArray *featuredBooks) {
                             [self loadBooks:featuredBooks];
                         }
                         failure:^(NSError *error) {
                             DLog(@"Error: %@", [error localizedDescription]);
                             [self showNoConnectionCardIfApplicableError:error];
                         }];
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO SUGGESTIONS" subtitle:@"MORE WAYS TO FIND FRIENDS SOON"
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

@end
