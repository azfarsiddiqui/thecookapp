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
@property(nonatomic,strong) UILabel *directionsLabel;
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
    DLog();
    self.directionsScrollView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    CGSize maxSize = CGSizeMake(self.directionsScrollView.frame.size.width, CGFLOAT_MAX);
    self.directionsLabel.text = self.directions;
    CGSize requiredSize = [self.directionsLabel sizeThatFits:maxSize];
    self.directionsLabel.frame = CGRectMake(0, 0, requiredSize.width, requiredSize.height);
    [ViewHelper adjustScrollContentSize:self.directionsScrollView forHeight:requiredSize.height];
}

//overridden
-(void)styleViews
{
    self.directionsLabel.font = [Theme defaultLabelFont];
    self.directionsLabel.textColor = [Theme directionsLabelColor];
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
