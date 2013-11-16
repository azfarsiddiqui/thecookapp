//
//  StoreCollectionViewController.m
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import "StoreCollectionViewController.h"
#import "StoreBookViewController.h"
#import "StoreFlowLayout.h"
#import "CKBook.h"
#import "CKBookCoverView.h"
#import "EventHelper.h"
#import "AppHelper.h"
#import "MRCEnumerable.h"
#import "CKActivityIndicatorView.h"
#import "CKServerManager.h"
#import "ViewHelper.h"
#import "CardViewHelper.h"
#import "CKPhotoManager.h"
#import "CKBookCover.h"

@interface StoreCollectionViewController () <UIActionSheetDelegate, StoreBookViewControllerDelegate>

@property (nonatomic, strong) UIView *emptyBanner;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;
@property (nonatomic, strong) NSMutableArray *bookCoverImages;
@property (nonatomic, strong) NSMutableArray *bookCovers;
@property (nonatomic, strong) StoreBookViewController *storeBookViewController;
@property (nonatomic, assign) id<StoreCollectionViewControllerDelegate> delegate;

@end

@implementation StoreCollectionViewController

- (void)dealloc {
    [EventHelper unregisterFollowUpdated:self];
    [EventHelper unregisterPhotoLoading:self];
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
    [self.collectionView registerClass:[StoreBookCoverViewCell class] forCellWithReuseIdentifier:kCellId];
    
    [EventHelper registerFollowUpdated:self selector:@selector(followUpdated:)];
    [EventHelper registerPhotoLoading:self selector:@selector(photoLoadingReceived:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)enable:(BOOL)enable {
    self.enabled = enable;
}

- (void)loadData {
    if (self.loading) {
        return;
    }
    self.loading = YES;
    [self showActivity:YES];
    [self hideMessageCard];
}

- (void)unloadData {
    [self unloadDataCompletion:nil];
}

- (void)unloadDataCompletion:(void(^)())completion {
    DLog(@"Unloading Books [%d]", [self.books count]);
    self.dataLoaded = NO;
    [self.collectionView reloadData];
    
    if (completion != nil) {
        completion();
    }
}

- (void)purgeData {
    [self unloadData];
    [self.books removeAllObjects];
    [self.bookCoverImages removeAllObjects];
    [self.bookCovers removeAllObjects];
    self.books = nil;
    self.bookCoverImages = nil;
    self.bookCovers = nil;
}

- (void)loadBooks {
    
    if (self.books && [self.books count] > 0) {
        
        [self showActivity:YES];
        
        // Load books in next runloop to ensure spinner gets shown.
        [self performSelector:@selector(loadBooks:) withObject:self.books afterDelay:0.0];
        
    } else {
        
        [self loadData];
    }
}

- (void)loadBooks:(NSArray *)books {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    DLog(@"Books [%d] Existing [%d]", [books count], [self.books count]);
    
    // Hide any message cards.
    [self hideMessageCard];
    
    // Mark books as loaded.
    self.dataLoaded = YES;
    
    if ([books count] > 0) {
        
        self.books = [NSMutableArray arrayWithArray:books];
        
        // Gather book covers.
        self.bookCovers = [NSMutableArray arrayWithArray:[books collect:^id(CKBook *book) {
            CKBookCoverView *bookCoverView = [[CKBookCoverView alloc] initWithDelegate:nil];
            [bookCoverView loadBook:book editable:NO loadRemoteIllustration:NO];
            return bookCoverView;
        }]];
        
        // Gather current bookCoverImages.
        self.bookCoverImages = [NSMutableArray arrayWithArray:[self.bookCovers collect:^id(CKBookCoverView *bookCoverView) {
            UIImage *snapshotImage = [ViewHelper imageWithView:bookCoverView size:[StoreBookCoverViewCell cellSize] opaque:NO];
            return snapshotImage;
        }]];
        
        [self showActivity:NO];
        [self insertBooks];
        
    } else {
        [self showActivity:NO];
        [self reloadBooks];
        [self showNoBooksCard];
        self.animating = NO;
        self.loading = NO;
    }
    
}

- (void)reloadBooks {
    [self.collectionView reloadData];
}

- (void)insertBooks {
    NSArray *insertIndexPaths = [self.books collectWithIndex:^id(CKBook *book, NSUInteger index) {
        return [NSIndexPath indexPathForItem:index inSection:0];
    }];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
    } completion:^(BOOL finished) {
        self.animating = NO;
        self.loading = NO;
    }];
}

- (BOOL)updateForFriendsBook:(BOOL)friendsBook {
    return NO;
}

