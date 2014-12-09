//
//  BookPageViewController.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKSaveableContent.h"

@class CKRecipe;
@class BookPageViewController;
@class ShareViewController;

@protocol BookPageViewControllerDelegate <NSObject>

- (void)bookPageViewControllerCloseRequested;
- (void)bookPageViewControllerShowRecipe:(CKRecipe *)recipe;
- (void)bookPageViewControllerPanEnable:(BOOL)enable;
- (void)bookPageViewController:(BookPageViewController *)bookPageViewController editModeRequested:(BOOL)editMode;
- (void)bookPageViewController:(BookPageViewController *)bookPageViewController editing:(BOOL)editing;
- (NSArray *)bookPageViewControllerAllPages;

@end

@interface BookPageViewController : UIViewController <CKSaveableContent>

@property (nonatomic, weak) id<BookPageViewControllerDelegate> bookPageDelegate;
@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, strong) ShareViewController *shareController;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *closeButton;

- (void)addCloseButtonLight:(BOOL)white;
- (void)addShareButtonLight:(BOOL)white;
- (void)applyPageEdgeShadows;
- (void)enableEditMode:(BOOL)editMode;
- (void)enableEditMode:(BOOL)editMode completion:(void (^)())completion;
- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated completion:(void (^)())completion;
- (UIEdgeInsets)pageContentInsets;
- (void)showIntroCard:(BOOL)show;
- (void)showShareOverlay:(BOOL)show;

@end
