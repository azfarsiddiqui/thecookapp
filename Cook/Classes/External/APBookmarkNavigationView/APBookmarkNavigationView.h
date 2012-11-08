//
//  APBookmarkNavigationView.h
//  APBookmarkNavigationViewDemo
//
//  Created by Jeff Tan-Ang on 20/06/12.
//  Copyright (c) 2012 Apps Perhaps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APBookmarkNavigationViewDelegate

- (void)bookmarkDidSelectOptionAtIndex:(NSUInteger)optionIndex;

@end

@interface APBookmarkNavigationView : UIView <UIGestureRecognizerDelegate>

- (id)initWithOptions:(NSArray *)options delegate:(id<APBookmarkNavigationViewDelegate>)delegate;
- (void)show:(BOOL)show animated:(BOOL)animated;

@end
