//
//  StoreCollectionViewController.h
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreCollectionViewController : UICollectionViewController

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSMutableArray *books;

- (void)enable:(BOOL)enable;
- (void)loadData;
- (void)loadBooks:(NSArray *)books;
- (void)reloadBooks;
- (BOOL)updateForFriendsBook:(BOOL)friendsBook;

@end
