//
//  StoreCollectionViewController.h
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKBook;

@interface StoreCollectionViewController : UICollectionViewController

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSMutableArray *books;

- (void)enable:(BOOL)enable;
- (void)loadData;
- (void)unloadData;
- (void)loadBooks:(NSArray *)books;
- (void)reloadBooks;
- (BOOL)updateForFriendsBook:(BOOL)friendsBook;
- (UIView *)noDataView;

@end
