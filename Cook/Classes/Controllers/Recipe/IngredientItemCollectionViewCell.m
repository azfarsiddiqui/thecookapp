//
//  IngredientItemCollectionViewCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientItemCollectionViewCell.h"
#import "CKEditingViewHelper.h"
#import "Theme.h"
#import "Ingredient.h"
#import "IngredientEditKeyboardAccessoryView.h"
#import "NSString+Utilities.h"
#import "ViewHelper.h"

@interface IngredientItemCollectionViewCell () <UITextFieldDelegate, IngredientEditKeyboardAccessoryViewDelegate>

@property (nonatomic, strong) Ingredient *ingredient;
@property (nonatomic, strong) UITextField *unitTextField;
@property (nonatomic, strong) UITextField *ingredientTextField;
@property (nonatomic, strong) IngredientEditKeyboardAccessoryView *ingredientEditKeyboardAccessoryView;

@end

@implementation IngredientItemCollectionViewCell

#define kDefaultFont            [UIFont systemFontOfSize:40]
#define kUnitWidth              160.0
#define kFieldDividerGap        20.0
#define kMaxLengthMeasurement   10
#define kMaxLengthDescription   30

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGFloat singleLineHeight = [CKEditingViewHelper singleLineHeightForFont:kDefaultFont size:self.contentView.bounds.size];
        UIEdgeInsets itemInsets = UIEdgeInsetsMake(floorf((self.contentView.bounds.size.height - singleLineHeight) / 2.0), 20.0, 0.0, 20.0);
        
        // Vertical divider.
        UIView *verticalDividerView = [[UIView alloc] initWithFrame:CGRectMake(itemInsets.left + kUnitWidth + kFieldDividerGap,
                                                                               self.boxImageView.bounds.origin.y + 1.0,
                                                                               1.0,
                                                                               self.boxImageView.bounds.size.height - 2.0)];
        verticalDividerView.backgroundColor = [Theme dividerRuleColour];
        [self.boxImageView addSubview:verticalDividerView];
        
        // Unit field.
        UITextField *unitTextField = [[UITextField alloc] initWithFrame:CGRectMake(itemInsets.left,
                                                                                   itemInsets.top,
                                                                                   kUnitWidth,
                                                                                   singleLineHeight)];
        unitTextField.backgroundColor = [UIColor clearColor];
        unitTextField.textAlignment = NSTextAlignmentCenter;
        unitTextField.delegate = self;
        unitTextField.font = kDefaultFont;
        unitTextField.textColor = [UIColor blackColor];
        unitTextField.keyboardType = UIKeyboardTypeNumberPad;
        unitTextField.returnKeyType = UIReturnKeyNext;
        unitTextField.userInteractionEnabled = NO;
        unitTextField.inputAccessoryView = self.ingredientEditKeyboardAccessoryView;
        [self.contentView addSubview:unitTextField];
        self.unitTextField = unitTextField;
        
        // Unit field.
        UITextField *ingredientTextField = [[UITextField alloc] initWithFrame:CGRectMake(verticalDividerView.frame.origin.x + kFieldDividerGap,
                                                                                         itemInsets.top,
                                                                                         self.contentView.bounds.size.width - verticalDividerView.frame.origin.x - kFieldDividerGap - itemInsets.right,
                                                                                         singleLineHeight)];
        ingredientTextField.backgroundColor = [UIColor clearColor];
        ingredientTextField.textAlignment = NSTextAlignmentLeft;
        ingredientTextField.delegate = self;
        ingredientTextField.font = kDefaultFont;
        ingredientTextField.textColor = [UIColor blackColor];
        ingredientTextField.returnKeyType = UIReturnKeyDone;
        ingredientTextField.userInteractionEnabled = NO;
        [self.contentView addSubview:ingredientTextField];
        self.ingredientTextField = ingredientTextField;
    }
    return self;
}

- (void)focusForEditing:(BOOL)focus {
    if (focus) {
        [self focusUnitField];
    } else {
        [self unfocusFields];
    }
}

- (void)configureValue:(id)value {
    
    // Default implementation to set up.
    [super configureValue:value];
    
    // Keep a reference of the ingredient.
    self.ingredient = (Ingredient *)value;
    self.unitTextField.text = [self.ingredient.measurement CK_truncatedStringToLength:kMaxLengthMeasurement];
    self.ingredientTextField.text = [self.ingredient.name CK_truncatedStringToLength:kMaxLengthDescription];
}

- (void)setPlaceholder:(BOOL)placeholder {
    [super setPlaceholder:placeholder];
    self.unitTextField.text = nil;
    self.ingredientTextField.text = nil;
}

- (id)currentValue {
    return [Ingredient ingredientwithName:[self.ingredientTextField.text CK_whitespaceTrimmed]
                              measurement:[self.unitTextField.text CK_whitespaceTrimmed]];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return [self.delegate processedValueForCell:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.unitTextField) {
        
        [self focusIngredientField];
        
    } else if (textField == self.ingredientTextField) {
        
        [self.delegate returnRequestedForCell:self];
        
    }
    return shouldReturn;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark - IngredientEditKeyboardAccessoryViewDelegate methods

- (void)didEnterMeasurementShortCut:(NSString*)name isAmount:(BOOL)isAmount {
    NSLog(@"didEnterMeasurementShortCut [%@] isAmount [%@]", name, [NSString CK_stringForBoolean:isAmount]);
    
    NSString *newValue = [NSString stringWithFormat:@"%@ %@",self.unitTextField.text, [name lowercaseString]];
    if (newValue.length < kMaxLengthMeasurement) {
        self.unitTextField.text = newValue;
    }
    
    // If this was not the amount field, then jump to the ingredient field.
    if (!isAmount) {
        [self focusIngredientField];
    }
    
}

#pragma mark - Properties

- (UIView *)ingredientEditKeyboardAccessoryView {
    if (!_ingredientEditKeyboardAccessoryView) {
        _ingredientEditKeyboardAccessoryView = [[IngredientEditKeyboardAccessoryView alloc] initWithDelegate:self];
    }
    return _ingredientEditKeyboardAccessoryView;
}

#pragma mark - Private methods

- (void)focusUnitField {
    self.unitTextField.userInteractionEnabled = YES;
    self.ingredientTextField.userInteractionEnabled = NO;
    [self.unitTextField becomeFirstResponder];
}

- (void)focusIngredientField {
    self.unitTextField.userInteractionEnabled = NO;
    self.ingredientTextField.userInteractionEnabled = YES;
    [ViewHelper setCaretOnFrontForInput:self.ingredientTextField];
    [self.ingredientTextField becomeFirstResponder];
}

- (void)unfocusFields {
    [self.unitTextField resignFirstResponder];
    [self.ingredientTextField resignFirstResponder];
    self.unitTextField.userInteractionEnabled = NO;
    self.ingredientTextField.userInteractionEnabled = NO;
}

@end
