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
@property (nonatomic,assign,readonly) BOOL imageEdited;
@property (nonatomic,strong) UIImage *recipeImage;
-(void)setRecipe:(CKRecipe *)recipe;
-(CGPoint)scrollViewContentOffset;
@end
