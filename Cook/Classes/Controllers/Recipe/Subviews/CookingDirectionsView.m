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
@property(nonatomic,strong) UIImageView *editIconImageView;
@property(nonatomic,strong) UITextView *directionsTextView;
@end
@implementation CookingDirectionsView

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
    self.editIconImageView.hidden = !editable;
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
    self.directionsLabel.backgroundColor = [UIColor clearColor];
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
        _directionsTextView.backgroundColor = [UIColor clearColor];
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

-(UIImageView *)editIconImageView
{
    if (!_editIconImageView) {
        UIImage *editIconImage = [UIImage imageNamed:@"cook_customise_btns_textedit.png"];
        _editIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - floorf(0.75*(editIconImage.size.width)),-5.0f,
                                                                           editIconImage.size.width, editIconImage.size.height)];
        _editIconImageView.hidden = YES;
        _editIconImageView.image = editIconImage;
        [self addSubview:_editIconImageView];
    }
    return _editIconImageView;
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
    self.directions = textView.text;
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
