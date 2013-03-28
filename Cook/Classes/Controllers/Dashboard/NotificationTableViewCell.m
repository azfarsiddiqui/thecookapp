//
//  NotificationTableViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 28/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "Theme.h"

@implementation NotificationTableViewCell

+ (CGFloat)heightForNotification:(CKUserNotification *)notification {
    return 50.0;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [Theme notificationCellNameFont];
        self.textLabel.textColor = [Theme notificationsCellNameColour];
        self.detailTextLabel.font = [Theme notificationCellActionFont];
        self.detailTextLabel.textColor = [Theme notificationsCellActionColour];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

@end
