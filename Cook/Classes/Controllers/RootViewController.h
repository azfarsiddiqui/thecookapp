//
//  RootViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKModalView.h"
#import "CKIntroViewController.h"
#import "MenuViewController.h"

@interface RootViewController : UIViewController <CKModalViewContentDelegate, CKIntroViewControllerDelegate,
    MenuViewControllerDelegate>

@end
