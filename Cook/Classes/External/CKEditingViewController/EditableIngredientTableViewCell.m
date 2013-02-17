//
//  EditableIngredientTableViewCell.m
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "EditableIngredientTableViewCell.h"
#import "Theme.h"
#import "ViewHelper.h"

#define kIngredientCellInsets UIEdgeInsetsMake(5.0f,10.0f,5.0f,10.0f)
#define kPaddingWidthBetweenFields 10.0f
#define kLabelMarginWidth 20.0f

@interface EditableIngredientTableViewCell()<UITextFieldDelegate>
@property(nonatomic,strong) UIView *maskCellView;
@property(nonatomic,strong) UITextField *measurementTextField;
@property(nonatomic,strong) UITextField *descriptionTextField;
@property(nonatomic,strong) UIView *backViewMeasurementView;
@property(nonatomic,strong) UIView *backViewDescriptionView;
@property(nonatomic,assign) NSNumber *rowIndex;
@property(nonatomic,assign) id<EditableIngredientTableViewCellDelegate> ingredientEditTableViewCellDelegate;
@end
@implementation EditableIngredientTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self config];
    }
    return self;
}

-(void)configureCellWithText:(NSString *)text forRowAtIndex:(NSNumber *)rowIndex editDelegate:(id<EditableIngredientTableViewCellDelegate>)editDelegate
{
    NSArray *textComponents = [text componentsSeparatedByString:@":"];
    self.measurementTextField.text = [textComponents objectAtIndex:0];
    self.descriptionTextField.text = [textComponents objectAtIndex:1];
    self.ingredientEditTableViewCellDelegate = editDelegate;
    self.rowIndex = rowIndex;
   [self setAsHighlighted:([rowIndex intValue] == 0)];
}

-(void)requestMeasurementTextFieldEdit
{
    [self.measurementTextField becomeFirstResponder];
}

#pragma mark -overridden
-(void)prepareForReuse
{
    [super prepareForReuse];
    self.descriptionTextField.text = nil;
    self.measurementTextField.text = nil;
    self.rowIndex = nil;
    [self setAsHighlighted:NO];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.maskCellView.frame = self.contentView.frame;
    
    float widthAvailable = self.contentView.frame.size.width - kPaddingWidthBetweenFields - kIngredientCellInsets.left - kIngredientCellInsets.right;
    float twentyPercent = floorf(0.2*widthAvailable);
    float eightyPercent = floorf(0.8*widthAvailable);
    
    
    self.backViewMeasurementView.frame = CGRectMake(kIngredientCellInsets.left,
                                                    kIngredientCellInsets.top,
                                                    twentyPercent,
                                                    self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);
    
    self.measurementTextField.frame = CGRectMake(kIngredientCellInsets.left + kLabelMarginWidth,
                                      kIngredientCellInsets.top,
                                      twentyPercent - 2*kLabelMarginWidth,
                                      self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);
    
    self.backViewDescriptionView.frame = CGRectMake(kIngredientCellInsets.left + twentyPercent + kPaddingWidthBetweenFields,
                                                    kIngredientCellInsets.top,
                                                    eightyPercent - kPaddingWidthBetweenFields,
                                                    self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);
    
    self.descriptionTextField.frame = CGRectMake(kIngredientCellInsets.left + twentyPercent + kPaddingWidthBetweenFields + kLabelMarginWidth,
                                            kIngredientCellInsets.top,
                                            eightyPercent - kPaddingWidthBetweenFields - 2*kLabelMarginWidth,
                                            self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected && ![self isFirstRow]) {
    }
}

#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [self isFirstRow];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.ingredientEditTableViewCellDelegate didSelectTextFieldForEditing:textField isMeasurementField:textField == self.measurementTextField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.measurementTextField) {
        [self.descriptionTextField becomeFirstResponder];
        return NO;
    } else {
        [textField resignFirstResponder];
        return YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)appendedString {

    NSString *newTextFieldValue = [textField.text stringByReplacingCharactersInRange:range withString:appendedString];
    BOOL isBackspace = [newTextFieldValue length] < [textField.text length];

    if (isBackspace) {
        [self.ingredientEditTableViewCellDelegate updateCharacterLimit:[newTextFieldValue length]];
        return YES;
    }
    
    return [self.ingredientEditTableViewCellDelegate requestedUpdateForCurrentEditableTextField:newTextFieldValue];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.ingredientEditTableViewCellDelegate didUpdateIngredientAtRowIndex:self.rowIndex withMeasurement:self.measurementTextField.text description:self.descriptionTextField.text];
    return YES;
}
#pragma mark - Private Methods

-(void)config
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.backViewMeasurementView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.backViewMeasurementView];
    
    self.measurementTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.measurementTextField setReturnKeyType:UIReturnKeyNext];
    self.measurementTextField.delegate = self;
    [self.contentView addSubview:self.measurementTextField];
    
    self.backViewDescriptionView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.backViewDescriptionView];
    
    self.descriptionTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.descriptionTextField.delegate = self;
    
    [self.contentView addSubview:self.descriptionTextField];
    
    self.maskCellView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.maskCellView];
    
    [self style];
    
}

-(void) style
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.descriptionTextField.backgroundColor = [UIColor clearColor];
    self.descriptionTextField.textColor = [UIColor blackColor];
    self.descriptionTextField.font = [Theme textEditableTextFont];
    
    self.measurementTextField.backgroundColor = [UIColor clearColor];
    self.measurementTextField.textColor = [UIColor blackColor];
    self.measurementTextField.font = [Theme textEditableTextFont];
    
    self.backViewMeasurementView.backgroundColor = [UIColor whiteColor];
    self.backViewDescriptionView.backgroundColor = [UIColor whiteColor];
    self.maskCellView.backgroundColor = [UIColor blackColor];
    
}

-(void)setAsHighlighted:(BOOL)highlighted {
    float maskAlpha = highlighted ? 0.0f : 0.7f;
    self.maskCellView.alpha = maskAlpha;
}

-(BOOL)isFirstRow
{
    return [self.rowIndex isEqualToNumber:[NSNumber numberWithInt:0]];
}

@end
