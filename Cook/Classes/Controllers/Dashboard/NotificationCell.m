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

@interface NotificationCell ()

@property (nonatomic, strong) CKUserProfilePhotoView *profileView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *notificationIconView;
@property (nonatomic, strong) UILabel *notificationLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *dividerView;

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
        [self.contentView addSubview:self.notificationIconView];
        [self.contentView addSubview:self.notificationLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.dividerView];
    }
    return self;
}

- (void)configureNotification:(CKUserNotification *)notification {
    
    CKUser *actionUser = notification.actionUser;
    
    // Load current user's profile.
    [self.profileView loadProfilePhotoForUser:actionUser];
    
    CGSize availableSize = [self availableSize];
    
    // Load profile photo.
    [self.profileView loadProfilePhotoForUser:actionUser];
    
    // Name label.
    self.nameLabel.hidden = NO;
    self.nameLabel.text = actionUser.name;
    CGSize size = [self.nameLabel sizeThatFits:availableSize];
    self.nameLabel.frame = (CGRect){
        self.profileView.frame.origin.x + self.profileView.frame.size.width + kProfileNameGap,
        kContentInsets.top,
        size.width,
        size.height
    };
    
    // Notification Icon.
    UIImage *iconImage = [self iconImageForNotification:notification];
    if (iconImage) {
        self.notificationIconView.hidden = NO;
        self.notificationIconView.frame = (CGRect) {
            self.nameLabel.frame.origin.x - 13.0,
            self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height - 10.0,
            iconImage.size.width,
            iconImage.size.height
        };
        self.notificationIconView.image = iconImage;
    } else {
        self.notificationIconView.image = nil;
        self.notificationIconView.hidden = YES;
    }
    
    // Notification.
    CGSize notificationAvailableSize = availableSize;
    notificationAvailableSize.width -= iconImage ? iconImage.size.width + kIconNotificationGap : 0.0;
    self.notificationLabel.text = [self textForNotification:notification];
    size = [self.notificationLabel sizeThatFits:notificationAvailableSize];
    self.notificationLabel.frame = (CGRect){
        iconImage ? self.notificationIconView.frame.origin.x + self.notificationIconView.frame.size.width + kIconNotificationGap : self.nameLabel.frame.origin.x,
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

- (UIImageView *)notificationIconView {
    if (!_notificationIconView) {
        _notificationIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _notificationIconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _notificationIconView;
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

#pragma mark - Private methods

- (CGSize)availableSize {
    return (CGSize){
        self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
        self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom
    };
}

- (UIImage *)iconImageForNotification:(CKUserNotification *)notification {
    UIImage *iconImage = nil;
    NSString *notificationName = notification.name;
    
    if ([notificationName isEqualToString:@"FriendRequest"]) {
        iconImage = [UIImage imageNamed:@"cook_book_inner_icon_small_serves.png"];
    } else if ([notificationName isEqualToString:@"FriendAccept"]) {
        iconImage = [UIImage imageNamed:@"cook_book_inner_icon_small_serves.png"];
    } else if ([notificationName isEqualToString:@"Comment"]) {
        iconImage = [UIImage imageNamed:@"cook_book_inner_icon_comment_light.png"];
    } else if ([notificationName isEqualToString:@"Like"]) {
        iconImage = [UIImage imageNamed:@"cook_book_inner_icon_like_light.png"];
    }
    
    return iconImage;
}

- (NSString *)textForNotification:(CKUserNotification *)notification {
    NSString *text = nil;
    
    NSString *notificationName = notification.name;
    
    if ([notificationName isEqualToString:@"FriendRequest"]) {
        text = @"Wants to be your friend!";
    } else if ([notificationName isEqualToString:@"FriendAccept"]) {
        text = @"Is now friends with you!";
    } else if ([notificationName isEqualToString:@"Comment"]) {
        text = [NSString stringWithFormat:@"Commented on your recipe: %@", notification.recipe.name];
    } else if ([notificationName isEqualToString:@"Like"]) {
        text = [NSString stringWithFormat:@"Liked your recipe: %@", notification.recipe.name];
    }
    
    return text;
}

@end
