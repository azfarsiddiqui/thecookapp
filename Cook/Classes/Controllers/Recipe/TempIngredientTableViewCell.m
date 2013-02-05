//
//  TempIngredientTableViewCell.m
//  Cook
//
//  Created by Jonny Sagorin on 10/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "TempIngredientTableViewCell.h"
#import "Theme.h"

NSString *const kIngredientTableViewCellReuseIdentifier = @"name";

@interface TempIngredientTableViewCell()
@property(nonatomic,strong) UITextField *ingredientsTextField;
@end
@implementation TempIngredientTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self) {
        [self config];
    }
    return self;
}

-(void)setIngredient:(Ingredient*)ingredient forRow:(NSInteger)row
{
    self.ingredientIndex = row;
    self.ingredientsTextField.text = [NSString stringWithFormat:@"%@ %i",ingredient.name, row];
}

#pragma mark - Private Methods
-(void)config
{
    self.ingredientsTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 160.0f, 21.0f)];
    self.ingredientsTextField.backgroundColor = [UIColor whiteColor];
    self.ingredientsTextField.font = [Theme defaultLabelFont];
    self.ingredientsTextField.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.ingredientsTextField];
}

-(void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.ingredientsTextField.delegate = delegate;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.ingredientsTextField.text = nil;
    self.ingredientsTextField.delegate = nil;
}
@end
