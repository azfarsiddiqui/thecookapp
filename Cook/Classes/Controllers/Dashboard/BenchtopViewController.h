//
//  CKBenchtopViewController.h
//  CKBenchtopViewControllerDemo
//
//  Created by Jeff Tan-Ang on 9/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BenchtopDelegate.h"
#import "BookViewController.h"
#import "MenuViewController.h"
#import "BenchtopEditViewController.h"

@interface BenchtopViewController : UICollectionViewController <BenchtopDelegate, BookViewControllerDelegate,
    MenuViewControllerDelegate, UIPopoverControllerDelegate, BenchtopEditViewControllerDelegate>

- (void)enable:(BOOL)enable;
- (void)freeze:(BOOL)freeze;

@end
