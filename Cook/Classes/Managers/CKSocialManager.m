//
//  CKSocialManager.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/09/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKSocialManager.h"
#import "CKRecipe.h"
#import "EventHelper.h"

@interface CKSocialManager ()

@property (nonatomic, strong) NSMutableDictionary *recipeNumComments;
@property (nonatomic, strong) NSMutableDictionary *recipeNumLikes;

@end

@implementation CKSocialManager

+ (CKSocialManager *)sharedInstance {
    static dispatch_once_t pred;
    static CKSocialManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKSocialManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.recipeNumComments = [NSMutableDictionary dictionary];
        self.recipeNumLikes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)reset {
    [self.recipeNumComments removeAllObjects];
    [self.recipeNumLikes removeAllObjects];
}

- (void)configureRecipe:(CKRecipe *)recipe {
    [self updateRecipe:recipe numComments:recipe.numComments broadcast:NO];
    [self updateRecipe:recipe numLikes:recipe.numLikes broadcast:NO];
}

- (void)updateRecipe:(CKRecipe *)recipe numComments:(NSUInteger)numComments {
    [self updateRecipe:recipe numComments:numComments broadcast:YES];
}

- (void)updateRecipe:(CKRecipe *)recipe numLikes:(NSUInteger)numLikes {
    [self updateRecipe:recipe numLikes:numLikes broadcast:YES];
}

- (void)like:(BOOL)like recipe:(CKRecipe *)recipe {
    NSInteger likes = [self numLikesForRecipe:recipe];
    [self updateRecipe:recipe numLikes:like ? (likes + 1) : (likes - 1)];
}

- (NSUInteger)numCommentsForRecipe:(CKRecipe *)recipe {
    
    DLog(@"numComments: %d", recipe.numComments);
    DLog(@"numLikes   : %d", recipe.numLikes);
    
    if (recipe == nil || ![recipe persisted]) {
        return 0;
    } else if ([self.recipeNumComments objectForKey:recipe.objectId]) {
        return [[self.recipeNumComments objectForKey:recipe.objectId] unsignedIntegerValue];
    } else {
        return recipe.numComments;
    }
}

- (NSUInteger)numLikesForRecipe:(CKRecipe *)recipe {
    if (recipe == nil || ![recipe persisted]) {
        return 0;
    } else if ([self.recipeNumLikes objectForKey:recipe.objectId]) {
        return [[self.recipeNumLikes objectForKey:recipe.objectId] unsignedIntegerValue];
    } else {
        return recipe.numLikes;
    }
}

#pragma mark - Private methods

- (void)updateRecipe:(CKRecipe *)recipe numComments:(NSUInteger)numComments broadcast:(BOOL)broadcast {
    DLog(@"+++++ numComments: %d", numComments);
    if (recipe != nil && [recipe persisted]) {
        [self.recipeNumComments setObject:@(numComments) forKey:recipe.objectId];
        
        if (broadcast) {
            [EventHelper postSocialUpdatesNumComments:numComments recipe:recipe];
        }
    }
}

- (void)updateRecipe:(CKRecipe *)recipe numLikes:(NSUInteger)numLikes broadcast:(BOOL)broadcast {
    DLog(@"+++++ numLikes: %d", numLikes);
    if (recipe != nil && [recipe persisted]) {
        [self.recipeNumLikes setObject:@(numLikes) forKey:recipe.objectId];
        
        if (broadcast) {
            [EventHelper postSocialUpdatesNumLikes:numLikes recipe:recipe];
        }
    }
}


@end
