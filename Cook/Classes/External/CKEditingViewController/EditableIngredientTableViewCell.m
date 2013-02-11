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
@property(nonatomic,strong) UIButton *doneButton;
@property(nonatomic,assign) NSInteger descriptionCharacterLimit;
@property(nonatomic,assign) NSInteger measurementCharacterLimit;
@property(nonatomic,assign) id<IngredientEditTableViewCellDelegate> ingredientEditTableViewCellDelegate;
@end
@implementation EditableIngredientTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.descriptionCharacterLimit = 30;
        self.measurementCharacterLimit = 10;
        [self config];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithText:(NSString*)text forRowAtIndexPath:(NSIndexPath *)indexPath editDelegate:(id<IngredientEditTableViewCellDelegate>)ingredientEditTableViewCellDelegate
{
    self.measurementTextField.text = [NSString stringWithFormat:@"300 ml"];
    self.descriptionTextField.text = text;
    self.ingredientEditTableViewCellDelegate = ingredientEditTableViewCellDelegate;
   [self setAsHighlighted:(indexPath.row == 0)];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.descriptionTextField.text = nil;
    self.measurementTextField.text = nil;
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
    
    self.doneButton.frame = CGRectMake(self.descriptionTextField.frame.origin.x + self.descriptionTextField.frame.size.width,
                                       self.descriptionTextField.frame.origin.y + floorf(0.5f*(self.descriptionTextField.frame.size.height) - floorf(0.5f*self.doneButton.frame.size.height)),
                                       self.doneButton.frame.size.width,
                                       self.doneButton.frame.size.height);

    
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self performSave];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL isBackspace = [newString length] < [textField.text length];

    NSInteger characterLimit = (textField == self.descriptionTextField) ? self.descriptionCharacterLimit : self.measurementCharacterLimit;
    if (textField == self.descriptionTextField) {
        if ([textField.text length] >= characterLimit && !isBackspace) {
            return NO;
        }
    }
    
    DLog(@"description: %i, value %@", textField == self.descriptionTextField, textField.text);
    
//    // Update character limit.
//    NSUInteger currentLimit = self.characterLimit - [newString length];
//    self.limitLabel.text = [NSString stringWithFormat:@"%d", currentLimit];
//    [self updateLimitLabel];
    
    // No save if no characters
    self.doneButton.enabled = [newString length] > 0;
    
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
    self.measurementTextField.delegate = self;
    [self.contentView addSubview:self.measurementTextField];
    
    self.backViewDescriptionView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.backViewDescriptionView];
    
    self.descriptionTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.descriptionTextField.delegate = self;
    
    [self.contentView addSubview:self.descriptionTextField];
    
    self.maskCellView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.maskCellView];
    
    [self addDoneButton];
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

- (void)performSave {
    
//    UITextField *textField = (UITextField *)self.targetEditingView;

//    [self.delegate editingView:self.sourceEditingView saveRequestedWithResult:textField.text];
//    [super performSave];
}

-(void)setAsHighlighted:(BOOL)highlighted {
    float maskAlpha = highlighted ? 0.0f : 0.7f;
    self.maskCellView.alpha = maskAlpha;
    self.doneButton.hidden = !highlighted;
}

-(void) addDoneButton
{
    self.doneButton = [ViewHelper buttonWithImage:[UIImage imageNamed:@"cook_customise_btns_done.png"]
                                           target:self selector:@selector(doneButtonTapped:withEvent:)];

    self.doneButton.hidden = YES;
    [self.contentView addSubview:self.doneButton];
    
}

-(void) doneButtonTapped:(UIButton*)button withEvent:(UIEvent*)event {
    UITouch *touch = [[event touchesForView:button] anyObject];
    DLog(@"Done button tapped");
    [self.ingredientEditTableViewCellDelegate didUpdateIngredientAtTouch:touch withMeasurement:self.measurementTextField.text description:self.descriptionTextField.text];
}

@end
