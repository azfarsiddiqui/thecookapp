//
//  NotificationsViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "NotificationsViewController.h"
#import "ModalOverlayHeaderView.h"
#import "ViewHelper.h"
#import "NotificationCell.h"
#import "CKUserNotification.h"
#import "NotificationsFlowLayout.h"
#import "MRCEnumerable.h"
#import "CKActivityIndicatorView.h"
#import "ImageHelper.h"
#import "NSString+Utilities.h"
#import "CKUser.h"
#import "RecipeSocialViewController.h"
#import "ProfileViewController.h"
#import "AnalyticsHelper.h"
#import "PaginationHelper.h"
#import "CKActivityIndicatorView.h"
#import "CKContentContainerCell.h"

@interface NotificationsViewController () <NotificationCellDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, RecipeSocialViewControllerDelegate>

@property (nonatomic, weak) id<NotificationsViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSMutableDictionary *notificationActionsInProgress;
@property (nonatomic, strong) UILabel *emptyCommentsLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CKNavigationController *cookNavigationController;
@property (nonatomic, strong) PaginationHelper *paginationHelper;
@property (nonatomic, strong) UIView *loadMoreContainerView;
@property (nonatomic, strong) CKActivityIndicatorView *loadMoreActivityView;

@end

@implementation NotificationsViewController

#define kContentInsets          (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kUnderlayMaxAlpha       0.7
#define kHeaderCellId           @"HeaderCell"
#define kCellId                 @"NotificationCell"
#define kActivityId             @"ActivityCell"
#define LOAD_MORE_CELL_ID       @"LoadMoreCellId"
#define kNotificationsSection   0

- (id)initWithDelegate:(id<NotificationsViewControllerDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.notificationActionsInProgress = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.closeButton];
    [self loadData];
    
    [AnalyticsHelper trackEventName:kEventNotificationsView];
}

#pragma mark - NotificationCellDelegate methods

- (void)notificationCell:(NotificationCell *)notificationCell acceptFriendRequest:(BOOL)accept {
    [self acceptFriendRequestForNotificationCell:notificationCell accept:accept];
}

- (BOOL)notificationCellInProgress:(NotificationCell *)notificationCell {
    return [self notificationActionInProgressForNotification:notificationCell.notification];
}

- (void)notificationCellProfileRequestedForUser:(CKUser *)user {
    [self showProfileForUser:user];
}

#pragma mark - RecipeSocialViewControllerDelegate methods

