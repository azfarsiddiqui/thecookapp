//
//  NotificationCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "NotificationCell.h"
#import "CKUserProfilePhotoView.h"
#import "Theme.h"
#import "CKUserNotification.h"
#import "CKUser.h"
#import "CKRecipe.h"
#import "DateHelper.h"
#import "ViewHelper.h"
#import "CKActivityIndicatorView.h"

@interface NotificationCell ()

@property (nonatomic, strong) CKUserProfilePhotoView *profileView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *notificationLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UIButton *acceptFriendButton;
@property (nonatomic, strong) UIButton *ignoreFriendButton;
@property (nonatomic, strong) CKActivityIndicatorView *activityView;

@end

@implementation NotificationCell

#define kContentInsets          (UIEdgeInsets){ 15.0, 30.0, 20.0, 30.0 }
#define kProfileNameGap         20.0
#define kIconNotificationGap    0.0
#define kNameNotificationGap    0.0
#define kNotificationTimeGap    3.0

+ (CGSize)unitSize {
    return (CGSize){ 600.0, 120.0 };
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.profileView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.notificationLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.dividerView];
        [self.contentView addSubview:self.acceptFriendButton];
        [self.contentView addSubview:self.ignoreFriendButton];
        [self.contentView addSubview:self.activityView];
    }
    return self;
}

- (void)configureNotification:(CKUserNotification *)notification {
    
    self.notification = notification;
    CKUser *actionUser = notification.actionUser;
    
    // Load current user's profile.
    [self.profileView loadProfilePhotoForUser:actionUser];
    
    CGSize availableSize = [self availableSize];
    
    // Load profile photo.
    [self.profileView loadProfilePhotoForUser:actionUser];
    
    // Name label.
    self.nameLabel.hidden = NO;
    self.nameLabel.text = [actionUser.name uppercaseString];
    CGSize size = [self.nameLabel sizeThatFits:availableSize];
    self.nameLabel.frame = (CGRect){
        self.profileView.frame.origin.x + self.profileView.frame.size.width + kProfileNameGap,
        kContentInsets.top,
        size.width,
        size.height
    };
    
    // Notification.
    self.notificationLabel.text = [self textForNotification:notification];
    size = [self.notificationLabel sizeThatFits:availableSize];
    self.notificationLabel.frame = (CGRect){
        self.nameLabel.frame.origin.x,
        self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + kNameNotificationGap,
        size.width,
        size.height
    };
    
    // Time.
    self.timeLabel.text = [[[DateHelper sharedInstance] relativeDateTimeDisplayForDate:notification.createdDateTime] uppercaseString];
    size = [self.timeLabel sizeThatFits:availableSize];
    self.timeLabel.frame = (CGRect){
        self.nameLabel.frame.origin.x,
        self.notificationLabel.frame.origin.y + self.notificationLabel.frame.size.height + kNotificationTimeGap,
        size.width,
        size.height
    };
    
    // Divider.
    self.dividerView.hidden = NO;
    self.dividerView.frame = (CGRect){
        self.contentView.bounds.origin.x,
        self.contentView.bounds.size.height - self.dividerView.frame.size.height,
        self.contentView.bounds.size.width,
        self.dividerView.frame.size.height
    };
    
    // Accept/Ignore Friend buttons.
    BOOL friendRequest = [self friendRequestNotification:notification];
    self.acceptFriendButton.hidden = !friendRequest;
    self.ignoreFriendButton.hidden = !friendRequest;
    if (friendRequest) {
        
        BOOL inProgress = [self.delegate notificationCellInProgress:self];
        BOOL friendRequestAccepted = notification.friendRequestAccepted;
        if (inProgress || friendRequestAccepted) {
            self.acceptFriendButton.hidden = YES;
            self.ignoreFriendButton.hidden = YES;
            
            if (friendRequestAccepted) {
                [self.activityView stopAnimating];
            } else {
                [self.activityView startAnimating];
            }
        } else {
            [self.activityView stopAnimating];
            self.ignoreFriendButton.frame = (CGRect){
                self.contentView.bounds.size.width - self.ignoreFriendButton.frame.size.width,
                floorf((self.contentView.bounds.size.height - self.ignoreFriendButton.frame.size.height) / 2.0),
                self.ignoreFriendButton.frame.size.width,
                self.ignoreFriendButton.frame.size.height
            };
            self.acceptFriendButton.frame = (CGRect){
                self.ignoreFriendButton.frame.origin.x - self.acceptFriendButton.frame.size.width + 5.0,
                self.ignoreFriendButton.frame.origin.y,
                self.acceptFriendButton.frame.size.width,
                self.acceptFriendButton.frame.size.height
            };
        }
        
    }
}

