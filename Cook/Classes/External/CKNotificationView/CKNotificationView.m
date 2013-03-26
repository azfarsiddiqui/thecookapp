//
//  CKNotificationView.m
//  CKNotificationViewDemo
//
//  Created by Jeff Tan-Ang on 26/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKNotificationView.h"

@interface CKNotificationView ()

@property (nonatomic, strong) id<CKNotificationViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *notifyIconView;
@property (nonatomic, strong) UIImageView *notifyBackgroundView;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *itemViews;

@end

@implementation CKNotificationView

#define kIconOffset             4.0
#define kIconItemsGap           50.0
#define kIconBadgeOffset        42.0
#define kIconBadgeRightOffset   8.0
#define kBadgeFont              [UIFont boldSystemFontOfSize:16]
#define kItemCount              4
#define kInterItemGap           5.0

- (id)initWithDelegate:(id<CKNotificationViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.delegate = delegate;
        
        // Notify icon.
        UIImageView *notifyIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_icons_notifications.png"]];
        notifyIconView.userInteractionEnabled = YES;
        notifyIconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        notifyIconView.frame = CGRectMake(kIconOffset, 0.0, notifyIconView.frame.size.width, notifyIconView.frame.size.height);
        self.frame = CGRectMake(0.0, 0.0, notifyIconView.frame.origin.x + notifyIconView.frame.size.width, notifyIconView.frame.size.height);
        [self addSubview:notifyIconView];
        self.notifyIconView = notifyIconView;
        
        // Notify alert background view.
        UIImage *notifyBackgroundImage = [[UIImage imageNamed:@"cook_dash_notitifcations_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 19.0, 0.0, 19.0)];
        UIImageView *notifyBackgroundView = [[UIImageView alloc] initWithImage:notifyBackgroundImage];
        notifyBackgroundView.userInteractionEnabled = YES;
        notifyBackgroundView.frame = CGRectMake(5.0, 5.0, notifyBackgroundView.frame.size.width, notifyBackgroundView.frame.size.height);
        notifyBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self insertSubview:notifyBackgroundView belowSubview:notifyIconView];
        notifyBackgroundView.hidden = YES;
        self.notifyBackgroundView = notifyBackgroundView;
        
        // Register tap for background.
        UITapGestureRecognizer *backgroundTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTapped:)];
        [notifyBackgroundView addGestureRecognizer:backgroundTapGesture];
        
        // Badge label.
        UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        badgeLabel.backgroundColor = [UIColor clearColor];
        badgeLabel.font = kBadgeFont;
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.shadowColor = [UIColor blackColor];
        badgeLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        badgeLabel.hidden = YES;
        [self addSubview:badgeLabel];
        self.badgeLabel = badgeLabel;
        
        // Register tap.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconTapped:)];
        [notifyIconView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)clear {
    [self setNotificationItems:nil];
}

- (void)setNotificationItems:(NSArray *)notificationItems {
    self.items = [NSMutableArray arrayWithArray:notificationItems];
    self.notifyBackgroundView.hidden = ([self.items count] == 0);
    
    if ([self.items count] > 0) {
        self.badgeLabel.text = [NSString stringWithFormat:@"%d", [self.items count]];
        [self.badgeLabel sizeToFit];
        self.badgeLabel.frame = CGRectMake(self.notifyIconView.frame.origin.x + kIconBadgeOffset,
                                           floorf((self.bounds.size.height - self.badgeLabel.frame.size.height) / 2.0) - 1.0,
                                           self.badgeLabel.frame.size.width,
                                           self.badgeLabel.frame.size.height);
        self.notifyBackgroundView.frame = CGRectMake(self.notifyBackgroundView.frame.origin.x,
                                                     self.notifyBackgroundView.frame.origin.y,
                                                     self.badgeLabel.frame.origin.x + self.badgeLabel.frame.size.width + kIconBadgeRightOffset,
                                                     self.notifyBackgroundView.frame.size.height);
        
        // Fan out the items to the right of the badge.
        CGFloat itemOffset = self.notifyBackgroundView.frame.origin.x + self.notifyBackgroundView.frame.size.width + kIconItemsGap;
        NSInteger itemCount = ([self.items count] > kItemCount) ? kItemCount : [self.items count];
        self.itemViews = [NSMutableArray arrayWithCapacity:itemCount];
        for (NSInteger itemIndex = 0; itemIndex < itemCount; itemIndex++) {
            
            // Calls the delegate for custom item view.
            UIView *itemView = [self.delegate notificationItemViewForIndex:itemIndex];
            if (itemView == nil) {
                continue;
            }
            
            itemView.userInteractionEnabled = YES;
            itemView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            itemView.frame = CGRectMake(itemOffset,
                                        floorf((self.bounds.size.height - itemView.frame.size.height) / 2.0),
                                        itemView.frame.size.width,
                                        itemView.frame.size.height);
            [self addSubview:itemView];
            [self.itemViews addObject:itemView];
            itemOffset += itemView.frame.size.width + kInterItemGap;
            
            // Register taps on individual item views.
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewTapped:)];
            [itemView addGestureRecognizer:tapGesture];            
            
            // Prepare for transition.
            itemView.transform = CGAffineTransformMakeTranslation(-20.0, 0.0);
            //itemView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            itemView.alpha = 0.0;
        }
        
        // Update frame to accomodate.
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                itemOffset,
                                self.notifyIconView.frame.size.height);
        
        self.badgeLabel.hidden = NO;
        self.notifyBackgroundView.hidden = NO;
        self.badgeLabel.alpha = 0.0;
        self.notifyBackgroundView.alpha = 0.0;
        self.badgeLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
        
        // Animate them all in,
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.badgeLabel.alpha = 1.0;
                             self.notifyBackgroundView.alpha = 1.0;
                             self.badgeLabel.transform = CGAffineTransformIdentity;
                             for (UIView *itemView in self.itemViews) {
                                 itemView.transform = CGAffineTransformIdentity;
                                 itemView.alpha = 1.0;
                             }
                         }
                         completion:^(BOOL finished) {
            
                         }];
        
    } else {
        
        // Update self frame.
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.notifyIconView.frame.origin.x + self.notifyIconView.frame.size.width,
                                self.notifyIconView.frame.size.height);
        
        // Animate them all out.,
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.badgeLabel.alpha = 0.0;
                             self.badgeLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             self.notifyBackgroundView.alpha = 0.0;
                             for (UIView *itemView in self.itemViews) {
                                 itemView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                 itemView.alpha = 0.0;
                             }
                         }
                         completion:^(BOOL finished) {
                             self.badgeLabel.hidden = YES;
                             self.notifyBackgroundView.hidden = YES;
                             self.badgeLabel.transform = CGAffineTransformIdentity;
                             [self.itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                         }];

    }
}

- (BOOL)hasNotificationItems {
    return ([self.items count] > 0);
}

#pragma mark - Private methods

- (void)iconTapped:(UITapGestureRecognizer *)tapGesture {
    [self.delegate notificationViewTapped:self];
}

- (void)itemViewTapped:(UITapGestureRecognizer *)tapGesture {
    UIView *tappedView = [tapGesture view];
    [self.delegate notificationView:self tappedForItemIndex:[self.itemViews indexOfObject:tappedView]];
}

@end
