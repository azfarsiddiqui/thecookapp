//
//  StoreTabView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 6/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreTabView.h"
#import "Theme.h"
#import "StoreUnitTabView.h"

@interface StoreTabView ()

@property (nonatomic, assign) id<StoreTabViewDelegate> delegate;
@property (nonatomic, strong) StoreUnitTabView *suggestedTabView;
@property (nonatomic, strong) StoreUnitTabView *featuredTabView;
@property (nonatomic, strong) StoreUnitTabView *friendsTabView;

@property (nonatomic, strong) UIImage *selectedTabImage;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) NSMutableArray *iconViews;
@property (nonatomic, strong) NSMutableArray *tabs;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) NSInteger selectedTabIndex;


@end

@implementation StoreTabView

#define kHeight         105
#define kMinTabHeight   83.0
#define kMaxTabHeight   103.0
#define kSuggestedTab   0
#define kFeaturedTab    1
#define kFriendsTab     2

- (id)initWithDelegate:(id<StoreTabViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
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
    
    CGPoint offset = CGPointZero;
    
    StoreUnitTabView *suggestedTabView = [[StoreUnitTabView alloc] initWithText:@"SUGGESTED"
                                                                           icon:[UIImage imageNamed:@"cook_library_icons_suggested.png"]];
    suggestedTabView.frame = (CGRect){
        offset.x,
        offset.y,
        suggestedTabView.frame.size.width,
        suggestedTabView.frame.size.height
    };
    [self addSubview:suggestedTabView];
    self.suggestedTabView = suggestedTabView;
    self.bounds = CGRectUnion(self.bounds, self.suggestedTabView.frame);
    offset.x += self.suggestedTabView.frame.size.width;
    
    StoreUnitTabView *featuredTabView = [[StoreUnitTabView alloc] initWithText:@"FEATURED"
                                                                          icon:[UIImage imageNamed:@"cook_library_icons_featured.png"]];
    featuredTabView.frame = (CGRect){
        offset.x,
        offset.y,
        featuredTabView.frame.size.width,
        featuredTabView.frame.size.height
    };
    [self addSubview:featuredTabView];
    self.featuredTabView = featuredTabView;
    self.bounds = CGRectUnion(self.bounds, self.featuredTabView.frame);
    offset.x += self.featuredTabView.frame.size.width;
    
    StoreUnitTabView *friendsTabView = [[StoreUnitTabView alloc] initWithText:@"FRIENDS"
                                                                         icon:[UIImage imageNamed:@"cook_library_icons_friends.png"]];
    friendsTabView.frame = (CGRect){
        offset.x,
        offset.y,
        friendsTabView.frame.size.width,
        friendsTabView.frame.size.height
    };
    [self addSubview:friendsTabView];
    self.friendsTabView = friendsTabView;
    self.bounds = CGRectUnion(self.bounds, self.friendsTabView.frame);
    
    // Register tap.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapGesture];
    
    // Select the featured tab.
    [self selectFeatured];
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    CGPoint location = [tapGesture locationInView:self];
    if (CGRectContainsPoint(self.suggestedTabView.frame, location)) {
        [self selectSuggested];
    } else if (CGRectContainsPoint(self.featuredTabView.frame, location)) {
        [self selectFeatured];
    } else if (CGRectContainsPoint(self.friendsTabView.frame, location)) {
        [self selectFriends];
    }
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
    
    // Bring the selected tab upfront.
    UIView *selectedTabView = [self.tabs objectAtIndex:tabIndex];
    [self bringSubviewToFront:selectedTabView];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.suggestedTabView select:(tabIndex == kSuggestedTab)];
                         [self.featuredTabView select:(tabIndex == kFeaturedTab)];
                         [self.friendsTabView select:(tabIndex == kFriendsTab)];
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                         [self selectedTabAtIndex:tabIndex];
                     }];
    
}

@end
