//
//  BookNavigationHelper.m
//  Cook
//
//  Created by Jeff Tan-Ang on 6/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookNavigationHelper.h"
#import "CKRecipe.h"
#import "BookNavigationStackViewController.h"

@implementation BookNavigationHelper

+ (BookNavigationHelper *)sharedInstance {
    static dispatch_once_t pred;
    static BookNavigationHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[BookNavigationHelper alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)updateBookNavigationWithRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    
    // Return immediately if no opened book.
    if (!self.bookNavigationViewController) {
        completion();
    }
    
    // Ask the opened book to update with the recipe.
    [self.bookNavigationViewController updateWithRecipe:recipe completion:completion];
}

- (void)updateBookNavigationWithDeletedRecipe:(CKRecipe *)recipe completion:(BookNavigationUpdatedBlock)completion {
    
    // Return immediately if no opened book.
    if (!self.bookNavigationViewController) {
        completion();
    }
    
    // Ask the opened book to update with the recipe.
    [self.bookNavigationViewController updateWithDeletedRecipe:recipe completion:completion];
}

- (void)updateBookNavigationWithDeletedPage:(NSString *)page completion:(BookNavigationUpdatedBlock)completion {
    
    // Return immediately if no opened book.
    if (!self.bookNavigationViewController) {
        completion();
    }
    
    // Ask the opened book to update with the recipe.
    [self.bookNavigationViewController updateWithDeletedPage:page completion:completion];
}

@end
