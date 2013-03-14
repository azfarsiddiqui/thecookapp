//
//  StoreCollectionViewController.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreCollectionViewController.h"
#import "StoreFlowLayout.h"
#import "StoreBookCoverViewCell.h"
#import "CKBook.h"
#import "CKBookCoverView.h"
#import "BookViewController.h"
#import "EventHelper.h"
#import "AppHelper.h"
#import "MRCEnumerable.h"
#import "StoreBookViewController.h"

@interface StoreCollectionViewController () <UIActionSheetDelegate, StoreBookCoverViewCellDelegate,
    StoreBookViewControllerDelegate>

@property (nonatomic, assign) id<StoreCollectionViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *emptyBanner;
@property (nonatomic, strong) BookViewController *bookViewController;
@property (nonatomic, strong) StoreBookViewController *storeBookViewController;

@end

@implementation StoreCollectionViewController

#define kCellId         @"StoreBookCellId"
#define kStoreSection   0

- (void)dealloc {
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
    [EventHelper unregisterFollowUpdated:self];
}

- (id)initWithDelegate:(id<StoreCollectionViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[StoreFlowLayout alloc] init]]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[StoreBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
    
    [EventHelper registerLoginSucessful:self selector:@selector(loginSuccessful:)];
    [EventHelper registerLogout:self selector:@selector(loggedOut:)];
    [EventHelper registerFollowUpdated:self selector:@selector(followUpdated:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)enable:(BOOL)enable {
    self.enabled = enable;
}

- (void)loadData {
    // Subclasses to implement.
}

- (void)unloadData {
    DLog(@"Unloading Books [%d]", [self.books count]);
    if ([self.books count] > 0) {
        
        NSArray *deletedIndexPaths = [self.books collectWithIndex:^id(CKBook *book, NSUInteger index) {
            return [NSIndexPath indexPathForItem:index inSection:0];
        }];
        [self.books removeAllObjects];
        [self.collectionView deleteItemsAtIndexPaths:deletedIndexPaths];
    }
}

- (void)loadBooks:(NSArray *)books {
    DLog(@"Books [%d] Existing [%d]", [books count], [self.books count]);
    
    // Remove the no data view immediately if there were any books to be loaded.
    if ([books count] > 0) {
        [self.emptyBanner removeFromSuperview];
        self.emptyBanner = nil;
    }
    
    if ([self.books count] > 0) {
        
        // Reload the books.
        [self.books removeAllObjects];
        self.books = [NSMutableArray arrayWithArray:books];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        
    } else {
        
        self.books = [NSMutableArray arrayWithArray:books];
        
        // Insert the books.
        NSArray *insertIndexPaths = [books collectWithIndex:^id(CKBook *book, NSUInteger index) {
            return [NSIndexPath indexPathForItem:index inSection:0];
        }];
        [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
        
    }
    
    [self updateNoDataView];
}

- (void)reloadBooks {
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kStoreSection]];
}

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    return NO;
}

- (UIView *)noDataView {
    // Subclasses to implement.
    return nil;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
    
    CKBook *selectedBook = [self.books objectAtIndex:indexPath.row];
    [self showBook:selectedBook];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [StoreBookCoverViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return -120.0;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.books count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StoreBookCoverViewCell *cell = (StoreBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                             forIndexPath:indexPath];
    cell.delegate = self;
    [cell loadBook:[self.books objectAtIndex:indexPath.item]];
    return cell;
}

#pragma mark - StoreBookCoverViewCellDelegate methods

- (void)storeBookFollowTappedForCell:(UICollectionViewCell *)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self followBookAtIndexPath:indexPath];
}

#pragma mark - StoreBookViewControllerDelegate methods

- (void)storeBookViewControllerCloseRequested {
    [self closeBook];
}

#pragma mark - Private methods

- (void)loginSuccessful:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
        [self loadData];
    }
}

- (void)loggedOut:(NSNotification *)notification {
    [self unloadData];
}

- (void)followBookAtIndexPath:(NSIndexPath *)indexPath {
    CKBook *book = [self.books objectAtIndex:indexPath.item];
    CKUser *currentUser = [CKUser currentUser];
    
    // Remove the book immediately. 
    [self.books removeObjectAtIndex:indexPath.item];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    } completion:^(BOOL finished) {
        [self updateNoDataView];
    }];
    
    // Then follow in the background.
    BOOL isFriendsBook = [book isThisMyFriendsBook];
    [book addFollower:currentUser
              success:^{
                  [EventHelper postFollow:YES friends:isFriendsBook];
             } failure:^(NSError *error) {
                 DLog(@"Unable to follow.");
             }];
}

- (void)openBookAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - Private methods

- (void)followUpdated:(NSNotification *)notification {
    BOOL follow = [EventHelper followForNotification:notification];
    BOOL friendsBook = [EventHelper friendsBookFollowUpdatedForNotification:notification];
    if (!follow && [self updateForFriendsBook:friendsBook]) {
        [self loadData];
    }
}

- (void)updateNoDataView {
    
    // Empty banner if no books to load.
    if ([self.books count] == 0) {
        [self.emptyBanner removeFromSuperview];
        
        UIView *emptyBanner = [self noDataView];
        if (emptyBanner) {
            emptyBanner.frame = CGRectMake(floorf((self.view.bounds.size.width - emptyBanner.frame.size.width) / 2.0),
                                           floorf((self.view.bounds.size.height - emptyBanner.frame.size.height) / 2.0) + 47.0,
                                           emptyBanner.frame.size.width,
                                           emptyBanner.frame.size.height);
            [self.view addSubview:emptyBanner];
            emptyBanner.alpha = 0.0;
            self.emptyBanner = emptyBanner;
        }
        
        // Fade it in.
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             self.emptyBanner.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
        
    }
}

- (void)showBook:(CKBook *)book {
    [self.delegate storeCollectionViewControllerPanRequested:NO];
    
    UIView *rootView = [[AppHelper sharedInstance] rootView];
    StoreBookViewController *storeBookViewController = [[StoreBookViewController alloc] initWithBook:book delegate:self];
    storeBookViewController.view.alpha = 0.0;
    [rootView addSubview:storeBookViewController.view];
    self.storeBookViewController = storeBookViewController;
    
    // Fade it in.
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.storeBookViewController.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)closeBook {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.storeBookViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.storeBookViewController.view removeFromSuperview];
                         self.storeBookViewController = nil;
                         [self.delegate storeCollectionViewControllerPanRequested:YES];
                     }];
}

@end
