//
//  NotificationTableViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 28/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "Theme.h"
#import "CKUserProfilePhotoView.h"
#import "CKUserNotification.h"
#import "CKUser.h"
#import "TTTTimeIntervalFormatter.h"

@interface NotificationTableViewCell ()

@property (nonatomic, strong) CKUserNotification *notification;
@property (nonatomic, strong) CKUserProfilePhotoView *profileView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TTTTimeIntervalFormatter *timeIntervalFormatter;

@end

@implementation NotificationTableViewCell

#define kContentInsets      UIEdgeInsetsMake(15, 10.0, 15.0, 10.0)
#define kProfileLabelGap    20.0
#define kTitleSubtitleGap   -2.0
#define kSubtitleTimeGap    -5.0

+ (CGFloat)heightForNotification:(CKUserNotification *)notification {
    CGFloat height = kContentInsets.top + kContentInsets.bottom;
    height += [CKUserProfilePhotoView sizeForProfileSize:ProfileViewSizeMedium].height;
    return height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        // Profile view.
        CKUserProfilePhotoView *profileView = [[CKUserProfilePhotoView alloc] initWithProfileSize:ProfileViewSizeMedium];
        profileView.frame = CGRectMake(kContentInsets.left, kContentInsets.top, profileView.frame.size.width, profileView.frame.size.height);
        [self.contentView addSubview:profileView];
        self.profileView = profileView;
        
        // Title label.
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileView.frame.origin.x + profileView.frame.size.width + kProfileLabelGap, 0.0, 0.0, 0.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [Theme notificationCellNameFont];
        titleLabel.textColor = [Theme notificationsCellNameColour];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        // Subtitle label.
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, 0.0, 0.0, 0.0)];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.font = [Theme notificationCellActionFont];
        subtitleLabel.textColor = [Theme notificationsCellActionColour];
        [self.contentView addSubview:subtitleLabel];
        self.subtitleLabel = subtitleLabel;
        
        // Time label.
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, 0.0, 0.0, 0.0)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [Theme notificationCellTimeFont];
        timeLabel.textColor = [Theme notificationsCellTimeColour];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        // Past dates formatting.
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
        [self.timeIntervalFormatter setUsesIdiomaticDeicticExpressions:NO];
    }
    return self;
}

- (void)configureUserNotification:(CKUserNotification *)userNotification {
    
    self.notification = userNotification;
    
    // Trigger load of profile picture.
    [self.profileView loadProfilePhotoForUser:userNotification.user];
    
    self.profileView.frame = CGRectMake(kContentInsets.left,
                                        floorf((self.contentView.bounds.size.height - self.profileView.frame.size.height) / 2.0),
                                        self.profileView.frame.size.width,
                                        self.profileView.frame.size.height);
    
    CGSize availableSize = [self availableSize];
    NSString *title = [userNotification.user.name uppercaseString];
    CGSize titleSize = [title sizeWithFont:self.titleLabel.font forWidth:availableSize.width lineBreakMode:NSLineBreakByTruncatingTail];
    NSString *subtitle = [self notificationActionDisplay];
    CGSize subtitleSize = [subtitle sizeWithFont:self.subtitleLabel.font forWidth:availableSize.width lineBreakMode:NSLineBreakByTruncatingTail];
    NSString *timeDisplay = [self.timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:userNotification.createdDateTime];
    CGSize timeSize = [timeDisplay sizeWithFont:self.timeLabel.font forWidth:availableSize.width lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat totalHeight = titleSize.height + kTitleSubtitleGap + subtitleSize.height + kSubtitleTimeGap + timeSize.height;
    
    self.titleLabel.text = title;
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                       floorf((self.contentView.bounds.size.height - totalHeight) / 2.0) + 5.0,
                                       titleSize.width,
                                       titleSize.height);
    self.subtitleLabel.text = subtitle;
    self.subtitleLabel.frame = CGRectMake(self.subtitleLabel.frame.origin.x,
                                          self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + kTitleSubtitleGap,
                                          subtitleSize.width,
                                          subtitleSize.height);
    self.timeLabel.text = timeDisplay;
    self.timeLabel.frame = CGRectMake(self.titleLabel.frame.origin.x,
                                      self.subtitleLabel.frame.origin.y + self.subtitleLabel.frame.size.height + kSubtitleTimeGap,
                                      timeSize.width,
                                      timeSize.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

#pragma mark - Private methods

- (CGSize)availableSize {
    return CGSizeMake(self.contentView.bounds.size.width - kContentInsets.left - kContentInsets.right,
                      self.contentView.bounds.size.height - kContentInsets.top - kContentInsets.bottom);
}

- (NSString *)notificationActionDisplay {
    NSString *actionDisplay = self.notification.actionName;
    if ([actionDisplay isEqualToString:kUserNotificationNameFriendRequest]) {
        actionDisplay = @"Wants to be your friend";
    }
    return actionDisplay;
}

@end
