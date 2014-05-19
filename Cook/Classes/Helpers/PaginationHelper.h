//
//  PaginationHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 18/05/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaginationHelper : NSObject

@property (nonatomic, assign) BOOL ready;
@property (nonatomic, assign) NSUInteger numItems;
@property (nonatomic, strong) NSArray *items;

- (void)reset;
- (void)updateWithItems:(NSArray *)items batchIndex:(NSUInteger)batchIndex numItems:(NSUInteger)numItems numBatches:(NSUInteger)numBatches;
- (void)removeItemAtIndex:(NSUInteger)itemIndex;
- (NSUInteger)currentNumItems;
- (NSUInteger)nextBatchIndex;
- (NSUInteger)nextSliceIndex;
- (BOOL)hasMoreItems;
- (id)itemAtIndex:(NSUInteger)itemIndex;

@end
