//
//  CookingDirectionsView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CookingDirectionsView.h"

@implementation CookingDirectionsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
}


//-(UILabel *)cookingDirectionsLabel
//{
//    if (!_cookingDirectionsLabel) {
//        _cookingDirectionsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f,  330.0f, 20.0f)];
//        _cookingDirectionsLabel.numberOfLines = 0;
//        _cookingDirectionsLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        [self.cookingDirectionsScrollView addSubview:_cookingDirectionsLabel];
//    }
//    
//    self.cookingDirectionsLabel.font = [Theme defaultLabelFont];
//    self.cookingDirectionsLabel.textColor = [Theme directionsLabelColor];
//
//    return _cookingDirectionsLabel;
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