#pragma mark - Properties

- (CKUserProfilePhotoView *)profileView {
    if (!_profileView) {
        _profileView = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeMedium];
        _profileView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        _profileView.frame = (CGRect){
            kContentInsets.left,
            kContentInsets.top + 5.0,
            _profileView.frame.size.width,
            _profileView.frame.size.height
        };
    }
    return _profileView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [Theme recipeCommenterFont];
        _nameLabel.textColor = [Theme recipeCommenterColour];
        _nameLabel.shadowOffset = (CGSize){ 0.0, 1.0 };
        _nameLabel.shadowColor = [UIColor blackColor];
        _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    }
    return _nameLabel;
}

- (UILabel *)notificationLabel {
    if (!_notificationLabel) {
        _notificationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _notificationLabel.backgroundColor = [UIColor clearColor];
        _notificationLabel.font = [Theme recipeCommentFont];
        _notificationLabel.textColor = [Theme recipeCommentColour];
        _notificationLabel.shadowOffset = (CGSize){ 0.0, 1.0 };
        _notificationLabel.shadowColor = [UIColor blackColor];
        _notificationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _notificationLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    }
    return _notificationLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [Theme overlayTimeFont];
        _timeLabel.textColor = [Theme overlayTimeColour];
        _timeLabel.shadowOffset = (CGSize){ 0.0, 1.0 };
        _timeLabel.shadowColor = [UIColor blackColor];
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    }
    return _timeLabel;
}

- (UIView *)dividerView {
    if (!_dividerView) {
        _dividerView = [[UIView alloc] initWithFrame:(CGRect){ 0.0, 0.0, 1.0, 1.0 }];
        _dividerView.backgroundColor = [UIColor darkGrayColor];
        _dividerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    }
    return _dividerView;
}

- (UIButton *)acceptFriendButton {
    if (!_acceptFriendButton) {
        _acceptFriendButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_btns_accept.png"]
                                            selectedImage:[UIImage imageNamed:@"cook_btns_accept_onpress.png"]
                                                   target:self selector:@selector(acceptFriendTapped:)];
    }
    return _acceptFriendButton;
}

- (UIButton *)ignoreFriendButton {
    if (!_ignoreFriendButton) {
        _ignoreFriendButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_btns_ignore.png"]
                                            selectedImage:[UIImage imageNamed:@"cook_btns_ignore_onpress.png"]
                                                   target:self selector:@selector(ignoreFriendTapped:)];
    }
    return _ignoreFriendButton;
}

- (CKActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CKActivityIndicatorView alloc] initWithStyle:CKActivityIndicatorViewStyleTiny];
        _activityView.frame = (CGRect){
            self.contentView.bounds.size.width - _activityView.frame.size.width - kContentInsets.right,
            floorf((self.contentView.bounds.size.height - _activityView.frame.size.height) / 2.0) - 3.0,
            _activityView.frame.size.width,
            _activityView.frame.size.height
        };
    }
    return _activityView;
}

#pragma mark - Private methods

- (CGSize)availableSize {
    return (CGSize){
        self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
        self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom
    };
}

- (NSString *)textForNotification:(CKUserNotification *)notification {
    NSString *text = nil;
    
    NSString *notificationName = notification.name;
    CKUser *actionUser = notification.actionUser;
    
    if ([notificationName isEqualToString:kUserNotificationTypeFriendRequest]) {
        if (notification.friendRequestAccepted) {
            text = [NSString stringWithFormat:@"You are now friends with %@.", [actionUser friendlyName]];
        } else {
            text = [NSString stringWithFormat:@"%@ wants to be friends.", [actionUser friendlyName]];
        }
    } else if ([notificationName isEqualToString:kUserNotificationTypeFriendAccept]) {
        text = [NSString stringWithFormat:@"You are now friends with %@.", [actionUser friendlyName]];
    } else if ([notificationName isEqualToString:kUserNotificationTypeComment]) {
        text = [NSString stringWithFormat:@"%@ commented on your recipe \"%@\"", [actionUser friendlyName], notification.recipe.name];
    } else if ([notificationName isEqualToString:kUserNotificationTypeLike]) {
        text = [NSString stringWithFormat:@"%@ liked your recipe \"%@\"", [actionUser friendlyName], notification.recipe.name];
    }
    
    return text;
}

- (void)acceptFriendTapped:(id)sender {
    [self.delegate notificationCell:self acceptFriendRequest:YES];
}

- (void)ignoreFriendTapped:(id)sender {
    [self.delegate notificationCell:self acceptFriendRequest:NO];
}

- (BOOL)friendRequestNotification:(CKUserNotification *)notification {
    return [notification.name isEqualToString:kUserNotificationTypeFriendRequest];
}

@end
