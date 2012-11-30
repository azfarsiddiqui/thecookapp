//
//  IngredientsView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsView.h"
#import "Theme.h"
#import "ViewHelper.h"

@interface IngredientsView()
@property(nonatomic,strong) UILabel *ingredientsLabel;
@property(nonatomic,strong) UIScrollView *ingredientsScrollView;
@end

@implementation IngredientsView

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
}

#pragma mark - Private methods
//overridden
-(void)configViews
{
    self.ingredientsScrollView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);

    CGSize maxSize = CGSizeMake(190.0f, CGFLOAT_MAX);
    self.ingredientsLabel.text = self.ingredients;
    CGSize requiredSize = [self.ingredients sizeWithFont:self.ingredientsLabel.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    self.ingredientsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
    [ViewHelper adjustScrollContentSize:self.ingredientsScrollView forHeight:requiredSize.height];
}

//overridden
-(void) styleViews
{
    self.ingredientsLabel.font = [Theme defaultLabelFont];
    self.ingredientsLabel.backgroundColor = [UIColor clearColor];
    self.ingredientsLabel.textColor = [Theme ingredientsLabelColor];
}

-(UILabel *)ingredientsLabel
{
    if (!_ingredientsLabel) {
        _ingredientsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _ingredientsLabel.numberOfLines = 0;
        [self.ingredientsScrollView addSubview:_ingredientsLabel];
    }
    
    return _ingredientsLabel;
}

-(UIScrollView *)ingredientsScrollView
{
    if (!_ingredientsScrollView) {
        _ingredientsScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _ingredientsScrollView.scrollEnabled = YES;
        [self addSubview:_ingredientsScrollView];
    }
    return _ingredientsScrollView;
}

-(void) adjustScrollContentSizeToHeight:(float)height
{
    self.ingredientsScrollView.contentSize = height > self.ingredientsScrollView.frame.size.height ?
        CGSizeMake(self.ingredientsScrollView.frame.size.width, height) :
    CGSizeMake(self.ingredientsScrollView.frame.size.width, self.ingredientsScrollView.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
