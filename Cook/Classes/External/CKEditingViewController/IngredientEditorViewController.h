//
//  IngredientEditorViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//  View for editing ingredients
//

#import <UIKit/UIKit.h>

@interface IngredientEditorViewController : UIViewController
@property(nonatomic,assign) NSInteger selectedIndex;
@property(nonatomic,strong) NSArray *ingredientList;
- (id)initWithFrame:(CGRect)frame;
- (void)updateFrameSize:(CGRect)frame;
@end
