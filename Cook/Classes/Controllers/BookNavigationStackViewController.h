//
//  BookPagingStackViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 12/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookNavigationViewControllerDelegate.h"
#import "BookNavigationHelper.h"

@class CKBook;
@class CKRecipe;

@interface BookNavigationStackViewController : UICollectionViewController

- (id)initWithBook:(CKBook *)book delegate:(id<BookNavigationViewControllerDelegate>)delegate;
- (void)updateWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion;
- (void)setActive:(BOOL)active;
- (void)updateBinderAlpha:(CGFloat)alpha;

@end
