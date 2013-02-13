//
//  EditableIngredientTableViewCell.h
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EditableIngredientTableViewCellDelegate
-(void)didUpdateIngredientAtRowIndex:(NSNumber*)rowIndex withMeasurement:(NSString*)measurementString description:(NSString*)ingredientDescription;
-(void)didSelectTextFieldForEditing:(UITextField*)textField isMeasurementField:(BOOL)isMeasurementField;
-(NSInteger)characterLimitForCurrentEditableTextField;
-(UITextField*) currentEditableTextField;
-(void) updateCharacterLimit:(NSInteger)textFieldLength;
@end

@interface EditableIngredientTableViewCell : UITableViewCell
-(void)configureCellWithText:(NSString*)text forRowAtIndex:(NSNumber *)rowIndex editDelegate:(id<EditableIngredientTableViewCellDelegate>)editDelegate;
-(void)requestMeasurementTextFieldEdit;
@end
