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

@interface CookingDirectionsView()
@property(nonatomic,strong) UITextView *directionsTextView;
@property(nonatomic,strong) UIScrollView *directionsScrollView;

@end
@implementation CookingDirectionsView

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
}

#pragma mark - Private methods

//overridden
-(void) configViews
{
    
    self.directionsScrollView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    
    CGSize maxSize = CGSizeMake(330.0f, CGFLOAT_MAX);
    self.directionsTextView.text = self.directions;
    CGSize requiredSize = [self.directions sizeWithFont:self.directionsTextView.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    self.directionsTextView.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
    [ViewHelper adjustScrollContentSize:self.directionsScrollView forHeight:requiredSize.height];
}

//overridden
-(void)styleViews
{
    self.directionsTextView.font = [Theme defaultLabelFont];
    self.directionsTextView.textColor = [Theme directionsLabelColor];
    self.directionsTextView.backgroundColor = [UIColor clearColor];
}

-(UITextView *)directionsTextView
{
    if (!_directionsTextView) {
        _directionsTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _directionsTextView.editable = NO;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
