//
//  CookingDirectionsView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CookingDirectionsView.h"
#import "Theme.h"
#import "ViewHelper.h"

#define directionsInputInsets UIEdgeInsetsMake(5.0f,5.0f,0.0f,0.0f)

@interface CookingDirectionsView()<UITextViewDelegate>
@property(nonatomic,strong) UILabel *directionsLabel;
@property(nonatomic,strong) UIScrollView *directionsScrollView;
@property(nonatomic,strong) UIImageView *backgroundEditImageView;
@property(nonatomic,strong) UITextView *directionsTextView;
@end
@implementation CookingDirectionsView

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    self.backgroundEditImageView.hidden = !editable;
    self.directionsLabel.hidden = editable;
    self.directionsTextView.text = self.directions;
    self.directionsTextView.frame = [self editSize];
    self.directionsTextView.hidden = !editable;
}

#pragma mark - Private methods

//overridden
-(void) configViews
{
    DLog();
    self.directionsScrollView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    self.directionsLabel.text = self.directions;
    CGRect editSize = [self editSize];
    self.directionsLabel.frame = editSize;
    [ViewHelper adjustScrollContentSize:self.directionsScrollView forHeight:editSize.size.height];
}

//overridden
-(void)styleViews
{
    self.directionsLabel.font = [Theme defaultLabelFont];
    self.directionsLabel.textColor = [Theme directionsLabelColor];
    self.directionsTextView.font = [Theme defaultLabelFont];
    self.directionsLabel.backgroundColor = [UIColor redColor];
}

-(UILabel *)directionsLabel
{
    if (!_directionsLabel) {
        _directionsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _directionsLabel.numberOfLines = 0;
        [self.directionsScrollView addSubview:_directionsLabel];
    }
    
    return _directionsLabel;
}

-(UITextView *)directionsTextView
{
    if (!_directionsTextView) {
        _directionsTextView = [[UITextView alloc]initWithFrame:CGRectZero];
        _directionsTextView.hidden = YES;
        _directionsTextView.backgroundColor = [UIColor redColor];
        [self.directionsScrollView addSubview:_directionsTextView];
    }
    return _directionsTextView;
}

-(UIScrollView *)directionsScrollView
{
    if (!_directionsScrollView) {
        _directionsScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _directionsScrollView.scrollEnabled = YES;
        [self addSubview:_directionsScrollView];
    }
    return _directionsScrollView;
}

-(UIImageView *)backgroundEditImageView
{
    if (!_backgroundEditImageView) {
        UIImage *backgroundImage = [[UIImage imageNamed:@"cook_editrecipe_textbox"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0f,4.0f,4.0f,4.0f)];
        _backgroundEditImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
        _backgroundEditImageView.hidden = YES;
        _backgroundEditImageView.image = backgroundImage;
        [self insertSubview:_backgroundEditImageView atIndex:0];
    }
    return _backgroundEditImageView;
}


-(CGRect)editSize
{
    CGSize maxSize = CGSizeMake(self.directionsScrollView.frame.size.width-directionsInputInsets.left-directionsInputInsets.right, CGFLOAT_MAX);
    CGSize requiredSize = [self.directions sizeWithFont:[Theme defaultLabelFont] constrainedToSize:maxSize];
    return CGRectMake(directionsInputInsets.top, directionsInputInsets.left,
                                               self.directionsScrollView.frame.size.width-directionsInputInsets.left-directionsInputInsets.right,
                                               requiredSize.height+directionsInputInsets.top);
}

#pragma mark - UITextViewDelegate
-(void)textViewDidEndEditing:(UITextView *)textView
{
    DLog();
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
