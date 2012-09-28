//
//  CKIntroViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 27/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKIntroViewControllerDelegate

- (void)introViewDismissRequested;

@end

@interface CKIntroViewController : UIViewController

- (id)initWithDelegate:(id<CKIntroViewControllerDelegate>)delegate;

@end
