//
//  RecipeShareViewController.h
//  Cook
//
//  Created by Gerald Kim on 31/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKRecipe;

typedef enum {
    CKShareTwitter = 0,
    CKShareFacebook,
    CKShareMail,
    CKShareMessage
} CKShareType;

@protocol RecipeShareViewControllerDelegate <NSObject>

- (void)recipeShareViewControllerCloseRequested;
- (UIImage *)recipeShareViewControllerImageRequested;

@end

@interface RecipeShareViewController : UIViewController

- (id)initWithRecipe:(CKRecipe *)recipe delegate:(id<RecipeShareViewControllerDelegate>)delegate;

@end
