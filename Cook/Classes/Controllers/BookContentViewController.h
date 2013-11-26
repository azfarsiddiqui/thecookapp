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
- (void)bookContentViewControllerScrolledOffset:(CGFloat)offset page:(NSString *)page distanceTravelled:(CGFloat)distance;
- (BOOL)bookContentViewControllerAddSupportedForPage:(NSString *)page;
- (void)bookContentViewControllerShowNavigationView:(BOOL)show;
- (NSInteger)bookContentViewControllerNumBatchesForPage:(NSString *)page;
- (NSInteger)bookContentViewControllerCurrentBatchIndexForPage:(NSString *)page;
- (void)bookContentViewControllerLoadMoreForPage:(NSString *)page;

@end

@interface BookContentViewController : BookPageViewController

@property BOOL isFastForward;

- (id)initWithBook:(CKBook *)book page:(NSString *)page delegate:(id<BookContentViewControllerDelegate>)delegate;
- (void)loadData;
- (void)loadPageContent;
- (CGPoint)currentScrollOffset;
- (void)setScrollOffset:(CGPoint)scrollOffset;
- (void)applyOverlayAlpha:(CGFloat)alpha;
- (void)loadMoreRecipes:(NSArray *)recipes;

@end