- (void)showActivity:(BOOL)show {
    if (show) {
        [self.activityView removeFromSuperview];
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
        [[CardViewHelper sharedInstance] showNoConnectionCard:YES view:self.collectionView center:self.collectionView.center];
    } else {
        [[CardViewHelper sharedInstance] showCardText:@"UNABLE TO FETCH BOOKS" subtitle:@"PLEASE TRY AGAIN LATER"
                                                 view:self.collectionView show:YES center:self.collectionView.center];
    }
    [self showActivity:NO];
}

- (void)showNoBooksCard {
    DLog();
}

- (void)hideMessageCard {
    [[CardViewHelper sharedInstance] hideCardInView:self.collectionView];
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKBook *book = [self.books objectAtIndex:indexPath.row];
    [self showBook:book atIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [StoreBookCoverViewCell cellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15.0, 60.0, 0.0, 60.0);
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
    return self.dataLoaded ? [self.books count] : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StoreBookCoverViewCell *cell = (StoreBookCoverViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                       forIndexPath:indexPath];
    cell.delegate = self;
    CKBook *book = [self.books objectAtIndex:indexPath.item];
    [cell loadBookCoverImage:[self.bookCoverImages objectAtIndex:indexPath.item] status:book.status];
    [self loadRemoteIllustrationAtIndex:indexPath.item];
    
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
    book.status = kBookStatusFollowed;
    NSUInteger updatedBookIndex = [self.books indexOfObject:book];
    StoreBookCoverViewCell *cell = (StoreBookCoverViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:updatedBookIndex inSection:kStoreSection]];
    [cell loadBookCoverImage:[self.bookCoverImages objectAtIndex:updatedBookIndex] status:book.status];
}

#pragma mark - Subclass used methods

- (void)loadRemoteIllustrationAtIndex:(NSUInteger)bookIndex {
    CKBook *book = [self.books objectAtIndex:bookIndex];
    if (book.illustrationImageFile) {
        
        // Load the full image remotely.
        [[CKPhotoManager sharedInstance] imageForUrl:[NSURL URLWithString:book.illustrationImageFile.url]
                                                size:[CKBookCover coverImageSize]];
    }
}

#pragma mark - Private methods

- (void)openBookAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
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
    __weak CKBook *weakBook = book;
    [book addFollower:currentUser
              success:^{
                  [EventHelper postFollow:YES book:weakBook];
              } failure:^(NSError *error) {
                  DLog(@"Unable to follow.");
              }];
}

- (void)followUpdated:(NSNotification *)notification {
    BOOL follow = [EventHelper followForNotification:notification];
    if (!follow) {
        [self unloadDataCompletion:^{
            [self loadData];
        }];
    }
}

- (void)showBook:(CKBook *)book atIndexPath:(NSIndexPath *)indexPath {
    UIView *rootView = [[AppHelper sharedInstance] rootView];
    
    // Remember the cell to transition from.
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    cell.hidden = YES;
    self.selectedBookCell = cell;
    
    // Determine the point to transition from.
    CGPoint pointAtRootView = [self.collectionView convertPoint:cell.center toView:rootView];
    
    [self.delegate storeCollectionViewControllerPanRequested:NO];
    
    StoreBookViewController *storeBookViewController = [[StoreBookViewController alloc] initWithBook:book delegate:self];
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

- (void)photoLoadingReceived:(NSNotification *)notification {
    NSString *receivedPhotoName = [EventHelper nameForPhotoLoading:notification];
    
    if ([EventHelper hasImageForPhotoLoading:notification]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Find the matching book index.
            NSInteger bookIndex = [self.books findIndexWithBlock:^BOOL(CKBook *book) {
                return [receivedPhotoName isEqualToString:[book.illustrationImageFile.url lowercaseString]];
            }];
            
            if (bookIndex != -1) {
                CKBook *book = [self.books objectAtIndex:bookIndex];
                NSString *photoName = [book.illustrationImageFile.url lowercaseString];
                if ([photoName isEqualToString:receivedPhotoName]) {
                    
                    // Load the book cover image.
                    UIImage *image = [EventHelper imageForPhotoLoading:notification];
                    CKBookCoverView *bookCoverView = [self.bookCovers objectAtIndex:bookIndex];
                    [bookCoverView loadRemoteIllustrationImage:image];
                    
                    // Snapshot it.
                    UIImage *snapshotImage = [ViewHelper imageWithView:bookCoverView size:[StoreBookCoverViewCell cellSize] opaque:NO];
                    
                    StoreBookCoverViewCell *cell = (StoreBookCoverViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:bookIndex inSection:0]];
                    [cell loadBookCoverImage:snapshotImage status:book.status];
                }
            }
            
        });
    }
    
}

@end
