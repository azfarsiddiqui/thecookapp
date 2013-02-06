//
//  EditableIngredientTableViewCell.m
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "EditableIngredientTableViewCell.h"

@interface EditableIngredientTableViewCell()
@property(nonatomic,strong) UITextField *measurementTextField;
@property(nonatomic,strong) UITextField *descriptionTextField;
@end
@implementation EditableIngredientTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self config];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithText:(NSString*)text forRowAtIndexPath:(NSIndexPath *)indexPath
{
   [self setAsHighlighted:(indexPath.row == 0) ];
}

-(void)config
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.descriptionTextField.text = nil;
    self.measurementTextField.text = nil;
    [self setAsHighlighted:NO];
}

#pragma mark - Private Methods
-(void)setAsHighlighted:(BOOL)higlighted {

    UIColor *backColor = higlighted ? [UIColor redColor] : [UIColor lightGrayColor];
    self.contentView.backgroundColor = backColor;
    self.textLabel.backgroundColor = backColor;
}
@end
