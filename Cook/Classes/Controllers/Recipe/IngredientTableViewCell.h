//
//  IngredientTableViewCell.h
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"

extern NSString *const kIngredientTableViewCellReuseIdentifier;
@interface IngredientTableViewCell : UITableViewCell
@property(nonatomic,assign) NSInteger ingredientIndex;
@property(nonatomic,assign) id<UITextFieldDelegate> delegate;

-(void)setIngredient:(Ingredient*)ingredient forRow:(NSInteger)row;
@end
