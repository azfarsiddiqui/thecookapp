//
//  CKNotificationView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 22/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKNotificationView.h"
#import "CKUser.h"
#import "CKUserNotification.h"
#import "EventHelper.h"
#import "Theme.h"
#import "ViewHelper.h"
#import "DataHelper.h"

@interface CKNotificationView ()

@property (nonatomic, weak) id<CKNotificationViewDelegate> delegate;
@property (nonatomic, strong) UIButton *offButtonIcon;
@property (nonatomic, strong) UIButton *onButtonIcon;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) NSUInteger badgeCount;

@end

@implementation CKNotificationView

#define kFont       [UIFont fontWithName:@"BrandonGrotesque-Medium" size:20.0]
#define kMidFont    [UIFont fontWithName:@"BrandonGrotesque-Medium" size:18.0]
#define kMinFont    [UIFont fontWithName:@"BrandonGrotesque-Medium" size:12.0]

- (void)dealloc {
    [EventHelper unregisterAppActive:self];
    [EventHelper unregisterUserNotifications:self];
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
}

- (id)initWithDelegate:(id<CKNotificationViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.frame = self.offButtonIcon.frame;
        [self addSubview:self.offButtonIcon];
        [self addSubview:self.onButtonIcon];
        [self addSubview:self.badgeLabel];
        
        [EventHelper registerAppActive:self selector:@selector(appActive:)];
        [EventHelper registerUserNotifications:self selector:@selector(notificationsReceived:)];
        [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
        [EventHelper registerLoginSucessful:self selector:@selector(loggedOut:)];
        
        [self loadData];
    }
    return self;
}

- (void)clearBadge {
    self.badgeCount = 0;
    [self updateBadge];
}

#pragma mark - Properties

- (UIButton *)offButtonIcon {
    if (!_offButtonIcon) {
        _offButtonIcon = [ViewHelper buttonWithImage:[self imageForHasNotifications:NO selected:NO]
                                       selectedImage:[self imageForHasNotifications:NO selected:YES]
                                              target:self selector:@selector(tapped:)];
    }
    return _offButtonIcon;
}

- (UIButton *)onButtonIcon {
    if (!_onButtonIcon) {
        _onButtonIcon = [ViewHelper buttonWithImage:[self imageForHasNotifications:YES selected:NO]
                                      selectedImage:[self imageForHasNotifications:YES selected:YES]
                                             target:self selector:@selector(tapped:)];
        _onButtonIcon.hidden = YES;   // Hidden to start off with.
    }
    return _onButtonIcon;
}

- (UILabel *)badgeLabel {
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _badgeLabel.backgroundColor = [UIColor clearColor];
        _badgeLabel.font = kFont;
        _badgeLabel.textColor = [UIColor colorWithHexString:@"8e8e8e"];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.lineBreakMode = NSLineBreakByClipping;
        _badgeLabel.hidden = YES;   // Hidden to start off with.
    }
    return _badgeLabel;
}

#pragma mark - Private methods

- (void)tapped:(id)sender {
    [self.delegate notificationViewTapped];
}

- (UIImage *)imageForHasNotifications:(BOOL)hasNotifications selected:(BOOL)selected {
    if (hasNotifications) {
        return selected ? [UIImage imageNamed:@"cook_dash_icons_notifications_on_onpress.png"] : [UIImage imageNamed:@"cook_dash_icons_notifications_on.png"];
    } else {
        return selected ? [UIImage imageNamed:@"cook_dash_icons_notifications_off_onpress.png"] : [UIImage imageNamed:@"cook_dash_icons_notifications_off.png"];
    }
}

- (void)loggedIn:(NSNotification *)notification {
    [self loadData];
}

- (void)loggedOut:(NSNotification *)notification {
    [self loadData];
}

- (void)appActive:(NSNotification *)notification {
    BOOL appActive = [EventHelper appActiveForNotification:notification];
    if (appActive) {
        [self loadData];
    }
}

- (void)notificationsReceived:(NSNotification *)notification {
    [self loadData];
}

- (void)updateBadge {
    BOOL hasNotifications = (self.badgeCount > 0);
    if (hasNotifications) {
        
        // Update the label.
        self.badgeLabel.text = [DataHelper friendlyDisplayForCount:self.badgeCount showFractional:NO];  // No fractions.
        self.badgeLabel.font = [self fontForBadgeCount];
        [self.badgeLabel sizeToFit];
        self.badgeLabel.frame = (CGRect){
            floorf((self.bounds.size.width - self.badgeLabel.frame.size.width) / 2.0),
            floorf((self.bounds.size.height - self.badgeLabel.frame.size.height) / 2.0),
            self.badgeLabel.frame.size.width,
            self.badgeLabel.frame.size.height
        };
        
        if (!self.on) {
            
            // Swap the on image in.
            self.onButtonIcon.alpha = 0.0;
            self.onButtonIcon.hidden = NO;
            self.badgeLabel.alpha = 0.0;
            self.badgeLabel.hidden = NO;
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.offButtonIcon.alpha = 0.0;
                                 self.onButtonIcon.alpha = 1.0;
                                 self.badgeLabel.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 self.offButtonIcon.hidden = YES;
                             }];
        }
        
        self.on = YES;
        
    } else {
        
        if (self.on) {
            
            // Swap the off image in.
            self.offButtonIcon.alpha = 0.0;
            self.offButtonIcon.hidden = NO;
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.offButtonIcon.alpha = 1.0;
                                 self.onButtonIcon.alpha = 0.0;
                                 self.badgeLabel.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 self.onButtonIcon.hidden = YES;
                                 self.badgeLabel.hidden = YES;
                             }];
        }
        
        self.on = NO;
    }
    
    
}

- (UIFont *)fontForBadgeCount {
    UIFont *font = kFont;
    NSString *badgeText = self.badgeLabel.text;
    if ([badgeText length] > 3) {
        font = kMinFont;
    } else if ([badgeText length] > 2) {
        font = kMidFont;
    }
    return font;
}

- (void)loadData {
    DLog();
    
    if (self.loading) {
        return;
    }
    self.loading = YES;
    
    if ([CKUser isLoggedIn]) {
        
        [[CKUser currentUser] numUnreadNotificationsCompletion:^(int count) {
            
            self.badgeCount = count;
            self.loading = NO;
            [self updateBadge];
            
        } failure:^(NSError *error) {
            
            // Ignore error.
            self.badgeCount = 0;
            self.loading = NO;
            [self updateBadge];
        }];
        
    } else {
        
        self.badgeCount = 0;
        self.loading = NO;
        [self updateBadge];
    }
}

@end
