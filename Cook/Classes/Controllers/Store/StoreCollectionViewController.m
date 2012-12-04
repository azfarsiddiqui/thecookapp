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
#import "BenchtopBookCoverViewCell.h"
#import "CKBook.h"
#import "CKBookCoverView.h"
#import "EventHelper.h"
#import "MRCEnumerable.h"

@interface StoreCollectionViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation StoreCollectionViewController

#define kCellId         @"StoreBookCellId"
#define kStoreSection   0

- (void)dealloc {
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterFollowUpdated:self];
}

- (id)init {
    if (self = [super initWithCollectionViewLayout:[[StoreFlowLayout alloc] init]]) {
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
    [self.collectionView registerClass:[BenchtopBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
    
    [EventHelper registerLoginSucessful:self selector:@selector(loginSuccessful:)];
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

- (void)loadBooks:(NSArray *)books {
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
    
}

- (void)reloadBooks {
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:kStoreSection]];
}

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    return NO;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil
                                               destructiveButtonTitle:nil otherButtonTitles:@"Follow", @"Open", nil];
    actionSheet.delegate = self;
    [actionSheet showFromRect:cell.frame inView:collectionView animated:YES];
    self.selectedIndexPath = indexPath;
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
    BenchtopBookCoverViewCell *cell = (BenchtopBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                             forIndexPath:indexPath];
    [cell loadBook:[self.books objectAtIndex:indexPath.item]];
    return cell;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"Item %d", buttonIndex);
    switch (buttonIndex) {
        case 0:
            [self followBookAtIndexPath:self.selectedIndexPath];
            break;
        case 1:
            [self openBookAtIndexPath:self.selectedIndexPath];
            break;
        default:
            break;
    }
}

#pragma mark - Private methods

- (void)loginSuccessful:(NSNotification *)notification {
    BOOL success = [EventHelper loginSuccessfulForNotification:notification];
    if (success) {
        [self loadData];
    }
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
    BOOL friendsBook = [book friendsBook];
    [book addFollower:currentUser
              success:^{
                  [EventHelper postFollowUpdatedForFriends:friendsBook];
             } failure:^(NSError *error) {
                 DLog(@"Unable to follow.");
             }];
}

- (void)openBookAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - Private methods

- (void)followUpdated:(NSNotification *)notification {
    BOOL friendsBook = [EventHelper friendsBookFollowUpdatedForNotification:notification];
    if ([self updateForFriendsBook:friendsBook]) {
        [self loadData];
    }
}

@end
