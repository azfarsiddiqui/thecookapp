//
//  StoreCollectionViewController.h
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreBookCoverViewCell.h"

@class CKBook;
@class CKUser;

@protocol StoreCollectionViewControllerDelegate

- (void)storeCollectionViewControllerPanRequested:(BOOL)enabled;

@end

@interface StoreCollectionViewController : UICollectionViewController <StoreBookCoverViewCellDelegate>

#define kCellId         @"StoreBookCellId"
#define kStoreSection   0

@property (nonatomic, strong) CKUser *currentUser;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL dataLoaded;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) NSMutableArray *books;

- (id)initWithDelegate:(id<StoreCollectionViewControllerDelegate>)delegate;
- (void)enable:(BOOL)enable;
- (void)loadData;
- (void)unloadData;
- (void)unloadDataCompletion:(void(^)())completion;
- (void)purgeData;
- (void)loadBooks;
- (void)loadBooks:(NSArray *)books;
- (void)reloadBooks;
- (void)insertBooks;
- (BOOL)updateForFriendsBook:(BOOL)friendsBook;
- (void)showActivity:(BOOL)show;
- (void)showNoConnectionCardIfApplicableError:(NSError *)error;
- (void)showNoBooksCard;
- (void)hideMessageCard;

// Lifecyle of logged in/out
- (void)isLoggedIn;
- (void)isLoggedOut;

//Subclass accessed methods and properties
@property (nonatomic, strong) UICollectionViewCell *selectedBookCell;

- (void)loadRemoteIllustrationAtIndex:(NSUInteger)bookIndex;
- (void)showBook:(CKBook *)book atIndexPath:(NSIndexPath *)indexPath;

@end
