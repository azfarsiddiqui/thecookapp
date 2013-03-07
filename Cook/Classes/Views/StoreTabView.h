//
//  StoreTabView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 6/03/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StoreTabViewDelegate

- (void)storeTabSelectedFeatured;
- (void)storeTabSelectedFriends;
- (void)storeTabSelectedSuggested;

@end

@interface StoreTabView : UIView

- (id)initWithDelegate:(id<StoreTabViewDelegate>)delegate;
- (void)selectFeatured;
- (void)selectFriends;
- (void)selectSuggested;

@end
