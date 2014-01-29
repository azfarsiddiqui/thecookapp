//
//  CategoriesStoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoriesStoreCollectionViewController.h"
#import "CardViewHelper.h"

@interface CategoriesStoreCollectionViewController ()

@end

@implementation CategoriesStoreCollectionViewController

- (void)loadData {
    [super loadData];
    [CKBook categoriesBooksForUser:[CKUser currentUser]
                           success:^(NSArray *featuredBooks) {
                               [self loadBooks:featuredBooks];
                           }
                           failure:^(NSError *error) {
                               [self showNoConnectionCardIfApplicableError:error];
                           }];
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO COLLECTIONS BOOKS" subtitle:@"PLEASE CHECK BACK SOON"
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

@end
