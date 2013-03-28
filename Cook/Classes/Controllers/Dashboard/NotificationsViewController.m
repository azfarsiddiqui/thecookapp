//
//  NotificationsViewController.m
//  Cook
//
//  Created by Jeff Tan-Ang on 27/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "NotificationsViewController.h"
#import "NotificationTableViewCell.h"
#import "CKUserNotification.h"
#import "CKUser.h"
#import "Theme.h"

@interface NotificationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation NotificationsViewController

#define kTitleYOffset   10.0
#define kHeaderHeight   70.0
#define kCellId         @"NotificationCellId"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0.0, 0.0, 500.0, 650.0);
    
    [self initTitleLabel];
    [self initTableView];
    [self loadData];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellId
                                                                                                   forIndexPath:indexPath];
    CKUserNotification *notification = [self.notifications objectAtIndex:indexPath.item];
    cell.textLabel.text = [notification.user.name uppercaseString];
    cell.detailTextLabel.text = [notification.name uppercaseString];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKUserNotification *notification = [self.notifications objectAtIndex:indexPath.item];
    return [NotificationTableViewCell heightForNotification:notification];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Private methods

- (void)initTitleLabel {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [Theme notificationsHeaderFont];
    titleLabel.textColor = [Theme notificationsHeaderColour];
    titleLabel.text = @"NOTIFICATIONS";
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake(floorf((self.view.bounds.size.width - titleLabel.frame.size.width) / 2.0),
                                  kTitleYOffset,
                                  titleLabel.frame.size.width,
                                  titleLabel.frame.size.height);
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           kHeaderHeight,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - kHeaderHeight)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.scrollEnabled = NO;
    tableView.autoresizingMask = UIViewAutoresizingNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollEnabled = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView registerClass:[NotificationTableViewCell class] forCellReuseIdentifier:kCellId];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(floorf((tableView.bounds.size.width - activityView.frame.size.width) / 2.0),
                                    floorf((tableView.bounds.size.height - activityView.frame.size.height - kHeaderHeight) / 2.0),
                                    activityView.frame.size.width,
                                    activityView.frame.size.height);
    [tableView addSubview:activityView];
    self.activityView = activityView;
}

- (void)loadData {
    [self.activityView startAnimating];
    CKUser *currentUser = [CKUser currentUser];
    [CKUserNotification notificationsForUser:currentUser
                                  completion:^(NSArray *notifications) {
                                      self.notifications = [NSMutableArray arrayWithArray:notifications];
                                      [self.activityView stopAnimating];
                                      [self.tableView reloadData];
                                  } failure:^(NSError *error) {
                                      DLog(@"Error %@", [error localizedDescription]);
                                      [self.activityView stopAnimating];
                                  }];
}

@end
