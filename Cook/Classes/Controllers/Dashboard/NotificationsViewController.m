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
#import "ModalOverlayHelper.h"
#import "ImageHelper.h"
#import "NSString+Utilities.h"
#import "CKUser.h"

@interface NotificationsViewController () <NotificationCellDelegate>

@property (nonatomic, weak) id<NotificationsViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSMutableDictionary *notificationActionsInProgress;

@end

@implementation NotificationsViewController

#define kContentInsets          (UIEdgeInsets){ 20.0, 20.0, 50.0, 20.0 }
#define kUnderlayMaxAlpha       0.7
#define kHeaderCellId           @"HeaderCell"
#define kCellId                 @"NotificationCell"
#define kActivityId             @"ActivityCell"
#define kNotificationsSection   0

- (id)initWithDelegate:(id<NotificationsViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[NotificationsFlowLayout alloc] init]]) {
        self.delegate = delegate;
        self.notificationActionsInProgress = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [ModalOverlayHelper modalOverlayBackgroundColour];
    self.collectionView.bounces = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kActivityId];
    [self.collectionView registerClass:[NotificationCell class] forCellWithReuseIdentifier:kCellId];
    [self.collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHeaderCellId];
    
    [self.view addSubview:self.closeButton];
    
    [self loadData];
}

#pragma mark - NotificationCellDelegate methods

- (void)notificationCell:(NotificationCell *)notificationCell acceptFriendRequest:(BOOL)accept {
    [self acceptFriendRequestForNotificationCell:notificationCell accept:accept];
}

- (BOOL)notificationCellInProgress:(NotificationCell *)notificationCell {
    return [self notificationActionInProgressForNotification:notificationCell.notification];
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
    
    CGSize cellSize = [NotificationCell unitSize];    
    return cellSize;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DLog();
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    
    if (self.notifications) {
        numItems = [self.notifications count];
    } else {
        numItems = 1;
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = nil;
    if (self.notifications) {
        NotificationCell *notificationCell = (NotificationCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                                forIndexPath:indexPath];
        notificationCell.delegate = self;
        CKUserNotification *notification = [self.notifications objectAtIndex:indexPath.item];
        [notificationCell configureNotification:notification];
        cell = notificationCell;
    } else {
        
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kActivityId forIndexPath:indexPath];
        CKActivityIndicatorView *activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleSmall];
        activityView.center = cell.contentView.center;
        [cell.contentView addSubview:activityView];
        [activityView startAnimating];
        
    }
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
        _closeButton = [ViewHelper closeButtonLight:NO target:self selector:@selector(closeTapped:)];
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

#pragma mark - Private methods

- (void)loadData {
    [CKUserNotification notificationsCompletion:^(NSArray *notifications) {
        DLog(@"Loaded notifications [%d]", [notifications count]);
        [self.delegate notificationsViewControllerDataLoaded];
        
        // Get only the accepted notifications.
        NSArray *acceptedNotificationNames = [self acceptedNotificationNames];
        self.notifications = [NSMutableArray arrayWithArray:[notifications select:^BOOL(CKUserNotification *notification) {
            return [acceptedNotificationNames containsObject:notification.name];
        }]];
        
        // Collect the indexpaths to insert.
        NSArray *indexPathsToInsert = [self.notifications collectWithIndex:^id(CKUserNotification *notification,
                                                                               NSUInteger notificationIndex) {
            return [NSIndexPath indexPathForItem:notificationIndex inSection:kNotificationsSection];
            
        }];
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
            [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
        } completion:^(BOOL finished) {
        }];
        
    } failure:^(NSError *error) {
        DLog(@"Unable to load notifications");
    }];
}

- (void)closeTapped:(id)sender {
    [self.delegate notificationsViewControllerDismissRequested];
}

- (NSArray *)acceptedNotificationNames {
    return @[kUserNotificationTypeFriendRequest, kUserNotificationTypeFriendAccept, kUserNotificationTypeComment, kUserNotificationTypeLike];
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
        [user ignoreFriendRequestFrom:actionUser completion:^{
            
            // Get the cell to refresh.
            NotificationCell *cell = [self notificationCellForNotification:notificationCell.notification];
            if (cell) {
                
                // Mark as completed.
                [self markNotificationInAction:notificationCell.notification inProgress:NO];
                
                // Remove notification from list.
                [self.notifications removeObject:notificationCell.notification];
                
                NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
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

@end
