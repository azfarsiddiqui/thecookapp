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

@interface FriendsStoreCollectionViewController ()

@end

@implementation FriendsStoreCollectionViewController

- (void)loadData {
    
    CKUser *currentUser = [CKUser currentUser];
    if ([currentUser isSignedIn]) {
        [CKBook friendsBooksForUser:currentUser
                            success:^(NSArray *friendsBooks) {
                                self.books = [NSMutableArray arrayWithArray:friendsBooks];
                                [self reloadBooks];
                            }
                            failure:^(NSError *error) {
                                DLog(@"Error: %@", [error localizedDescription]);
                            }];
    }
}

@end
