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
#import "CKActivityIndicatorView.h"
#import "CKContentContainerCell.h"
#import "AppHelper.h"
#import "RootViewController.h"
#import "ModalOverlayHelper.h"

@interface NotificationsViewController () <NotificationCellDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout, RecipeSocialViewControllerDelegate, ProfileViewControllerDelegate>

@property (nonatomic, weak) id<NotificationsViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *modalOverlayView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSMutableDictionary *notificationActionsInProgress;
@property (nonatomic, strong) UILabel *emptyCommentsLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *loadMoreContainerView;
@property (nonatomic, strong) CKActivityIndicatorView *loadMoreActivityView;
@property (nonatomic, strong) ProfileViewController *profileViewController;

@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, strong) NSMutableArray *notifications;

@end

@implementation NotificationsViewController

#define kContentInsets              (UIEdgeInsets){ 30.0, 15.0, 50.0, 15.0 }
#define kUnderlayMaxAlpha           0.7
#define kHeaderCellId               @"HeaderCell"
#define kCellId                     @"NotificationCell"
#define kActivityId                 @"ActivityCell"
#define LOAD_MORE_CELL_ID           @"LoadMoreCellId"
#define kNotificationsSection       0
#define MODAL_SCALE_TRANSFORM       0.9
#define MODAL_OVERLAY_ALPHA         0.5

- (void)dealloc {
    self.blurredImageView.image = nil;
}

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
    [self.view addSubview:self.blurredImageView];
    [self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.collectionView];
    [self.containerView addSubview:self.closeButton];
    
    UIScreenEdgePanGestureRecognizer *screenEdgeRecogniser = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                                                                               action:@selector(screenEdgeSwiped:)];
    screenEdgeRecogniser.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenEdgeRecogniser];
    
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
    [self showProfileOverlay:YES user:user];
}

#pragma mark - RecipeSocialViewControllerDelegate methods

