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

//+ (NSArray *)getCachedRecipes {
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"com.cook.thecookapp"];
//    NSArray *cachedRecipes = [sharedDefaults objectForKey:@"cachedRecipes"];
//}

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

//- (NSDictionary *)dictionaryRepresentation {
//    return @{@"profilePicURL": self.profilePicUrl,
//             @"countryName": self.countryName,
//             @"recipeName": self.recipeName,
//             @"recipeUpdatedAt": self.recipeUpdatedAt,
//             @"numServes": self.numServes,
//             @"makeTimeMins": self.makeTimeMins,
//             @"quantityType": self.quantityType
//}

@end