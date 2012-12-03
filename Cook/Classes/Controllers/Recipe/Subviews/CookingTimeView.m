//
//  CookingTimeView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CookingTimeView.h"
#import "ViewHelper.h"
#import "Theme.h"

@interface CookingTimeView()
@property(nonatomic,strong) UILabel *cookingTimeLabel;
@end
@implementation CookingTimeView

//overridden
-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
}


#pragma mark - Private methods

//overridden
-(void)styleViews
{
    self.cookingTimeLabel.font = [Theme defaultLabelFont];
    self.cookingTimeLabel.textColor = [Theme directionsLabelColor];
    self.cookingTimeLabel.backgroundColor = [UIColor clearColor];
    
}

-(void)configViews
{
    self.cookingTimeLabel.frame = CGRectMake(35.0f, 2.0f, self.bounds.size.width-35.0f, self.bounds.size.height);
    if (self.cookingTimeInSeconds > 0.0f) {
        self.cookingTimeLabel.text = [ViewHelper formatAsHoursSeconds:self.cookingTimeInSeconds];
    }
}

-(UILabel *)cookingTimeLabel
{
    if (!_cookingTimeLabel) {
        _cookingTimeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:_cookingTimeLabel];
    }
    return _cookingTimeLabel;
}

@end
