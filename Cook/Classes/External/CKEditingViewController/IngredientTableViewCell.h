//
//  IngredientTableViewCell.h
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"
@interface IngredientTableViewCell : UITableViewCell
//text is measurument:ingredient
-(void)configureCellWithIngredient:(Ingredient*)ingredient forRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)styleCell;
@end
