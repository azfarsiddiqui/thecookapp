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

@interface NotificationsViewController ()

@property (nonatomic, weak) id<NotificationsViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSMutableArray *notifications;

@end

@implementation NotificationsViewController

#define kContentInsets          (UIEdgeInsets){ 20.0, 20.0, 20.0, 20.0 }
#define kUnderlayMaxAlpha       0.7
#define kHeaderCellId           @"HeaderCell"
#define kCellId                 @"NotificationCell"
#define kNotificationsSection   0

- (id)initWithDelegate:(id<NotificationsViewControllerDelegate>)delegate {
    if (self = [super initWithCollectionViewLayout:[[NotificationsFlowLayout alloc] init]]) {
        self.delegate = delegate;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:kUnderlayMaxAlpha];
    self.collectionView.bounces = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[NotificationCell class] forCellWithReuseIdentifier:kCellId];
    [self.collectionView registerClass:[ModalOverlayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderCellId];
    
    [self.view addSubview:self.closeButton];
    
    [self loadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    CGSize unitSize = [NotificationCell unitSize];
    CGFloat sideGap = floorf((self.collectionView.bounds.size.width - unitSize.width) / 2.0);
    return (UIEdgeInsets) { kContentInsets.top, sideGap, kContentInsets.bottom, sideGap };
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
    
    CGSize cellSize = CGSizeZero;
    if (indexPath.section == kNotificationsSection) {
        cellSize = [NotificationCell unitSize];
    }
    
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
    
    if (section == kNotificationsSection) {
        numItems = [self.notifications count];
    }
    
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NotificationCell *cell = (NotificationCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kCellId
                                                                                                forIndexPath:indexPath];
    CKUserNotification *notification = [self.notifications objectAtIndex:indexPath.item];
    [cell configureNotification:notification];
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
        [self.collectionView insertItemsAtIndexPaths:indexPathsToInsert];
        
    } failure:^(NSError *error) {
        DLog(@"Unable to load notifications");
    }];
}

- (void)closeTapped:(id)sender {
    [self.delegate notificationsViewControllerDismissRequested];
}

- (NSArray *)acceptedNotificationNames {
    return @[@"FriendRequest", @"FriendAccept", @"Comment", @"Like"];
}

@end
