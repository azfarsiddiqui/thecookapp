//
//  IngredientTableViewCell.m
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientTableViewCell.h"

@interface IngredientTableViewCell()
@end

#define kIngredientCellInsets UIEdgeInsetsMake(10.0f,30.0f,10.0f,10.0f)
#define kPaddingBetweenFields 10.0f

@implementation IngredientTableViewCell

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
}

-(void)configureCellWithText:(NSString *)text
{
    self.textLabel.text = text;
    self.detailTextLabel.text = [NSString stringWithFormat:@"300 ml"];
}
#pragma mark - Private Methods

-(void)config
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.textLabel.text = nil;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //reposition textlabel,detailtextlabel 924,89
    
    float widthAvailable = self.contentView.frame.size.width - kPaddingBetweenFields - kIngredientCellInsets.left - kIngredientCellInsets.right;
    float twentyPercent = floorf(0.2*widthAvailable);
    float eightyPercent = floorf(0.8*widthAvailable);
    
    self.textLabel.frame = CGRectMake(kIngredientCellInsets.left, kIngredientCellInsets.top, twentyPercent,
                                      self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);
    self.detailTextLabel.frame = CGRectMake(kIngredientCellInsets.left + twentyPercent + kPaddingBetweenFields,
                                            kIngredientCellInsets.top, eightyPercent,
                                            self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);
    [self styleCell];
}

-(void)styleCell
{
    self.textLabel.backgroundColor = [UIColor whiteColor];
    self.textLabel.font =[UIFont systemFontOfSize:16.0f];
    self.detailTextLabel.backgroundColor = [UIColor whiteColor];
    self.detailTextLabel.font =[UIFont systemFontOfSize:16.0f];


}
@end
