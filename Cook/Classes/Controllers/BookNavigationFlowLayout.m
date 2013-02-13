//
//  BookNavigationFlowLayout.m
//  Cook
//
//  Created by Jeff Tan-Ang on 11/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationFlowLayout.h"
#import "BookNavigationFlowLayoutAttributes.h"

@implementation BookNavigationFlowLayout

+ (CGSize)unitSize {
    return CGSizeMake(280.0, 500.0);
}

+ (CGFloat)columnSeparatorWidth {
    return 40.0;
}

+ (Class)layoutAttributesClass {
    DLog();
    return [BookNavigationFlowLayoutAttributes class];
}

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (void)prepareLayout {
    DLog();
}

#pragma mark - UICollectionViewLayout methods

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *layoutAttributes in attributes) {
        
        
    }
    return attributes;
}

@end
