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

- (void)loadData {
    [CKBook featuredBooksForUser:[CKUser currentUser]
                         success:^(NSArray *featuredBooks) {
                             self.books = [NSMutableArray arrayWithArray:featuredBooks];
                             
                             // Insert the books.
                             NSArray *insertIndexPaths = [self.books collectWithIndex:^id(CKBook *book, NSUInteger index) {
                                 return [NSIndexPath indexPathForItem:index inSection:0];
                             }];
                             [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
                         }
                         failure:^(NSError *error) {
                            DLog(@"Error: %@", [error localizedDescription]);
                         }];
}

@end
