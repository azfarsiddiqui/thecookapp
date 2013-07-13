//
//  BookCategoryLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryLayout.h"

@implementation BookCategoryLayout

+ (CGSize)unitSize {
    return CGSizeMake(312.0, 642.0);
}

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = [BookCategoryLayout unitSize];
    }
    return self;
}

@end
