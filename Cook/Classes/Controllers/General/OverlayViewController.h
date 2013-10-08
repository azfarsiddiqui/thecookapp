//
//  OverlayViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 23/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@interface OverlayViewController : UIViewController

@property (nonatomic, strong) UILabel *statusMessageLabel;

- (void)clearStatusMessage;
- (void)displayStatusMessage:(NSString *)statusMessage;
- (void)showContextWithRecipe:(CKRecipe *)recipe;
- (void)showContextModalViewController:(UIViewController *)viewController;

@end
