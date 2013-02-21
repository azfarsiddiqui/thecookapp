//
//  CKActivity.m
//  Cook
//
//  Created by Jeff Tan-Ang on 21/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKActivity.h"
#import "CKUser.h"
#import "MRCEnumerable.h"
#import "CKRecipe.h"

@interface CKActivity ()

+ (void)saveActivityForParseRecipe:(PFObject *)parseRecipe name:(NSString *)name;
+ (void)saveParseActivity:(PFObject *)parseActivity name:(NSString *)name;

@end

@implementation CKActivity

+ (CKActivity *)activityForParseActivity:(PFObject *)parseActivity {
    return [[CKActivity alloc] initWithParseObject:parseActivity];
}

+ (void)saveAddRecipeActivityForRecipe:(CKRecipe *)recipe {
    [self saveActivityForParseRecipe:recipe.parseObject name:kActivityNameAddRecipe];
}

+ (void)saveUpdateRecipeActivityForRecipe:(CKRecipe *)recipe {
    [self saveActivityForParseRecipe:recipe.parseObject name:kActivityNameUpdateRecipe];
}

+ (void)saveLikeRecipeActivityForRecipe:(CKRecipe *)recipe {
    [self saveActivityForParseRecipe:recipe.parseObject name:kActivityNameLikeRecipe];
}

+ (void)activitiesForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure; {
    PFQuery *query = [PFQuery queryWithClassName:kActivityModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [query includeKey:kUserModelForeignKeyName];
    [query includeKey:kRecipeModelForeignKeyName];
    [query includeKey:[NSString stringWithFormat:@"%@.%@", kRecipeModelForeignKeyName, kRecipeAttrRecipePhotos]];
    [query orderByDescending:kModelAttrCreatedAt];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseActivities, NSError *error) {
        if (!error) {
            NSArray *activities = [parseActivities collect:^id(PFObject *parseActivity) {
                return [CKActivity activityForParseActivity:parseActivity];
            }];
            DLog(@"Fetch returned %d activities", [activities count]);
            success(activities);
        } else {
            failure(error);
        }
    }];
}

- (CKUser *)user {
    if (_user == nil) {
        _user = [CKUser userWithParseUser:[self.parseObject objectForKey:kUserModelForeignKeyName]];
    }
    return _user;
}

- (CKRecipe *)recipe {
    if (_recipe == nil) {
        _recipe = [CKRecipe recipeForParseRecipe:[self.parseObject objectForKey:kRecipeModelForeignKeyName]
                                            user:self.user];
    }
    return _recipe;
}
    
#pragma mark - Private methods

+ (void)saveActivityForParseRecipe:(PFObject *)parseRecipe name:(NSString *)name {
    PFObject *parseActivity = [self objectWithDefaultSecurityWithClassName:kActivityModelName];
    [parseActivity setObject:parseRecipe forKey:kRecipeModelForeignKeyName];
    [self saveParseActivity:parseActivity name:name];
}

+ (void)saveParseActivity:(PFObject *)parseActivity name:(NSString *)name {
    PFUser *currentUser = [PFUser currentUser];
    [parseActivity setObject:name forKey:kModelAttrName];
    [parseActivity setObject:currentUser forKey:kUserModelForeignKeyName];
    [parseActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            DLog(@"Saved activity[%@] name[%@] user[%@]", parseActivity, name, currentUser);
        } else {
            DLog(@"Unable to save name[%@] user[%@]", name, currentUser);
        }
    }];
}

@end