- (void)recipeSocialViewControllerCloseRequested {
    DLog();
    [self.cookNavigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    CGSize unitSize = [NotificationCell unitSize];
    CGFloat sideGap = floorf((self.collectionView.bounds.size.width - unitSize.width) / 2.0);
    return (UIEdgeInsets) {
        kContentInsets.top,
        sideGap,
        kContentInsets.bottom,
        sideGap
    };
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between columns in the same row.
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    // Between rows in the same column.
    return 10.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return [ModalOverlayHeaderView unitSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize unitSize = [NotificationCell unitSize];
    if (self.paginationHelper.ready) {
        
        if ([self.paginationHelper.items count] > 0) {
            
            if (indexPath.item < [self.paginationHelper.items count]) {
                
                return [NotificationCell unitSize];
                
            } else {
                
                return self.loadMoreContainerView.frame.size;
                
            }

        } else {
            
            return (CGSize){
                unitSize.width,
                515.0
            };
        }
        
    } else {
        
        return (CGSize){
            unitSize.width,
            515.0
        };
    }
    
}

#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.paginationHelper.items count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CKUserNotification *notification = [self.paginationHelper itemAtIndex:indexPath.item];
    NSString *notificationName = notification.name;

    if ([notificationName isEqualToString:kUserNotificationTypeFriendRequest]
        || [notificationName isEqualToString:kUserNotificationTypeFriendAccept]
        || [notificationName isEqualToString:kUserNotificationTypeFeedPin]
        ) {

        CKUser *user = notification.actionUser;
        if (user) {
            [self showProfileForUser:user];
        }
        
    } else if ([notificationName isEqualToString:kUserNotificationTypeComment]
               || [notificationName isEqualToString:kUserNotificationTypeReply]
               || [notificationName isEqualToString:kUserNotificationTypeLike]
               || [notificationName isEqualToString:kUserNotificationTypePin]
               ) {
        
        CKRecipe *recipe = notification.recipe;
        if (recipe) {
            RecipeSocialViewController *recipeSocialViewController = [[RecipeSocialViewController alloc] initWithRecipe:recipe delegate:self];
            [self.cookNavigationController pushViewController:recipeSocialViewController animated:YES];
        }
    }

}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    
    if (self.paginationHelper.ready) {
        
        if ([self.paginationHelper.items count] > 0) {
            numItems = [self.paginationHelper.items count];
            
            // Load more.
            if ([self.paginationHelper hasMoreItems]) {
                numItems += 1;
            }
            
        } else {
            numItems = 1;
        }

    } else {
        
        // Activity.
        numItems = 1;
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (self.paginationHelper.ready) {
        
        if ([self.paginationHelper.items count] > 0) {
            
            if (indexPath.item < [self.paginationHelper.items count]) {
                
                // Notification item cell.
                NotificationCell *notificationCell = (NotificationCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                                        forIndexPath:indexPath];
                notificationCell.delegate = self;
                CKUserNotification *notification = [self.paginationHelper itemAtIndex:indexPath.item];
                [notificationCell configureNotification:notification];
                cell = notificationCell;
                
            } else {
                
                // Load more spinner?
                CKContentContainerCell *activityCell = (CKContentContainerCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:LOAD_MORE_CELL_ID
                                                                                                                                forIndexPath:indexPath];
                [self.loadMoreContainerView removeFromSuperview];
                [activityCell configureContentView:self.loadMoreContainerView];
                if (![self.loadMoreActivityView isAnimating]) {
                    [self.loadMoreActivityView startAnimating];
                }
                
                cell = activityCell;
                
                // Load more?
                if ([self.paginationHelper hasMoreItems]) {
                    [self notificationsBatchIndex:[self.paginationHelper nextBatchIndex]];
                }

            }
            
        } else {
            
            // No notifications.
            [self.overlayActivityView stopAnimating];
            [self.overlayActivityView removeFromSuperview];
            cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kActivityId forIndexPath:indexPath];
            self.emptyCommentsLabel.center = cell.contentView.center;
            [cell.contentView addSubview:self.emptyCommentsLabel];
            
        }

    } else {
        
        // Loading spinner.
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kActivityId forIndexPath:indexPath];
        self.overlayActivityView.center = cell.contentView.center;
        [cell.contentView addSubview:self.overlayActivityView];
        [self.overlayActivityView startAnimating];
        
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *supplementaryView = nil;
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ModalOverlayHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                     withReuseIdentifier:kHeaderCellId forIndexPath:indexPath];
        [headerView configureTitle:@"NOTIFICATIONS"];
        supplementaryView = headerView;
    }
    
    return supplementaryView;
}

#pragma mark - Properties

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [ViewHelper closeButtonLight:YES target:self selector:@selector(closeTapped:)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _closeButton.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top,
            _closeButton.frame.size.width,
            _closeButton.frame.size.height
        };
    }
    return _closeButton;
}

- (UILabel *)emptyCommentsLabel {
    if (!_emptyCommentsLabel) {
        _emptyCommentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyCommentsLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Regular" size:18.0];
        _emptyCommentsLabel.textColor = [UIColor whiteColor];
        _emptyCommentsLabel.text = @"NO NOTIFICATIONS";
        [_emptyCommentsLabel sizeToFit];
    }
    return _emptyCommentsLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:[[NotificationsFlowLayout alloc] init]];
        _collectionView.bounces = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityId];
        [_collectionView registerClass:[NotificationCell class] forCellWithReuseIdentifier:kCellId];
        [_collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHeaderCellId];
        [_collectionView registerClass:[CKContentContainerCell class] forCellWithReuseIdentifier:LOAD_MORE_CELL_ID];
    }
    return _collectionView;
}

