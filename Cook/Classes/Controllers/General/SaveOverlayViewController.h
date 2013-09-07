//
//  SaveOverlayViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 7/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKProgressView;

@interface SaveOverlayViewController : UIViewController

- (id)initWithTitle:(NSString *)title;
- (void)updateProgress:(CGFloat)progress;

@end
