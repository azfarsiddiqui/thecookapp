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
#import "EventHelper.h"
#import "AppHelper.h"
#import "MRCEnumerable.h"
#import "StoreBookViewController.h"
#import "CKActivityIndicatorView.h"
#import "CKServerManager.h"
#import "ViewHelper.h"

@interface StoreCollectionViewController () <UIActionSheetDelegate, StoreBookCoverViewCellDelegate,
    StoreBookViewControllerDelegate>

@property (nonatomic, assign) id<StoreCollectionViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *emptyBanner;
@property (nonatomic, strong) StoreBookViewController *storeBookViewController;
@property (nonatomic, strong) UICollectionViewCell *selectedBookCell;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;

@end

@implementation StoreCollectionViewController

#define kCellId         @"StoreBookCellId"
#define kStoreSection   0

- (void)dealloc {
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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[StoreBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
    
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
    // Subclasses to extend.
    [self showActivity:YES];
    [self hideMessageCard];
}

- (void)unloadData {
    [self unloadDataCompletion:nil];
}

- (void)unloadDataCompletion:(void(^)())completion {
    DLog(@"Unloading Books [%d]", [self.books count]);
    [self hideMessageCard];
    if ([self.books count] > 0) {
        [self.books removeAllObjects];
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished){
            if (completion != nil) {
                completion();
            }
        }];
    }
}

- (void)loadBooks:(NSArray *)books {
    DLog(@"Books [%d] Existing [%d]", [books count], [self.books count]);
    
    [self showActivity:NO];
    
    // Hide any message cards.
    [self hideMessageCard];
    
    if ([books count] > 0) {
        
        BOOL reloadBooks = [self.books count] > 0;
        self.books = [NSMutableArray arrayWithArray:books];
        
        if (reloadBooks) {
            
            [self reloadBooks];
            
        } else {
            
            // Insert the books.
            NSArray *insertIndexPaths = [books collectWithIndex:^id(CKBook *book, NSUInteger index) {
                return [NSIndexPath indexPathForItem:index inSection:0];
            }];
            
            [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
        }
        
        
    } else {
        
        // Show no books card.
        [self showNoBooksCard];
        
    }
    
}

- (void)reloadBooks {
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kStoreSection]];
}

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    return NO;
}

- (BOOL)addMode {
    return NO;
}

- (void)showActivity:(BOOL)show {
    if (show) {
        self.activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        self.activityView.center = self.collectionView.center;
        [self.collectionView addSubview:self.activityView];
        [self.activityView startAnimating];
    } else {
        [self.activityView stopAnimating];
        [self.activityView removeFromSuperview];
        self.activityView = nil;
    }
}

- (void)showNoConnectionCardIfApplicableError:(NSError *)error {
    if ([[CKServerManager sharedInstance] noConnectionError:error]) {
        [ViewHelper showNoConnectionCard:YES view:self.collectionView center:self.collectionView.center];
        [self showActivity:NO];
    }
}

- (void)showNoBooksCard {
    DLog();
}

- (void)hideMessageCard {
    [ViewHelper hideCardInView:self.collectionView];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [self showBookAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [StoreBookCoverViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15.0, 60.0, 0.0, 0.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 25.0;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    DLog(@"Books Count: %d", [self.books count]);
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

- (void)storeBookViewControllerUpdatedBook:(CKBook *)book {
    book.followed = YES;
    NSUInteger updatedBookIndex = [self.books indexOfObject:book];
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:updatedBookIndex
                                                                                              inSection:0]]];
}

#pragma mark - Private methods

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

- (void)showBookAtIndexPath:(NSIndexPath *)indexPath {
    UIView *rootView = [[AppHelper sharedInstance] rootView];
    
    // Remember the cell to transition from.
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    cell.hidden = YES;
    self.selectedBookCell = cell;
    
    // Determine the point to transition from.
    CGPoint pointAtRootView = [self.collectionView convertPoint:cell.center toView:rootView];
    
    CKBook *book = [self.books objectAtIndex:indexPath.row];
    [self.delegate storeCollectionViewControllerPanRequested:NO];
    
    StoreBookViewController *storeBookViewController = [[StoreBookViewController alloc] initWithBook:book
                                                                                             addMode:[self addMode]
                                                                                            delegate:self];
    [rootView addSubview:storeBookViewController.view];
    [storeBookViewController transitionFromPoint:pointAtRootView];
    self.storeBookViewController = storeBookViewController;
}

- (void)closeBook {
    [self.storeBookViewController.view removeFromSuperview];
    self.storeBookViewController = nil;
    self.selectedBookCell.hidden = NO;
    [self.delegate storeCollectionViewControllerPanRequested:YES];
}

@end
