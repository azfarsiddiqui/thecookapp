//
//  WorldStoreViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "WorldStoreCollectionViewController.h"
#import "CardViewHelper.h"

@interface WorldStoreCollectionViewController ()

@end

@implementation WorldStoreCollectionViewController

- (void)loadData {
    [super loadData];
    [CKBook worldBooksForUser:self.currentUser
                      success:^(NSArray *featuredBooks) {
                          [self loadBooks:featuredBooks];
                      }
                      failure:^(NSError *error) {
                          DLog(@"Error: %@", [error localizedDescription]);
                          [self showNoConnectionCardIfApplicableError:error];
                      }];
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:NSLocalizedString(@"NO WORLD BOOKS", nil)
                                         subtitle:NSLocalizedString(@"PLEASE CHECK BACK SOON", nil)
                                             view:self.collectionView show:YES center:self.collectionView.center];
}


@end
