//
//  FeaturedStoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 30/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "FeaturedStoreCollectionViewController.h"
#import "CKBook.h"
#import "MRCEnumerable.h"
#import "CardViewHelper.h"

@interface FeaturedStoreCollectionViewController ()

@end

@implementation FeaturedStoreCollectionViewController

- (void)loadData {
    [super loadData];
    [CKBook featuredBooksForUser:[CKUser currentUser]
                         success:^(NSArray *featuredBooks) {
                             [self loadBooks:featuredBooks];
                         }
                         failure:^(NSError *error) {
                             [self showNoConnectionCardIfApplicableError:error];
                         }];
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO FEATURED BOOKS" subtitle:@"PLEASE CHECK BACK SOON"
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

@end
