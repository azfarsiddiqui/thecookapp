//
//  TodayRecipeCell.m
//  Cook
//
//  Created by Gerald on 8/09/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "TodayRecipeCell.h"

@implementation TodayRecipeCell

- (void)awakeFromNib {
    // Initialization code
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.profileImageView.bounds
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:(CGSize){
                                                             floorf(self.profileImageView.bounds.size.width / 2.0),
                                                             floorf(self.profileImageView.bounds.size.height / 2.0)}];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.profileImageView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.profileImageView.layer.mask = maskLayer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
