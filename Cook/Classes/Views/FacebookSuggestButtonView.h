//
//  FacebookSuggestButtonView.h
//  FacebookStoreButtonDemo
//
//  Created by Jeff Tan-Ang on 8/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FacebookSuggestButtonViewDelegate <NSObject>

- (void)facebookSuggestButtonViewTapped;

@end

@interface FacebookSuggestButtonView : UIView

- (id)initWithDelegate:(id<FacebookSuggestButtonViewDelegate>)delegate;
- (void)enableActivity:(BOOL)activity;

@end
