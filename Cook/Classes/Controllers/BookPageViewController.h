//
//  BookPageViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;
@class BookPageViewController;

@protocol BookPageViewControllerDelegate <NSObject>

- (void)bookPageViewControllerCloseRequested;
- (void)bookPageViewControllerShowRecipe:(CKRecipe *)recipe;
- (void)bookPageViewControllerPanEnable:(BOOL)enable;
- (void)bookPageViewController:(BookPageViewController *)bookPageViewController editModeRequested:(BOOL)editMode;

@end

@interface BookPageViewController : UIViewController

@property (nonatomic, weak) id<BookPageViewControllerDelegate> bookPageDelegate;
@property (nonatomic, assign) BOOL editMode;

- (void)addCloseButtonLight:(BOOL)white;
- (void)applyPageEdgeShadows;
- (void)enableEditMode:(BOOL)editMode;
- (void)enableEditMode:(BOOL)editMode completion:(void (^)())completion;

@end
