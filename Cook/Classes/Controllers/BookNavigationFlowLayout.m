//
//  BookNavigationFlowLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationFlowLayout.h"

@implementation BookNavigationFlowLayout

+ (CGSize)unitSize {
    return CGSizeMake(280.0, 500.0);
}

+ (CGFloat)columnSeparatorWidth {
    return 40.0;
}

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

@end
