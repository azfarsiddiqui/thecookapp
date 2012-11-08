//
//  APBookmarkNavigationView.h
//  APBookmarkNavigationViewDemo
//
//  Created by Jeff Tan-Ang on 20/06/12.
//  Copyright (c) 2012 Apps Perhaps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APBookmarkNavigationViewDelegate

- (NSUInteger)bookmarkNumberOfOptions;
- (UIView *)bookmarkIconView;
- (UIView *)bookmarkOptionViewAtIndex:(NSUInteger)optionIndex;
- (NSString *)bookmarkOptionLabelAtIndex:(NSUInteger)optionIndex;
- (void)bookmarkDidSelectOptionAtIndex:(NSUInteger)optionIndex;

@end

@interface APBookmarkNavigationView : UIView <UIGestureRecognizerDelegate>

- (id)initWithDelegate:(id<APBookmarkNavigationViewDelegate>)delegate;
- (void)show:(BOOL)show animated:(BOOL)animated;

@end