- (PaginationHelper *)paginationHelper {
    if (!_paginationHelper) {
        _paginationHelper = [[PaginationHelper alloc] init];
    }
    return _paginationHelper;
}

- (UIView *)loadMoreContainerView {
    if (!_loadMoreContainerView) {
        UIEdgeInsets spinnerInsets = (UIEdgeInsets){ 30.0, 0.0, 0.0, 0.0 };
        _loadMoreContainerView = [[UIView alloc] initWithFrame:(CGRect){
            0.0,
            0.0,
            spinnerInsets.left + self.loadMoreActivityView.frame.size.width + spinnerInsets.right,
            spinnerInsets.top + self.loadMoreActivityView.frame.size.height + spinnerInsets.bottom }];
        
        self.loadMoreActivityView.frame = (CGRect){
            spinnerInsets.left + floorf((_loadMoreContainerView.bounds.size.width - self.loadMoreActivityView.frame.size.width) / 2.0),
            spinnerInsets.top,
            self.loadMoreActivityView.frame.size.width,
            self.loadMoreActivityView.frame.size.height
        };
        [_loadMoreContainerView addSubview:self.loadMoreActivityView];
        _loadMoreContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _loadMoreContainerView;
}

- (CKActivityIndicatorView *)loadMoreActivityView {
    if (!_loadMoreActivityView) {
        _loadMoreActivityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        _loadMoreActivityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _loadMoreActivityView;
}

#pragma mark - Private methods

- (void)loadData {
    [self notificationsBatchIndex:[self.paginationHelper nextBatchIndex]];
}

- (void)closeTapped:(id)sender {
    [self.delegate notificationsViewControllerDismissRequested];
}

- (BOOL)notificationActionInProgressForNotification:(CKUserNotification *)notification {
    return ([self.notificationActionsInProgress objectForKey:notification.objectId] != nil);
}

- (void)markNotificationInAction:(CKUserNotification *)notification inProgress:(BOOL)inProgress {
    if (inProgress) {
        [self.notificationActionsInProgress setObject:notification forKey:notification.objectId];
    } else {
        [self.notificationActionsInProgress removeObjectForKey:notification.objectId];
    }
}

- (void)acceptFriendRequestForNotificationCell:(NotificationCell *)notificationCell accept:(BOOL)accept {
    DLog(@"accept[%@]", [NSString CK_stringForBoolean:accept]);
    CKUser *user = notificationCell.notification.user;
    CKUser *actionUser = notificationCell.notification.actionUser;
    
    // Mark as in progress.
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:notificationCell];
    [self markNotificationInAction:notificationCell.notification inProgress:YES];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    if (accept) {
        
        // Accept friend request.
        [user requestFriend:actionUser
                 completion:^{
                     
                     // Get the cell to refresh.
                     NotificationCell *cell = [self notificationCellForNotification:notificationCell.notification];
                     if (cell) {
                         
                         // Mark as completed.
                         [self markNotificationInAction:notificationCell.notification inProgress:NO];
                         notificationCell.notification.friendRequestAccepted = YES;
                         
                         NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                         [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                         
                     }
                     
                 } failure:^(NSError *error) {
                     
                     // Get the cell to refresh.
                     NotificationCell *cell = [self notificationCellForNotification:notificationCell.notification];
                     if (cell) {
                         [self markNotificationInAction:notificationCell.notification inProgress:NO];
                         NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                         [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                     }
                     
                 }];
        
    } else {
        
        // Ignore friend request.
        [user ignoreRemoveFriendRequestFrom:actionUser completion:^{
            
            // Get the cell to refresh.
            NotificationCell *cell = [self notificationCellForNotification:notificationCell.notification];
            if (cell) {
                
                // Mark as completed.
                [self markNotificationInAction:notificationCell.notification inProgress:NO];
                
                NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                
                // Remove notification from list.
                [self.paginationHelper removeItemAtIndex:indexPath.item];
                
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                
            }
            
        } failure:^(NSError *errro) {
            
            // Get the cell to refresh.
            NotificationCell *cell = [self notificationCellForNotification:notificationCell.notification];
            if (cell) {
                [self markNotificationInAction:notificationCell.notification inProgress:NO];
                NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
            
        }];
        
    }
}

- (NotificationCell *)notificationCellForNotification:(CKUserNotification *)notification {
    NSArray *visibleCells = [self.collectionView visibleCells];
    return [visibleCells detect:^BOOL(NotificationCell *notificationCell) {
        return [notificationCell.notification.objectId isEqualToString:notification.objectId];
    }];
}

- (void)showProfileForUser:(CKUser *)user {
    if (!user) {
        return;
    }
    ProfileViewController *profileViewController = [[ProfileViewController alloc] initWithUser:user];
    [self.cookNavigationController pushViewController:profileViewController animated:YES];

}

- (void)notificationsBatchIndex:(NSUInteger)batchIndex {
    [CKUserNotification notificationsWithBatchIndex:batchIndex
                                         completion:^(NSArray *notifications, NSUInteger numItems,
                                                      NSUInteger notificationBatchIndex, NSUInteger numBatches) {
                                             
                                             DLog(@"Loaded notifications [%ld]", (long)[notifications count]);
                                             [self.delegate notificationsViewControllerDataLoaded];
                                             
                                             NSUInteger nextSliceIndex = [self.paginationHelper nextSliceIndex];
                                             
                                             // Collect the indexpaths to insert.
                                             NSMutableArray *indexPathsToInsert = [NSMutableArray arrayWithArray:[notifications collectWithIndex:^id(CKUserNotification *notification,
                                                                                                                                                     NSUInteger notificationIndex) {
                                                 return [NSIndexPath indexPathForItem:nextSliceIndex + notificationIndex
                                                                            inSection:kNotificationsSection];
                                             }]];
                                             
                                             // Update pagination helper with data.
                                             [self.paginationHelper updateWithItems:notifications
                                                                         batchIndex:notificationBatchIndex
                                                                           numItems:numItems
                                                                         numBatches:numBatches];
                                             
                                             if ([indexPathsToInsert count] > 0) {
                                                 
                                                 // Index paths to delete.
                                                 NSMutableArray *indexPathsToDelete = [NSMutableArray array];
                                                 
                                                 if (notificationBatchIndex == 0) {
                                                     
                                                     // Remove loading spinner if batchIndex is 0
                                                     [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
                                                     
                                                 } else {
                                                     
                                                     // Remove load more spinner.
                                                     [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:nextSliceIndex inSection:0]];
                                                     
                                                 }
                                                 
                                                 // Add load more spinner cell.
                                                 if ([self.paginationHelper hasMoreItems]) {
                                                     NSIndexPath *lastIndexPath = [indexPathsToInsert lastObject];
                                                     
                                                     NSIndexPath *activityInsertIndexPath = [NSIndexPath indexPathForItem:lastIndexPath.item + 1 inSection:0];
                                                     [indexPathsToInsert addObject:activityInsertIndexPath];
                                                 }
                                                 
                                                 [self.collectionView performBatchUpdates:^{
                                                     
                                                     if ([indexPathsToDelete count] > 0) {
                                                         [self.collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
                                                     }
                                                     
                                                     [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
                                                     
                                                 } completion:^(BOOL finished) {
                                                 }];
                                                 
                                             } else {
                                                 [self.collectionView reloadData];
                                             }
                                             
                                             
                                         } failure:^(NSError *error) {
                                             DLog(@"Unable to load notifications");
                                         }];
}

@end
