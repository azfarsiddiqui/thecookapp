//
//  RecipeImageView.h
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIEditableView.h"
#import "CKRecipe.h"
@interface RecipeImageView : UIEditableView
@property (nonatomic,strong) UIViewController *parentViewController;
-(void)setRecipe:(CKRecipe *)recipe;
@end
