//
//  IngredientTableViewCell.m
//  Cook
//
//  Created by Jonny Sagorin on 2/6/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientTableViewCell.h"
#import "Theme.h"
#import "ViewHelper.h"

@interface IngredientTableViewCell()
@property(nonatomic,strong) UIView *backViewMeasurementView;
@property(nonatomic,strong) UIView *backViewDescriptionView;
@property(nonatomic,strong) UIButton *doneButton;
@end

#define kIngredientCellInsets UIEdgeInsetsMake(5.0f,10.0f,5.0f,10.0f)
#define kPaddingWidthBetweenFields 10.0f
#define kLabelMarginWidth 20.0f

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

-(void)configureCellWithText:(NSString *)text forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.detailTextLabel.text = text;
    self.textLabel.text = [NSString stringWithFormat:@"300 ml"];
}

#pragma mark - Private Methods
-(void)config
{
    self.backViewMeasurementView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.backViewMeasurementView];
    
    self.backViewDescriptionView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.backViewDescriptionView];
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
    
    float widthAvailable = self.contentView.frame.size.width - kPaddingWidthBetweenFields - kIngredientCellInsets.left - kIngredientCellInsets.right;
    float twentyPercent = floorf(0.2*widthAvailable);
    float eightyPercent = floorf(0.8*widthAvailable);
    

    self.backViewMeasurementView.frame = CGRectMake(kIngredientCellInsets.left,
                                                    kIngredientCellInsets.top,
                                                    twentyPercent,
                                                    self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);

    self.textLabel.frame = CGRectMake(kIngredientCellInsets.left + kLabelMarginWidth,
                                      kIngredientCellInsets.top,
                                      twentyPercent - 2*kLabelMarginWidth,
                                      self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);

    
    self.backViewDescriptionView.frame = CGRectMake(kIngredientCellInsets.left + twentyPercent + kPaddingWidthBetweenFields,
                                                    kIngredientCellInsets.top,
                                                    eightyPercent - kPaddingWidthBetweenFields,
                                                    self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);

    self.detailTextLabel.frame = CGRectMake(kIngredientCellInsets.left + twentyPercent + kPaddingWidthBetweenFields + kLabelMarginWidth,
                                            kIngredientCellInsets.top,
                                            eightyPercent - kPaddingWidthBetweenFields - 2*kLabelMarginWidth,
                                            self.contentView.frame.size.height - kIngredientCellInsets.top - kIngredientCellInsets.bottom);
    
    [self styleCell];
}

-(void)styleCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.textColor = [UIColor blackColor];
    self.textLabel.font = [Theme textEditableTextFont];
    self.detailTextLabel.font = [Theme textEditableTextFont];

    self.backViewMeasurementView.backgroundColor = [UIColor whiteColor];
    self.backViewDescriptionView.backgroundColor = [UIColor whiteColor];

}

@end
