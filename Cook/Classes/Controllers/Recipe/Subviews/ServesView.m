//
//  ServesView.m
//  Cook
//
//  Created by Jonny Sagorin on 11/29/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "ServesView.h"
#import "Theme.h"

@interface ServesView()
@property(nonatomic,strong) UILabel *numServesLabel;
@end
@implementation ServesView

//overridden
-(void)makeEditable:(BOOL)editable
{
    [super makeEditable:editable];
}


#pragma mark - Private methods

//overridden
-(void)styleViews
{
    self.numServesLabel.font = [Theme defaultLabelFont];
    self.numServesLabel.textColor = [Theme directionsLabelColor];
    self.numServesLabel.backgroundColor = [UIColor clearColor];

}

-(void)configViews
{
    self.numServesLabel.frame = CGRectMake(35.0f, 2.0f, self.bounds.size.width-35.0f, self.bounds.size.height);
    self.numServesLabel.text = [NSString stringWithFormat:@"%i",self.serves];
}

-(UILabel *)numServesLabel
{
    if (!_numServesLabel) {
        _numServesLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:_numServesLabel];
    }
    return _numServesLabel;
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
