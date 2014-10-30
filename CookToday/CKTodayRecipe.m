//
//  CKTodayRecipe.m
//  Cook
//
//  Created by Gerald on 24/09/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKTodayRecipe.h"
#import <Parse/Parse.h>

@implementation CKTodayRecipe

+ (void)latestRecipesWithSuccess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:@"ExtensionRecipe"];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *results = [NSMutableArray new];
            for (PFObject *obj in objects) {
                CKTodayRecipe *recipe = [[CKTodayRecipe alloc] initWithParseObject:obj];
                [results addObject:recipe];
            }
            success(results);
        } else {
            failure(error);
        }
    }];
}

+ (NSArray *)getCachedRecipes {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"com.cook.thecookapp"];
    NSArray *cachedRecipes = [sharedDefaults objectForKey:@"cachedRecipes"];
    NSMutableArray *returnArray = [NSMutableArray new];
    [cachedRecipes enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        CKTodayRecipe *recipe = [[CKTodayRecipe alloc] initWithDictionary:obj];
        [returnArray addObject:recipe];
    }];
    return returnArray;
}

- (id)initWithParseObject:(PFObject *)parseObject {
    if (self = [super init]) {
        self.profilePicUrl = [parseObject objectForKey:@"profilePicUrl"];
        self.recipePic = [parseObject objectForKey:@"recipePic"];
        self.countryName = [parseObject objectForKey:@"countryName"];
        self.recipeName = [parseObject objectForKey:@"name"];
        self.recipeUpdatedAt = [parseObject objectForKey:@"recipeUpdatedAt"];
        self.numServes = [parseObject objectForKey:@"numServes"];
        self.makeTimeMins = [parseObject objectForKey:@"makeTimeMins"];
        self.quantityType = [parseObject objectForKey:@"quantityType"];
        self.recipeObjectId = [parseObject objectForKey:@"recipeObjectId"];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)recipeDict {
    if (self = [super init]) {
        self.profilePicUrl = [recipeDict objectForKey:@"profilePicURL"];
        self.recipeImageData = [recipeDict objectForKey:@"recipeImageData"];
        self.countryName = [recipeDict objectForKey:@"countryName"];
        self.recipeName = [recipeDict objectForKey:@"recipeName"];
        self.recipeUpdatedAt = [recipeDict objectForKey:@"recipeUpdatedAt"];
        self.numServes = [recipeDict objectForKey:@"numServes"];
        self.makeTimeMins = [recipeDict objectForKey:@"makeTimeMins"];
        self.quantityType = [recipeDict objectForKey:@"quantityType"];
        self.recipeObjectId = [recipeDict objectForKey:@"recipeObjectId"];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (self.profilePicUrl) {
        [dict setObject:self.profilePicUrl forKey:@"profilePicURL"];
    }
    if (self.countryName) {
        [dict setObject:self.countryName forKey:@"countryName"];
    }
    if (self.recipeName) {
        [dict setObject:self.recipeName forKey:@"recipeName"];
    }
    [dict setObject:self.recipeUpdatedAt forKey:@"recipeUpdatedAt"];
    if (self.numServes) {
        [dict setObject:self.numServes forKey:@"numServes"];
    }
    if (self.makeTimeMins) {
        [dict setObject:self.makeTimeMins forKey:@"makeTimeMins"];
    }
    if (self.quantityType) {
        [dict setObject:self.quantityType forKey:@"quantityType"];
    }
    if (self.recipeImageData) {
        [dict setObject:self.recipeImageData forKey:@"recipeImageData"];
    }
    if (self.recipeObjectId) {
        [dict setObject:self.recipeObjectId forKey:@"recipeObjectId"];
    }
    return dict;
}

@end