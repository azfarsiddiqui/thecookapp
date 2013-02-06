//
//  EditableIngredientTableViewCell.m
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "EditableIngredientTableViewCell.h"

@interface EditableIngredientTableViewCell()
@property(nonatomic,strong) UIView *maskCellView;
@property(nonatomic,strong) UITextField *measurementTextField;
@property(nonatomic,strong) UITextField *descriptionTextField;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithText:(NSString*)text forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.textLabel.text = text;
    self.detailTextLabel.text = @"300 ml";
   [self setAsHighlighted:(indexPath.row == 0)];
}

-(void)config
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.textLabel.backgroundColor = [UIColor whiteColor];
    self.detailTextLabel.backgroundColor = [UIColor whiteColor];

    self.maskCellView = [[UIView alloc] initWithFrame:CGRectZero];
    self.maskCellView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.maskCellView];
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
}

#pragma mark - Private Methods
-(void)setAsHighlighted:(BOOL)highlighted {

    float maskAlpha = highlighted ? 0.0f : 0.7f;
    self.maskCellView.alpha = maskAlpha;
}
@end
