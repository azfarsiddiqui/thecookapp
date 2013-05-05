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
@end

#define kCategoryCellInsets UIEdgeInsetsMake(0.0f,0.0f,5.0f,0.0f)

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
    [super setSelected:selected animated:animated];
    self.textLabel.textColor = selected ? [UIColor whiteColor]: [UIColor blackColor];
    self.textLabel.backgroundColor = selected ? [Theme categoryListSelectedColor] : [UIColor whiteColor];
}

-(void)configureCellWithCategory:(CKCategory *)category
{
    //categoryName
    self.textLabel.text = [category.name uppercaseString];
}

#pragma mark - Private Methods
-(void)config
{
    UIView *selectedView = [[UIView alloc] initWithFrame:self.bounds];
    selectedView.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = selectedView;
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
    float widthAvailable = self.contentView.frame.size.width - kCategoryCellInsets.left - kCategoryCellInsets.right;
    self.textLabel.frame = CGRectMake(kCategoryCellInsets.left,
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
    self.backgroundColor = [UIColor clearColor];
}

@end
