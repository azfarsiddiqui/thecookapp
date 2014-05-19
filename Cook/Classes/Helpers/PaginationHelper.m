//
//  PaginationHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/05/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "PaginationHelper.h"

@interface PaginationHelper ()

@property (nonatomic, assign) NSUInteger batchIndex;
@property (nonatomic, assign) NSUInteger numBatches;

@end

@implementation PaginationHelper

- (void)reset {
    [(NSMutableArray *)self.items removeAllObjects];
    self.numItems = 0;
    self.numBatches = 0;
    self.batchIndex = 0;
}

- (void)updateWithItems:(NSArray *)items batchIndex:(NSUInteger)batchIndex numItems:(NSUInteger)numItems numBatches:(NSUInteger)numBatches {
    self.batchIndex = batchIndex;
    self.numItems = numItems;
    self.numBatches = numBatches;
    
    if (batchIndex == 0) {
        self.items = [NSMutableArray arrayWithArray:items];
    } else {
        [(NSMutableArray *)self.items addObjectsFromArray:items];
    }
    
    // Marked as ready.
    self.ready = YES;
}

- (void)removeItemAtIndex:(NSUInteger)itemIndex {
    [(NSMutableArray *)self.items removeObjectAtIndex:itemIndex];
}

- (NSUInteger)currentNumItems {
    return [self.items count];
}

- (NSUInteger)nextBatchIndex {
    return self.ready ? self.batchIndex + 1 : 0;
}

- (NSUInteger)nextSliceIndex {
    return self.ready ? [self.items count] : 0;
}

- (BOOL)hasMoreItems {
    return self.ready ? (self.batchIndex < self.numBatches - 1) : NO;
}

- (id)itemAtIndex:(NSUInteger)itemIndex {
    return [self.items objectAtIndex:itemIndex];
}

@end
