//
//  CategoryListCell.m
//  Cook
//
//  Created by Jonny Sagorin on 10/8/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CategoryListCell.h"


@interface CategoryListCell ()
@property (strong, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (nonatomic,strong) UIImageView *selectedImageView;
@end

@implementation CategoryListCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    UIImage *selectedImageName = [UIImage imageNamed:@"cook_editrecipe_categoryselected"];
    self.selectedImageView = [[UIImageView alloc]initWithImage:[selectedImageName resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 14.0f, 0.0f, 14.0f)]];
    [self.contentView insertSubview:self.selectedImageView belowSubview:self.categoryNameLabel];
    
    self.selectedImageView.hidden = YES;
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
    }
    return self;
}

-(void)configure:(Category*)category;
{
    self.categoryNameLabel.text = [category.name uppercaseString];
    self.selectedImageView.frame = CGRectMake(0.0f, 0.0f, self.contentView.frame.size.width, 28.0f);

}

-(void)selectCell:(BOOL)selected;
{
    self.categoryNameLabel.textColor = selected? [UIColor whiteColor] : [UIColor blackColor];
    self.selectedImageView.hidden = !selected;
    

}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.categoryNameLabel.text = nil;
}

@end
