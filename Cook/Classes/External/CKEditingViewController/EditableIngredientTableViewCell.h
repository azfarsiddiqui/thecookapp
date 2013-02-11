//
//  EditableIngredientTableViewCell.h
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol IngredientEditTableViewCellDelegate
-(void)didUpdateIngredientAtTouch:(UITouch*)touch withMeasurement:(NSString*)measurementString description:(NSString*)ingredientDescription;
@end

@interface EditableIngredientTableViewCell : UITableViewCell
-(void)configureCellWithText:(NSString*)text forRowAtIndexPath:(NSIndexPath *)indexPath editDelegate:(id<IngredientEditTableViewCellDelegate>)editDelegate;

@end
