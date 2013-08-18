//
//  IngredientListCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 1/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientListCell.h"
#import "Ingredient.h"
#import "NSString+Utilities.h"
#import "CKEditingViewHelper.h"
#import "Theme.h"
#import "ViewHelper.h"
#import "MRCEnumerable.h"

@interface IngredientListCell () <UITextFieldDelegate, IngredientsKeyboardAccessoryViewControllerDelegate>

@property (nonatomic, strong) Ingredient *ingredient;
@property (nonatomic, strong) UITextField *unitTextField;
@property (nonatomic, assign) BOOL focusName;

@end

@implementation IngredientListCell

#define kFieldDividerGap        10.0
#define kUnitWidth              160.0
#define kDividerInsets          (UIEdgeInsets){ 16.0, 0.0, 11.0, 0.0 }
#define kMaxLengthMeasurement   10

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIEdgeInsets insets = [CKListCell listItemInsets];
        
        // Default font.
        self.font = [UIFont fontWithName:@"AvenirNext-Regular" size:36.0f];
        
        // Unit field.
        UITextField *unitTextField = [[UITextField alloc] initWithFrame:(CGRect){
            insets.left,
            insets.top,
            kUnitWidth,
            self.textField.frame.size.height
        }];
        unitTextField.backgroundColor = [UIColor clearColor];
        unitTextField.textAlignment = NSTextAlignmentCenter;
        unitTextField.delegate = self;
        unitTextField.font = self.textField.font;
        unitTextField.textColor = self.textField.textColor;
        unitTextField.keyboardType = UIKeyboardTypeNumberPad;
        unitTextField.returnKeyType = UIReturnKeyNext;
        [self.contentView addSubview:unitTextField];
        self.unitTextField = unitTextField;
        
        // Vertical divider.
        UIView *verticalDividerView = [[UIView alloc] initWithFrame:(CGRect){
            unitTextField.frame.origin.x + unitTextField.frame.size.width + kFieldDividerGap,
            kDividerInsets.top,
            1.0,
            self.contentView.bounds.size.height - kDividerInsets.top - kDividerInsets.bottom
        }];
        verticalDividerView.backgroundColor = [Theme dividerRuleColour];
        [self.contentView addSubview:verticalDividerView];
        
        // Move the main textfield across to make way for the unit text field.
        self.textField.textAlignment = NSTextAlignmentLeft;
        self.textField.frame = (CGRect){
            verticalDividerView.frame.origin.x + kFieldDividerGap,
            self.textField.frame.origin.y,
            self.contentView.bounds.size.width - verticalDividerView.frame.origin.x - kFieldDividerGap - insets.right,
            self.textField.frame.size.height
        };
    }
    return self;
}

- (void)configureMeasure:(NSString *)measure {
    NSMutableString *currentMeasureValue = [NSMutableString stringWithString:[self.unitTextField.text CK_whitespaceAndNewLinesTrimmed]];
    NSString *detectedMeasureValue = nil;
   
    // Loop and detect any entered uoms, and replace it if necessary.
    for (NSString *currentMeasure in [self.ingredientsAccessoryViewController allUnitOfMeasureOptions]) {
        
        NSString *searchString = [NSString stringWithFormat:@" %@", currentMeasure];
        if ([currentMeasureValue hasSuffix:searchString]) {
            detectedMeasureValue = searchString;
            break;
        }
        
    }
    
    // Do we have a detected value, if so remove it so that we can replace with the new value.
    if ([detectedMeasureValue length] > 0) {
        [currentMeasureValue deleteCharactersInRange:(NSRange){
            [currentMeasureValue length] - [detectedMeasureValue length],
            [detectedMeasureValue length]
        }];
    }
    [currentMeasureValue appendFormat:@" %@", measure];
    
    self.unitTextField.text = currentMeasureValue;
    
    [self focusNameField];
}

#pragma mark - CKListCell methods

- (void)configureValue:(id)value selected:(BOOL)selected {
    
    self.ingredient = (Ingredient *)value;
    [super configureValue:value selected:selected];
    
    NSString *unit = [self.ingredient.measurement CK_whitespaceTrimmed];
    self.unitTextField.text = unit;
}

- (NSString *)textValueForValue:(id)value {
    NSString *textValue = nil;
    if ([value isKindOfClass:[Ingredient class]]) {
        textValue = [((Ingredient *)value).name CK_whitespaceAndNewLinesTrimmed];
    } else {
        [super textValueForValue:value];
    }
    return textValue;
}

- (id)currentValue {
    NSString *unit = [self.unitTextField.text CK_whitespaceAndNewLinesTrimmed];
    NSString *name = [self.textField.text CK_whitespaceAndNewLinesTrimmed];
    self.ingredient = [Ingredient ingredientwithName:name measurement:unit];
    return self.ingredient;
}

- (void)setEditing:(BOOL)editMode {
    self.editMode = editMode;
    
    if (editMode) {
        [self.unitTextField becomeFirstResponder];
    } else {
        if ([self.unitTextField isFirstResponder]) {
            [self.unitTextField resignFirstResponder];
        } else {
            [self.textField resignFirstResponder];
        }
    }
}

#pragma mark - IngredientsKeyboardAccessoryViewControllerDelegate methods

- (void)ingredientsKeyboardAccessorySelectedValue:(NSString *)value {
    [self configureMeasure:value];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.unitTextField) {
        self.ingredientsAccessoryViewController.delegate = self;
    }
    return [super textFieldShouldBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (self.focusName) {
        
        // Not dismissed from UoM field, hence do the normal empty cells processing.
        return [super textFieldShouldEndEditing:textField];
        
    } else {
        
        // This was keyboard dismissal from UoM field.
        self.focusName = NO;
        return YES;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.unitTextField) {
        [self focusNameField];
        
        // Set a flag to indicate focussing onto next field, so we don't process empty cells in shouldEndEditing.
        self.focusName = YES;
        
    } else {
        [super textFieldShouldReturn:textField];
    }
    return shouldReturn;
}

#pragma mark - Properties

- (void)setIngredientsAccessoryViewController:(IngredientsKeyboardAccessoryViewController *)ingredientsAccessoryViewController {
    _ingredientsAccessoryViewController = ingredientsAccessoryViewController;
    self.unitTextField.inputAccessoryView = ingredientsAccessoryViewController.view;
}

#pragma mark - Private methods

- (void)focusNameField {
    [ViewHelper setCaretOnFrontForInput:self.textField];
    [self.textField becomeFirstResponder];
}

@end
