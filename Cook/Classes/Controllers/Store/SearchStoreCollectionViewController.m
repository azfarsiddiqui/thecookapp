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

@interface SearchStoreCollectionViewController ()

@end

@implementation SearchStoreCollectionViewController

- (void)searchByKeyword:(NSString *)keyword {
    DLog(@"keyword: %@", keyword);
    
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
}

- (BOOL)addMode {
    return NO;
}

@end
