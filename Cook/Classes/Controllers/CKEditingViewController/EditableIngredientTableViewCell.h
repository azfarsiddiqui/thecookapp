//
//  EditableIngredientTableViewCell.h
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"


@protocol EditableIngredientTableViewCellDelegate
-(void)didUpdateIngredientAtRowIndex:(NSNumber*)rowIndex withMeasurement:(NSString*)measurementString description:(NSString*)ingredientDescription;
-(void)didSelectTextFieldForEditing:(UITextField*)textField isMeasurementField:(BOOL)isMeasurementField;
-(NSInteger)characterLimitForCurrentEditableTextField;
-(UITextField*) currentEditableTextField;
-(void) updateCharacterLimit:(NSInteger)textFieldLength;
-(BOOL) requestedUpdateForCurrentEditableTextField:(NSString*)newTextFieldValue;
@end

@interface EditableIngredientTableViewCell : UITableViewCell
-(void)configureCellWithIngredient:(Ingredient*)ingredient forRowAtIndex:(NSNumber *)rowIndex editDelegate:(id<EditableIngredientTableViewCellDelegate>)editDelegate;
-(void)requestMeasurementTextFieldEdit;
-(void)requestDescriptionTextFieldEdit;
@end
