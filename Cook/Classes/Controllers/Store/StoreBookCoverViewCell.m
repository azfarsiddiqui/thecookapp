//
//  StoreBookCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreBookCoverViewCell.h"
#import "CKBookCoverView.h"

@interface StoreBookCoverViewCell ()

@end

@implementation StoreBookCoverViewCell

+ (CGSize)cellSize {
    return [BenchtopBookCoverViewCell cellSize];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

@end
