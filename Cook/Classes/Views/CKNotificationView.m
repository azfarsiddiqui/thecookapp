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
#import "UIView+CutOut.h"
#import "AppHelper.h"

@interface CKNotificationView ()

@property (nonatomic, weak) id<CKNotificationViewDelegate> delegate;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *offButtonIcon;
@property (nonatomic, strong) UIButton *onButtonIcon;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) NSUInteger badgeCount;

@end

@implementation CKNotificationView

#define kFont               [UIFont fontWithName:@"BrandonGrotesque-Regular" size:20.0]
#define kLabelInsets        (UIEdgeInsets) { 9.0, 14.0, 0.0, 12.0 }

- (void)dealloc {
    [EventHelper unregisterAppActive:self];
    [EventHelper unregisterUserNotifications:self];
    [EventHelper unregisterLoginSucessful:self];
    [EventHelper unregisterLogout:self];
}

- (id)initWithDelegate:(id<CKNotificationViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        
        [self reset];
        [self loadData];
        
        [EventHelper registerAppActive:self selector:@selector(appActive:)];
        [EventHelper registerUserNotifications:self selector:@selector(notificationsReceived:)];
        [EventHelper registerLoginSucessful:self selector:@selector(loggedIn:)];
        [EventHelper registerLogout:self selector:@selector(loggedOut:)];
        
    }
    return self;
}

- (void)clearBadge {
    self.badgeCount = 0;
    [self updateBadge];
}

#pragma mark - Properties

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.offButtonIcon.frame];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (UIButton *)offButtonIcon {
    if (!_offButtonIcon) {
        _offButtonIcon = [ViewHelper buttonWithImage:[self imageForHasNotifications:NO selected:NO]
                                       selectedImage:[self imageForHasNotifications:NO selected:YES]
                                              target:self selector:@selector(tapped:)];
        _offButtonIcon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    }
    return _offButtonIcon;
}

- (UIButton *)onButtonIcon {
    if (!_onButtonIcon) {
        _onButtonIcon = [ViewHelper buttonWithImage:[self imageForHasNotifications:YES selected:NO]
                                      selectedImage:[self imageForHasNotifications:YES selected:YES]
                                             target:self selector:@selector(tapped:)];
        _onButtonIcon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        _onButtonIcon.hidden = YES;   // Hidden to start off with.
    }
    return _onButtonIcon;
}

#pragma mark - Private methods

- (void)tapped:(id)sender {
    [self.delegate notificationViewTapped];
}

- (UIImage *)imageForHasNotifications:(BOOL)hasNotifications selected:(BOOL)selected {
    UIImage *image = nil;
    if (hasNotifications) {
        image = selected ? [UIImage imageNamed:@"cook_dash_icons_notifications_on_onpress.png"] : [UIImage imageNamed:@"cook_dash_icons_notifications_on.png"];
    } else {
        image = selected ? [UIImage imageNamed:@"cook_dash_icons_notifications_off_onpress.png"] : [UIImage imageNamed:@"cook_dash_icons_notifications_off.png"];
    }
    return [image resizableImageWithCapInsets:(UIEdgeInsets){ 0.0, 25.0, 0.0, 24.0 }];
}

- (void)loggedIn:(NSNotification *)notification {
    [self loadData];
}

- (void)loggedOut:(NSNotification *)notification {
    [self clearBadge];
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
    
    // Reset the views.
    [self reset];
    
    if (hasNotifications) {
        
        // Figure out the required text size.
        NSString *badgeText = [DataHelper formattedDisplayForInteger:self.badgeCount];
        CGSize requiredTextSize = [badgeText sizeWithAttributes:@{ NSFontAttributeName : [self fontForBadgeCount] }];
        
        // Adjust the frame of ourselves.
        CGRect frame = self.frame;
        CGSize containerSize = self.containerView.frame.size;
        CGFloat requiredWidth = containerSize.width - kLabelInsets.left - kLabelInsets.right;
        if (requiredTextSize.width > requiredWidth) {
            containerSize.width = requiredTextSize.width + kLabelInsets.left + kLabelInsets.right;
        }
        self.containerView.frame = (CGRect){ self.bounds.origin.x, self.bounds.origin.y, containerSize.width, containerSize.height };
        frame.size = containerSize;
        self.frame = frame;
        
        // Mark as ON.
        self.offButtonIcon.hidden = YES;
        self.onButtonIcon.hidden = NO;
        self.on = YES;
        
        UIOffset offset = (UIOffset){ 2.0, [[AppHelper sharedInstance] isRetina] ? -2.5 : -3.0 };
        [self.containerView setMaskWithText:[DataHelper formattedDisplayForInteger:self.badgeCount]
                                       font:[self fontForBadgeCount]
                                     offset:offset];
        
    } else {
        
        // Restore frame.
        CGRect frame = self.frame;
        frame.size.width = [self imageForHasNotifications:NO selected:NO].size.width;
        
        if (self.on) {
            
            // Swap the off image in.
            self.offButtonIcon.alpha = 0.0;
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.frame = frame;
                                 self.offButtonIcon.alpha = 1.0;
                                 self.onButtonIcon.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        
        // Mark as OFF.
        self.offButtonIcon.hidden = NO;
        self.onButtonIcon.hidden = YES;
        self.on = NO;
    }
    
}

- (UIFont *)fontForBadgeCount {
    return kFont;
}

- (void)loadData {
    if (self.loading) {
        return;
    }
    self.loading = YES;
    
    CKUser *currentUser = [CKUser currentUser];
    if ([currentUser isSignedIn]) {
        
        [currentUser numUnreadNotificationsCompletion:^(int count) {
            
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

- (void)reset {
    
    // Reset the views.
    [self.offButtonIcon removeFromSuperview];
    [self.onButtonIcon removeFromSuperview];
    [self.containerView removeFromSuperview];
    _offButtonIcon = nil;
    _onButtonIcon = nil;
    _containerView = nil;
    
    [self.containerView addSubview:self.offButtonIcon];
    [self.containerView addSubview:self.onButtonIcon];
    
    CGSize containerSize = self.containerView.frame.size;
    CGRect frame = self.frame;
    frame.size = containerSize;
    self.frame = frame;
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.offButtonIcon];
    [self.containerView addSubview:self.onButtonIcon];
}

@end
