//
//  ServesView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesView.h"

@implementation ServesView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.numServesLabel.font = [Theme defaultLabelFont];
//        self.numServesLabel.textColor = [Theme defaultLabelColor];

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
