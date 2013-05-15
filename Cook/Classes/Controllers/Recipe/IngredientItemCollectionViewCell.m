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

@interface IngredientItemCollectionViewCell () <UITextFieldDelegate, IngredientEditKeyboardAccessoryViewDelegate>

@property (nonatomic, strong) Ingredient *ingredient;
@property (nonatomic, strong) UITextField *unitTextField;
@property (nonatomic, strong) UITextField *ingredientTextField;
@property (nonatomic, strong) IngredientEditKeyboardAccessoryView *ingredientEditKeyboardAccessoryView;

@end

@implementation IngredientItemCollectionViewCell

#define kDefaultFont        [UIFont systemFontOfSize:50]
#define kUnitWidth          160.0
#define kFieldDividerGap    20.0

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
        unitTextField.textAlignment = NSTextAlignmentLeft;
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
        ingredientTextField.returnKeyType = UIReturnKeyNext;
        ingredientTextField.userInteractionEnabled = NO;
        [self.contentView addSubview:ingredientTextField];
        self.ingredientTextField = ingredientTextField;
    }
    return self;
}

- (void)focusForEditing:(BOOL)focus {
    if (focus) {
        self.unitTextField.userInteractionEnabled = YES;
        [self.unitTextField becomeFirstResponder];
    } else {
        [self.unitTextField resignFirstResponder];
        [self.ingredientTextField resignFirstResponder];
        self.unitTextField.userInteractionEnabled = NO;
        self.ingredientTextField.userInteractionEnabled = NO;
    }
}

- (void)configureValue:(id)value {
    
    // Default implementation to set up.
    [super configureValue:value];
    
    // Keep a reference of the ingredient.
    self.ingredient = (Ingredient *)value;
    self.unitTextField.text = self.ingredient.measurement;
    self.ingredientTextField.text = self.ingredient.name;
}

- (id)currentValue {
    return self.ingredient;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    if (textField == self.unitTextField) {
        
        self.ingredientTextField.userInteractionEnabled = YES;
        [self.ingredientTextField becomeFirstResponder];
        
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
}

#pragma mark - Properties

- (UIView *)ingredientEditKeyboardAccessoryView {
    if (!_ingredientEditKeyboardAccessoryView) {
        _ingredientEditKeyboardAccessoryView = [[IngredientEditKeyboardAccessoryView alloc] initWithDelegate:self];
    }
    return _ingredientEditKeyboardAccessoryView;
}

#pragma mark - Private methods



@end
