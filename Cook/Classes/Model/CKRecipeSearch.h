//
//  CKRecipeSearch.h
//  Cook
//
//  Created by Jeff Tan-Ang on 5/04/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRecipe.h"

@interface CKRecipeSearch : NSObject

@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, assign) CKRecipeSearchFilter filter;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSUInteger batchIndex;
@property (nonatomic, assign) NSUInteger numBatches;
@property (nonatomic, strong) NSArray *results;

@end
