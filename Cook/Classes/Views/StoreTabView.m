//
//  StoreTabView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 6/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreTabView.h"
#import "Theme.h"

@interface StoreTabView ()

@property (nonatomic, assign) id<StoreTabViewDelegate> delegate;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) NSMutableArray *iconViews;
@property (nonatomic, strong) NSMutableArray *tabs;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) NSInteger selectedTabIndex;

@end

@implementation StoreTabView

#define kMinTabHeight   83.0
#define kMaxTabHeight   103.0
#define kFeaturedTab    0
#define kFriendsTab     1
#define kSuggestedTab   2

- (id)initWithDelegate:(id<StoreTabViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
        self.selectedTabIndex = -1;
        
        UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_dash_library_tab_wrap.png"]];
        self.frame = CGRectMake(0.0, 0.0, topImageView.frame.size.width, topImageView.frame.size.height + kMaxTabHeight);
        [self addSubview:topImageView];
        self.topImageView = topImageView;
        
        [self initTabs];
    }
    return self;
}

- (void)selectFeatured {
    [self selectTabAtIndex:kFeaturedTab force:YES];
}

- (void)selectFriends {
    [self selectTabAtIndex:kFriendsTab force:YES];
}

- (void)selectSuggested {
    [self selectTabAtIndex:kSuggestedTab force:YES];
}

#pragma mark - Private methods

- (void)initTabs {
    self.titles = [NSArray arrayWithObjects:@"FEATURED", @"FRIENDS", @"SUGGESTED", nil];
    self.icons = [NSArray arrayWithObjects:@"cook_dash_library_icon_featured.png", @"cook_dash_library_icon_friends.png", @"cook_dash_library_icon_suggested.png", nil];
    self.iconViews = [NSMutableArray arrayWithCapacity:[self.titles count]];
    self.tabs = [NSMutableArray arrayWithCapacity:[self.titles count]];
    
    CGFloat offset = -3.0;
    
    for (NSInteger tabIndex = 0; tabIndex < [self.titles count]; tabIndex++) {
        
        UIImage *tabImage = nil;
        if (tabIndex == 0) {
            tabImage = [UIImage imageNamed:@"cook_dash_library_tab_left.png"];
        } else if (tabIndex == [self.titles count] - 1) {
            tabImage = [UIImage imageNamed:@"cook_dash_library_tab_right.png"];
        } else {
            tabImage = [UIImage imageNamed:@"cook_dash_library_tab_middle.png"];
        }
        tabImage = [tabImage resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 0.0, 81.0, 0.0)];
        
        // Button
        UIImageView *tabImageView = [[UIImageView alloc] initWithImage:tabImage];
        tabImageView.userInteractionEnabled = YES;
        tabImageView.frame = CGRectMake(offset,
                                        self.topImageView.frame.origin.y + self.topImageView.frame.size.height,
                                        tabImageView.frame.size.width,
                                        kMinTabHeight);
        [self addSubview:tabImageView];
        [self.tabs addObject:tabImageView];
        
        // Title
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        label.backgroundColor = [UIColor clearColor];
        label.font = [Theme storeTabFont];
        label.textColor = [Theme storeTabTextColour];
        label.shadowOffset = CGSizeMake(0.0, -1.0);
        label.shadowColor = [Theme storeTabTextShadowColour];
        label.text = [self.titles objectAtIndex:tabIndex];
        [label sizeToFit];
        label.frame = CGRectMake(floorf((tabImageView.bounds.size.width - label.frame.size.width) / 2.0),
                                 16.0,
                                 label.frame.size.width,
                                 label.frame.size.height);
        [tabImageView addSubview:label];
        
        // Icon.
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.icons objectAtIndex:tabIndex]]];
        iconView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        iconView.frame = CGRectMake(floorf((tabImageView.bounds.size.width - iconView.frame.size.width) / 2.0),
                                    10.0,
                                    iconView.frame.size.width,
                                    iconView.frame.size.height);
        iconView.alpha = 0.0;
        [tabImageView addSubview:iconView];
        [self.iconViews addObject:iconView];
        
        // Register tap on tab image.
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabTapped:)];
        [tabImageView addGestureRecognizer:tapGesture];
        
        // Next tab offset
        offset += tabImageView.frame.size.width - 19.0;
    }
    
    // Bring the middle tab to front.
    UIView *middleTabView = [self.tabs objectAtIndex:1];
    [self bringSubviewToFront:middleTabView];
    
    // Select the first tab.
    [self selectFeatured];
}

#pragma mark - Private methods

- (void)tabTapped:(UITapGestureRecognizer *)tapGesture {
    if (self.animating) {
        return;
    }
    
    UIView *sender = tapGesture.view;
    NSUInteger tabIndex = [self.tabs indexOfObject:sender];
    [self selectTabAtIndex:tabIndex];
}

- (void)selectedTabAtIndex:(NSUInteger)tabIndex {
    switch (tabIndex) {
        case kFeaturedTab:
            [self.delegate storeTabSelectedFeatured];
            break;
        case kFriendsTab:
            [self.delegate storeTabSelectedFriends];
            break;
        case kSuggestedTab:
            [self.delegate storeTabSelectedSuggested];
            break;
        default:
            break;
    }
}

- (void)selectTabAtIndex:(NSUInteger)tabIndex {
    [self selectTabAtIndex:tabIndex force:NO];
}

- (void)selectTabAtIndex:(NSUInteger)tabIndex force:(BOOL)force {
    if (!force && self.selectedTabIndex == tabIndex) {
        return;
    }
    
    self.selectedTabIndex = tabIndex;
    self.animating = YES;
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         // Unselect all buttons except the current one.
                         for (NSInteger buttonIndex = 0; buttonIndex < [self.tabs count]; buttonIndex++) {
                             UIView *button = [self.tabs objectAtIndex:buttonIndex];
                             CGRect buttonFrame = button.frame;
                             if (buttonIndex == tabIndex) {
                                 buttonFrame.size.height = kMaxTabHeight;
                             } else {
                                 buttonFrame.size.height = kMinTabHeight;
                             }
                             
                             button.frame = buttonFrame;
                         }
                         
                         // Fade out existing iconView.
                         for (UIImageView *iconView in self.iconViews) {
                             iconView.alpha = 0.0;
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                         
                         [UIView animateWithDuration:0.15
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              UIImageView *iconView = [self.iconViews objectAtIndex:tabIndex];
                                              iconView.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                          }];

                         
                         [self selectedTabAtIndex:tabIndex];
                     }];
    
}

@end
