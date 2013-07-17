//
//  BookSocialViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 16/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@protocol BookSocialViewControllerDelegate <NSObject>

- (void)bookSocialViewControllerCloseRequested;

@end

@interface BookSocialViewController : UIViewController

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<BookSocialViewControllerDelegate>)delegate;

@end
