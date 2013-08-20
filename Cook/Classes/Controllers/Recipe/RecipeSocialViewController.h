//
//  RecipeSocialViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 20/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

@protocol RecipeSocialViewControllerDelegate <NSObject>

- (void)recipeSocialViewControllerCloseRequested;

@end

@interface RecipeSocialViewController : UICollectionViewController

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeSocialViewControllerDelegate>)delegate;

@end
