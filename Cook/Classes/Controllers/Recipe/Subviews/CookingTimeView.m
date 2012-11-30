//
//  CookingTimeView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CookingTimeView.h"

@implementation CookingTimeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.cookingTimeLabel.font = [Theme defaultLabelFont];
//        self.cookingTimeLabel.textColor = [Theme defaultLabelColor];

    }
    return self;
}

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
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
