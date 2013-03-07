//
//  CategoryTableViewCell.m
//  Cook
//
//  Created by Jonny Sagorin on 3/7/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryTableViewCell.h"
#import "Theme.h"

@interface CategoryTableViewCell()
@property(nonatomic,strong) UIView *backView;
@end

#define kCategoryCellInsets UIEdgeInsetsMake(5.0f,10.0f,5.0f,10.0f)
#define kLabelMarginWidth 20.0f

@implementation CategoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self config];
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    DLog();
    [super setSelected:selected animated:animated];
    self.textLabel.textColor = selected ? [UIColor whiteColor]: [UIColor blackColor];
    self.backView.backgroundColor = selected ? [Theme categoryListSelectedColor] : [UIColor whiteColor];
}

-(void)setSelectedBackgroundView:(UIView *)selectedBackgroundView
{
    
}
-(void)configureCellWithCategory:(Category *)category forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //categoryName
    self.textLabel.text = [category.name uppercaseString];
}

#pragma mark - Private Methods
-(void)config
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundView = nil;
    [self.contentView addSubview:self.backView];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.textLabel.text = nil;
    [self setSelected:NO];
}

-(UIView *)backView
{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _backView;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    //reposition textlabel,detailtextlabel 924,89
    
    float widthAvailable = self.contentView.frame.size.width -  kCategoryCellInsets.left - kCategoryCellInsets.right;
    
    
    self.backView.frame = CGRectMake(kCategoryCellInsets.left,
                                                    kCategoryCellInsets.top,
                                                    widthAvailable,
                                                    self.contentView.frame.size.height - kCategoryCellInsets.top - kCategoryCellInsets.bottom);
    
    self.textLabel.frame = CGRectMake(kCategoryCellInsets.left + kLabelMarginWidth,
                                      kCategoryCellInsets.top,
                                      widthAvailable,
                                      self.contentView.frame.size.height - kCategoryCellInsets.top - kCategoryCellInsets.bottom);
    
    [self styleCell];
}

-(void)styleCell
{
    self.contentView.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [Theme categoryListFont];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.backView.backgroundColor = [UIColor whiteColor];
}

@end
