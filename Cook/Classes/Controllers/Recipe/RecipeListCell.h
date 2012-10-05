//
//  RecipeListCell.h
//  recipe
//
//  Created by Jonny Sagorin on 9/27/12.
//  Copyright (c) 2012 Cook Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKRecipe.h"

@interface RecipeListCell : UICollectionViewCell
-(void)configure:(CKRecipe*)recipe;
@end
