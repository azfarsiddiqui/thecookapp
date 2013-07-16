//
//  BookPageViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@protocol BookPageViewControllerDelegate <NSObject>

- (void)bookPageViewControllerShowNavigationBar:(BOOL)show;
- (void)bookPageViewControllerShowRecipe:(CKRecipe *)recipe;

@end

@interface BookPageViewController : UIViewController

@property (nonatomic, weak) id<BookPageViewControllerDelegate> bookPageDelegate;

@end
