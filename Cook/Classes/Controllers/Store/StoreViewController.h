//
//  StoreViewController.h
//  BenchtopDemo
//
//  Created by Jeff Tan-Ang on 29/11/12.
//  Copyright (c) 2012 Cook App Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchtopViewControllerDelegate.h"

@interface StoreViewController : UIViewController

@property (nonatomic, weak) id<BenchtopViewControllerDelegate> delegate;

- (void)enable:(BOOL)enable;
- (CGFloat)visibleHeight;
- (CGFloat)bottomShadowHeight;

@end