- (void)recipeSocialViewControllerCloseRequested {
    DLog();
    [self.delegate notificationsViewControllerDismissRequested];
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
    if (self.notifications) {
        
        if ([self.notifications count] > 0) {
            
            if (indexPath.item < [self.notifications count]) {
                
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
    if ([self.notifications count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CKUserNotification *notification = [self.notifications objectAtIndex:indexPath.item];
    NSString *notificationName = notification.name;

    if ([notificationName isEqualToString:kUserNotificationTypeFriendRequest]
        || [notificationName isEqualToString:kUserNotificationTypeFriendAccept]
        ) {

        CKUser *user = notification.actionUser;
        if (user) {
            [self showProfileOverlay:YES user:user];
        }
        
    } else if ([notificationName isEqualToString:kUserNotificationTypeComment]
               || [notificationName isEqualToString:kUserNotificationTypeReply]
               || [notificationName isEqualToString:kUserNotificationTypeLike]
               || [notificationName isEqualToString:kUserNotificationTypePin]
               || [notificationName isEqualToString:kUserNotificationTypeFeedPin]
               ) {
        
        CKRecipe *recipe = notification.recipe;
        if (recipe) {
            [self showRecipe:recipe];
        }
    }

}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    NSInteger numItems = 0;
    
    if (self.notifications) {
        
        if ([self.notifications count] > 0) {
            numItems = [self.notifications count];
            
            // Load more?
            if ([self.notifications count] < self.totalCount) {
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
    
    if (self.notifications) {
        
        if ([self.notifications count] > 0) {
            
            if (indexPath.item < [self.notifications count]) {
                
                // Notification item cell.
                NotificationCell *notificationCell = (NotificationCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                                        forIndexPath:indexPath];
                notificationCell.delegate = self;
                CKUserNotification *notification = [self.notifications objectAtIndex:indexPath.item];
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
                if ([self.notifications count] < self.totalCount) {
                    [self notificationsFromItemIndex:[self.notifications count]];
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

#pragma mark - ProfileViewControllerDelegate methods

- (void)profileViewControllerCloseRequested {
    [self showProfileOverlay:NO user:nil];
}

#pragma mark - AppModalViewController methods

- (void)setModalViewControllerDelegate:(id<AppModalViewControllerDelegate>)modalViewControllerDelegate {
    DLog();
}

- (void)appModalViewControllerWillAppear:(NSNumber *)appearNumber {
    DLog();
    
    BOOL appear = [appearNumber boolValue];
    if (appear) {
        
        // Create overlay.
        self.modalOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.modalOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.modalOverlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:MODAL_OVERLAY_ALPHA];
        self.modalOverlayView.alpha = 0.0;
        [self.view addSubview:self.modalOverlayView];
        
    }
}

- (void)appModalViewControllerAppearing:(NSNumber *)appearingNumber {
    DLog();
    BOOL appearing = [appearingNumber boolValue];
    [self applyModalTransitionToAppear:appearing];
}

- (void)appModalViewControllerDidAppear:(NSNumber *)appearNumber {
    DLog();
    BOOL appeared = [appearNumber boolValue];
    if (!appeared) {
        [self.modalOverlayView removeFromSuperview];
        self.modalOverlayView = nil;
    }
}

#pragma mark - Properties

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _containerView;
}

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

- (UIImageView *)blurredImageView {
    if (!_blurredImageView) {
        _blurredImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _blurredImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _blurredImageView.image = [self.delegate notificationsViewControllerSnapshotImageRequested];
    }
    return _blurredImageView;
}


#pragma mark - Private methods

- (void)loadData {
    [self notificationsFromItemIndex:[self.notifications count]];
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
                [self.notifications removeObjectAtIndex:indexPath.item];
                
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

- (void)notificationsFromItemIndex:(NSUInteger)itemIndex {
    [CKUserNotification notificationsFromItemIndex:itemIndex
                                        completion:^(NSArray *notifications, NSUInteger totalCount,
                                                     NSUInteger notificationItemIndex) {
                                             
                                            DLog(@"Loaded notifications [%ld]", (long)[notifications count]);
                                            [self.delegate notificationsViewControllerDataLoaded];
                                            
                                            // Current item index.
                                            NSUInteger nextSliceIndex = [self.notifications count];
                                            
                                            // Capture items to display.
                                            if (!self.notifications) {
                                                self.notifications = [NSMutableArray arrayWithArray:notifications];
                                            } else {
                                                [self.notifications addObjectsFromArray:notifications];
                                            }
                                            
                                            // Capture pagination metadata.
                                            self.totalCount = totalCount;
                                            
                                            // Collect the indexpaths to insert.
                                            NSMutableArray *indexPathsToInsert = [NSMutableArray arrayWithArray:[notifications collectWithIndex:^id(CKUserNotification *notification,
                                                                                                                                                     NSUInteger notificationIndex) {
                                                 return [NSIndexPath indexPathForItem:nextSliceIndex + notificationIndex
                                                                            inSection:kNotificationsSection];
                                             }]];
                                            
                                            // If we have stuff to insert.
                                            if ([indexPathsToInsert count] > 0) {
                                                 
                                                // Index paths to delete.
                                                NSMutableArray *indexPathsToDelete = [NSMutableArray array];
                                                 
                                                if (notificationItemIndex == 0) {
                                                     
                                                    // Remove loading spinner if itemIndex was 0
                                                    [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:0 inSection:0]];
                                                     
                                                } else {
                                                     
                                                    // Remove load more spinner.
                                                    [indexPathsToDelete addObject:[NSIndexPath indexPathForItem:nextSliceIndex inSection:0]];
                                                     
                                                }
                                                 
                                                // Add load more spinner cell.
                                                if ([self.notifications count] < self.totalCount) {
                                                    NSIndexPath *activityInsertIndexPath = [NSIndexPath indexPathForItem:[self.notifications count] inSection:0];
                                                    [indexPathsToInsert addObject:activityInsertIndexPath];
                                                }
                                                
                                                // Now insert into our collection view.
                                                [self.collectionView performBatchUpdates:^{
                                                    
                                                    // Any cell to delete?
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

- (void)showRecipe:(CKRecipe *)recipe {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[AppHelper sharedInstance] rootViewController] showModalWithRecipe:recipe callerViewController:self];
    });
}

- (void)showProfileOverlay:(BOOL)show user:(CKUser *)user {
    if (show) {
        self.profileViewController = [[ProfileViewController alloc] initWithUser:user delegate:self];
        self.profileViewController.useBackButton = YES;
    }
    
    [ModalOverlayHelper showModalOverlayForViewController:self.profileViewController
                                                     show:show
                                                 duration:0.4
                                                animation:^{
                                                    [self applyModalTransitionToAppear:show];
                                                }
                                               completion:^{
                                                   if (!show) {
                                                       self.profileViewController = nil;
                                                   }
                                               }];
}

- (void)applyModalTransitionToAppear:(BOOL)appearing {
    
    // Scale appropriate views.
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(MODAL_SCALE_TRANSFORM, MODAL_SCALE_TRANSFORM);
    self.containerView.transform = appearing ? scaleTransform : CGAffineTransformIdentity;
    
    // Fade container in/out.
    self.containerView.alpha = appearing ? 0.5 : 1.0;
    
    // Fade overlay in/out.
    self.modalOverlayView.alpha = appearing ? 1.0 : 0.0;
}

- (void)screenEdgeSwiped:(UIScreenEdgePanGestureRecognizer *)screenEdgeRecogniser {
    if (screenEdgeRecogniser.state == UIGestureRecognizerStateBegan) {
        [self.delegate notificationsViewControllerDismissRequested];
    }
}

@end
