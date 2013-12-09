//
//  FollowReloadButtonView.h
//  Cook
//
//  Created by Jeff Tan-Ang on 9/12/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FollowReloadButtonViewDelegate <NSObject>

- (void)followReloadButtonViewTapped;

@end

@interface FollowReloadButtonView : UIView

- (id)initWithDelegate:(id<FollowReloadButtonViewDelegate>)delegate;
- (void)enableActivity:(BOOL)activity;

@end
