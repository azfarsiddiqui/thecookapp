//
//  SuggestedStoreCollectionViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 7/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "SuggestedStoreCollectionViewController.h"
#import "CKBook.h"

@interface SuggestedStoreCollectionViewController ()

@end

@implementation SuggestedStoreCollectionViewController

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    if (!friendsBook) {
        return YES;
    } else {
        return [super updateForFriendsBook:friendsBook];
    }
}

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

- (BOOL)addMode {
    return NO;
}

@end
