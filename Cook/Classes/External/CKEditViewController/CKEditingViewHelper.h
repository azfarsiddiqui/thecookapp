//
//  CKEditingViewHelper.h
//  CKEditViewControllerDemo
//
//  Created by Jeff Tan-Ang on 12/04/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKEditingViewHelper : NSObject

+ (CKEditingViewHelper *)sharedInstance;
- (void)wrapEditingView:(UIView *)editingView;
- (void)unwrapEditingView:(UIView *)editingView;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap;
- (void)wrapEditingView:(UIView *)editingView wrap:(BOOL)wrap contentInsets:(UIEdgeInsets)contentInsets;

@end
