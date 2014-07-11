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
    [CKBook featuredBooksForUser:self.currentUser
                         success:^(NSArray *featuredBooks) {
                             [self loadBooks:featuredBooks];
                         }
                         failure:^(NSError *error) {
                             [self showNoConnectionCardIfApplicableError:error];
                         }];
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:NSLocalizedString(@"NO FEATURED BOOKS", nil)
                                         subtitle:NSLocalizedString(@"PLEASE CHECK BACK SOON", nil)
                                             view:self.collectionView show:YES center:self.collectionView.center];
}

@end
