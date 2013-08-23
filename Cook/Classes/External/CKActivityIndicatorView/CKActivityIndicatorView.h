//
//  APActivityIndicatorView.h
//  APActivityIndicatorViewDemo
//
//  Created by Jeff Tan-Ang on 22/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CKActivityIndicatorViewStyle) {
    CKActivityIndicatorViewStyleLarge
};

@interface CKActivityIndicatorView : UIView

@property (nonatomic, assign) BOOL hidesWhenStopped;

- (id)initWithStyle:(CKActivityIndicatorViewStyle)style;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
