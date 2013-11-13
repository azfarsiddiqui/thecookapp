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
@property (nonatomic, strong) StoreUnitTabView *categoriesTabView;
@property (nonatomic, strong) StoreUnitTabView *featuredTabView;
@property (nonatomic, strong) StoreUnitTabView *worldTabView;

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
#define kCategoriesTab  0
#define kFeaturedTab    1
#define kWorldTab       2

- (id)initWithDelegate:(id<StoreTabViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
        [self initTabs];
    }
    return self;
}

- (void)selectCategories {
    [self selectTabAtIndex:kCategoriesTab force:YES];
}

- (void)selectFeatured {
    [self selectTabAtIndex:kFeaturedTab force:YES];
}

- (void)selectWorld {
    [self selectTabAtIndex:kWorldTab force:YES];
}

#pragma mark - Properties

- (StoreUnitTabView *)categoriesTabView {
    if (!_categoriesTabView) {
        _categoriesTabView = [[StoreUnitTabView alloc] initWithText:@"CATEGORIES"
                                                               icon:[UIImage imageNamed:@"cook_library_icons_categories.png"]
                                                            offIcon:[UIImage imageNamed:@"cook_library_icons_categories_off.png"]];
    }
    return _categoriesTabView;
}

- (StoreUnitTabView *)featuredTabView {
    if (!_featuredTabView) {
        _featuredTabView = [[StoreUnitTabView alloc] initWithText:@"FEATURED"
                                                             icon:[UIImage imageNamed:@"cook_library_icons_featured.png"]
                                                          offIcon:[UIImage imageNamed:@"cook_library_icons_featured_off.png"]];
    }
    return _featuredTabView;
}

- (StoreUnitTabView *)worldTabView {
    if (!_worldTabView) {
        _worldTabView = [[StoreUnitTabView alloc] initWithText:@"WORLD"
                                                          icon:[UIImage imageNamed:@"cook_library_icons_world.png"]
                                                       offIcon:[UIImage imageNamed:@"cook_library_icons_world_off.png"]];
    }
    return _worldTabView;
}

#pragma mark - Private methods

- (void)initTabs {
    
    CGPoint offset = CGPointZero;
    
    // Categories Tab.
    self.categoriesTabView.frame = (CGRect){
        offset.x,
        offset.y,
        self.categoriesTabView.frame.size.width,
        self.categoriesTabView.frame.size.height
    };
    [self addSubview:self.categoriesTabView];
    self.bounds = CGRectUnion(self.bounds, self.categoriesTabView.frame);
    offset.x += self.categoriesTabView.frame.size.width;
    
    // Featured Tab.
    self.featuredTabView.frame = (CGRect){
        offset.x,
        offset.y,
        self.featuredTabView.frame.size.width,
        self.featuredTabView.frame.size.height
    };
    [self addSubview:self.featuredTabView];
    self.bounds = CGRectUnion(self.bounds, self.featuredTabView.frame);
    offset.x += self.featuredTabView.frame.size.width;
    
    // World Tab.
    self.worldTabView.frame = (CGRect){
        offset.x,
        offset.y,
        self.worldTabView.frame.size.width,
        self.worldTabView.frame.size.height
    };
    [self addSubview:self.worldTabView];
    self.bounds = CGRectUnion(self.bounds, self.worldTabView.frame);
    
    // Register tap.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapGesture];
    
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    CGPoint location = [tapGesture locationInView:self];
    if (CGRectContainsPoint(self.categoriesTabView.frame, location)) {
        [self selectCategories];
    } else if (CGRectContainsPoint(self.featuredTabView.frame, location)) {
        [self selectFeatured];
    } else if (CGRectContainsPoint(self.worldTabView.frame, location)) {
        [self selectWorld];
    }
}

- (void)selectedTabAtIndex:(NSUInteger)tabIndex {
    switch (tabIndex) {
        case kCategoriesTab:
            [self.delegate storeTabSelectedCategories];
            break;
        case kFeaturedTab:
            [self.delegate storeTabSelectedFeatured];
            break;
        case kWorldTab:
            [self.delegate storeTabSelectedWorld];
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
                         [self.categoriesTabView select:(tabIndex == kCategoriesTab)];
                         [self.featuredTabView select:(tabIndex == kFeaturedTab)];
                         [self.worldTabView select:(tabIndex == kWorldTab)];
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                         [self selectedTabAtIndex:tabIndex];
                     }];
    
}

@end
