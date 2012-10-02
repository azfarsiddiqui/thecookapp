//
//  CKDashboardBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKDashboardBookCell.h"
#import <QuartzCore/QuartzCore.h>

@interface CKDashboardBookCell ()

@property (nonatomic, retain) UILabel *textLabel;

@end

@implementation CKDashboardBookCell

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                   0.0,
                                                                   self.contentView.bounds.size.width,
                                                                   30.0)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        label.backgroundColor = [UIColor darkGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:12.0];
        label.textColor = [UIColor whiteColor];
        [self.contentView addSubview:label];
        self.textLabel = label;
    }
    return self;
}

- (void)setText:(NSString *)text {
    self.textLabel.text = text;
}

@end
