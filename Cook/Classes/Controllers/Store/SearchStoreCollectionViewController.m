//
//  SearchStoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "SearchStoreCollectionViewController.h"
#import "CKUser.h"
#import "CKBook.h"
#import "CardViewHelper.h"
#import "AnalyticsHelper.h"

@interface SearchStoreCollectionViewController ()

@end

@implementation SearchStoreCollectionViewController

- (void)loadData {
    [super loadData];
    [self showActivity:NO];
}

- (void)searchByKeyword:(NSString *)keyword {
    DLog(@"keyword: %@", keyword);
    
    [self hideMessageCard];
    [self unloadData];
    [self showActivity:YES];
    
    [CKBook searchBooksByKeyword:keyword
                         success:^(NSArray *results) {
                             [self loadBooks:results];
                         }
                         failure:^(NSError *error) {
                             [self showNoBooksCard];
                             [self showActivity:NO];
                         }];
    
    [AnalyticsHelper trackEventName:kEventSearch];
    
}

- (void)showNoBooksCard {
    [[CardViewHelper sharedInstance] showCardText:@"NO RESULTS" subtitle:@"TRY SEARCHING FOR ANOTHER NAME"
                        view:self.collectionView show:YES center:self.collectionView.center];
}

@end
