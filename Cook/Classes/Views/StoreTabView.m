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

@property (nonatomic, weak) id<StoreTabViewDelegate> delegate;
@property (nonatomic, strong) NSArray *tabViews;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) NSInteger numTabs;
@property (nonatomic, assign) NSInteger selectedTabIndex;


@end

@implementation StoreTabView

#define kHeight         105
#define kMinTabHeight   83.0
#define kMaxTabHeight   103.0
#define kCategoriesTab  0
#define kFeaturedTab    1
#define kWorldTab       2

- (id)initWithUnitTabViews:(NSArray *)storeUnitTabViews delegate:(id<StoreTabViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.delegate = delegate;
        self.tabViews = storeUnitTabViews;
        self.backgroundColor = [UIColor clearColor];
        [self initTabs];
    }
    return self;
}

- (void)selectTabAtIndex:(NSInteger)tabIndex {
    [self selectTabAtIndex:tabIndex force:YES];
}

#pragma mark - Private methods

- (void)initTabs {
    
    CGPoint offset = CGPointZero;
    
    for (StoreUnitTabView *unitTabView in self.tabViews) {
        unitTabView.frame = (CGRect){
            offset.x,
            offset.y,
            unitTabView.frame.size.width,
            unitTabView.frame.size.height
        };
        self.bounds = CGRectUnion(self.bounds, unitTabView.frame);
        offset.x += unitTabView.frame.size.width;
        [self addSubview:unitTabView];
    }
    
    // Register tap.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapGesture];
    
}

- (void)tapped:(UITapGestureRecognizer *)tapGesture {
    if (!self.userInteractionEnabled) {
        return;
    }
    
    CGPoint location = [tapGesture locationInView:self];
    
    // Detech which tab has been selected.
    [self.tabViews enumerateObjectsUsingBlock:^(StoreUnitTabView *unitTabView, NSUInteger tabIndex, BOOL *stop) {
        if (CGRectContainsPoint(unitTabView.frame, location)) {
            [self selectTabAtIndex:tabIndex force:YES];
            stop = YES;
        }
    }];
    
}

- (void)selectedTabAtIndex:(NSInteger)tabIndex {
    [self.delegate storeTabView:self selectedTabAtIndex:tabIndex];
}

- (void)selectTabAtIndex:(NSInteger)tabIndex force:(BOOL)force {
    if (!force && self.selectedTabIndex == tabIndex) {
        return;
    }
    
    self.selectedTabIndex = tabIndex;
    self.animating = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^{
                         [self.tabViews enumerateObjectsUsingBlock:^(StoreUnitTabView *unitTabView, NSUInteger tabIndex, BOOL *stop) {
                             [unitTabView select:(self.selectedTabIndex == tabIndex)];
                         }];
                     }
                     completion:^(BOOL finished) {
                         self.animating = NO;
                         [self selectedTabAtIndex:tabIndex];
                     }];
}

@end
