//
//  BookNavigationViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookNavigationHelper.h"

@class CKBook;
@class CKRecipe;

@protocol BookNavigationViewControllerDelegate

- (void)bookNavigationControllerCloseRequested;
- (void)bookNavigationControllerRecipeRequested:(CKRecipe *)recipe;

@end

@interface BookNavigationViewController : UICollectionViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate;
- (void)updateWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion;
- (void)setActive:(BOOL)active;

@end
