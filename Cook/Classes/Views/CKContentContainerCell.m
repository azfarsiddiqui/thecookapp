//
//  CKContentContainerCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 8/11/2013.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKContentContainerCell.h"

@interface CKContentContainerCell ()

@property (nonatomic, strong) UIView *cellContentView;

@end

@implementation CKContentContainerCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configureContentView:(UIView *)cellContentView {
    [self.cellContentView removeFromSuperview];
    cellContentView.frame = (CGRect){
        floorf((self.contentView.bounds.size.width - cellContentView.frame.size.width) / 2.0),
        floorf((self.contentView.bounds.size.height - cellContentView.frame.size.height) / 2.0),
        cellContentView.frame.size.width,
        cellContentView.frame.size.height
    };
    [self.contentView addSubview:cellContentView];
    self.cellContentView = cellContentView;
}

@end
