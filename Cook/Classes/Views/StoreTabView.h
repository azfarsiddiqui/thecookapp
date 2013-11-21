//
//  StoreTabView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 6/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreTabView;

@protocol StoreTabViewDelegate

- (void)storeTabView:(StoreTabView *)storeTabView selectedTabAtIndex:(NSInteger)tabIndex;

@end

@interface StoreTabView : UIView

- (id)initWithUnitTabViews:(NSArray *)storeUnitTabViews delegate:(id<StoreTabViewDelegate>)delegate;
- (void)selectTabAtIndex:(NSInteger)tabIndex;

@end
