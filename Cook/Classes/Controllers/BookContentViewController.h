//
//  BookCategoryViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookPageViewController.h"

@class CKBook;
@class CKRecipe;

@protocol BookContentViewControllerDelegate <NSObject>

- (NSArray *)recipesForBookContentViewControllerForPage:(NSString *)page;
- (CKRecipe *)featuredRecipeForBookContentViewControllerForPage:(NSString *)page;
- (void)bookContentViewControllerScrolledOffset:(CGFloat)offset page:(NSString *)page;

@end

@interface BookContentViewController : BookPageViewController

- (id)initWithBook:(CKBook *)book page:(NSString *)page delegate:(id<BookContentViewControllerDelegate>)delegate;
- (void)loadData;
- (CGPoint)currentScrollOffset;
- (void)setScrollOffset:(CGPoint)scrollOffset;
- (void)applyOverlayAlpha:(CGFloat)alpha;

@end
