//
//  BenchtopEditViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 5/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BenchtopEditViewControllerDelegate

- (void)editViewControllerCancelRequested;
- (void)editViewControllerDoneRequested;

@end

@interface BenchtopEditViewController : UIViewController

- (id)initWithDelegate:(id<BenchtopEditViewControllerDelegate>)delegate;
- (void)showEditPalette:(BOOL)show animated:(BOOL)animated;

@end
