//
//  IngredientEditorViewController.h
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//  View for editing ingredients
//

#import <UIKit/UIKit.h>

@protocol IngredientEditorDelegate
-(void)didUpdateIngredient:(NSString*)ingredientDescription atRowIndex:(NSInteger)rowIndex;
-(void)didRequestIngredientEditorViewDismissal;
@end

@interface IngredientEditorViewController : UIViewController
@property(nonatomic,assign) NSInteger selectedIndex;
@property(nonatomic,strong) NSArray *ingredientList;
@property(nonatomic,assign) id<IngredientEditorDelegate>ingredientEditorDelegate;
- (id)initWithFrame:(CGRect)frame withViewInsets:(UIEdgeInsets)viewInsets startingAtFrame:(CGRect)startingFrame;
- (void)updateFrameSize:(CGRect)frame forExpansion:(BOOL)expansion;
@end
