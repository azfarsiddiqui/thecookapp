//
//  RecipeShareViewController.h
//  Cook
//
//  Created by Gerald on 18/11/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareViewController.h"

@interface RecipeShareViewController : ShareViewController

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<ShareViewControllerDelegate>)delegate;

@end
