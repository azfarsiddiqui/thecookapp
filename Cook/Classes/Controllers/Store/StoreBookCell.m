//
//  StoreBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreBookCell.h"
#import "BenchtopBookCell.h"
#import "CKBookCoverView.h"

@interface CKBookCoverView ()

@property (nonatomic, strong) CKBookCoverView *bookCoverView;

@end

@implementation StoreBookCell

#define kDivideScaleFactor  2.0

+ (CGSize)cellSize {
    CGSize fullSize = [BenchtopBookCell cellSize];
    return CGSizeMake(fullSize.width / kDivideScaleFactor, fullSize.height / kDivideScaleFactor);
}

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

@end
