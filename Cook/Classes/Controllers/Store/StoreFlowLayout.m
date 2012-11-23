//
//  StoreFlowLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 23/11/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "StoreFlowLayout.h"
#import "StoreBookCell.h"

@implementation StoreFlowLayout

- (id)init {
    if (self = [super init]) {
        self.itemSize = [StoreBookCell cellSize];
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    }
    return self;
}

@end
