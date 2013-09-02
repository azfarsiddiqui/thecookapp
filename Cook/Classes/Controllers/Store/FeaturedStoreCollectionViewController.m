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

@interface FeaturedStoreCollectionViewController ()

@end

@implementation FeaturedStoreCollectionViewController

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    if (!friendsBook) {
        return YES;
    } else {
        return [super updateForFriendsBook:friendsBook];
    }
}

- (void)loadData {
    [super loadData];
    [CKBook featuredBooksForUser:[CKUser currentUser]
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

@end
