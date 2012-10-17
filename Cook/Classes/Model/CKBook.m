//
//  CKBook.m
//  Cook
//
//  Created by Jeff Tan-Ang on 2/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBook.h"
#import "CKRecipe.h"
#import "NSString+Utilities.h"
#import "NSArray+Enumerable.h"

@interface CKBook ()

+ (CKBook *)createBookIfRequiredForParseBook:(PFObject *)parseBook user:(CKUser *)user;

@end

@implementation CKBook

+ (void)bookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
    
    // Get local cache first before getting updated with networked version.
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *parseBook, NSError *error) {
        if (!error) {
            success([CKBook createBookIfRequiredForParseBook:parseBook user:user]);
        } else {
            failure(error);
        }
    }];

}

+ (PFObject *)parseBookForParseUser:(PFUser *)parseUser {
    PFObject *parseBook = [PFObject objectWithClassName:kBookModelName];
    [parseBook setObject:kBookAttrDefaultNameValue forKey:kModelAttrName];
    [parseBook setObject:parseUser forKey:kUserModelForeignKeyName];
    return parseBook;
}

+(void)friendsBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
    
    // List of friend keys
    NSArray *friendUserKeys = [user.friendIds collect:^id(NSString *friendObjectId) {
        return [PFUser objectWithoutDataWithClassName:kUserModelName objectId:friendObjectId];
    }];
    
    // Goes to network first before falling back to cache.
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query whereKey:kUserModelForeignKeyName containedIn:friendUserKeys];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            NSArray *books = [results collect:^id(PFObject *parseBook) {
                return [[CKBook alloc] initWithParseObject:parseBook];
            }];
            DLog(@"Loaded friends %d books.", [books count]);
            success(books);
        } else {
            failure(error);
        }
    }];
    
}

- (id)initWithParseBook:(PFObject *)parseBook user:(CKUser *)user {
    if (self = [super initWithParseObject:parseBook]) {
        self.user = user;
    }
    return self;
}

- (void)setCoverPhotoName:(NSString *)coverPhotoName {
    [self.parseObject setObject:coverPhotoName forKey:kBookAttrCoverPhotoName];
}

- (NSString *)coverPhotoName {
    return [self.parseObject objectForKey:kBookAttrCoverPhotoName];
}

- (void)listRecipesSuccess:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kRecipeModelName];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query whereKey:kUserModelForeignKeyName equalTo:self.user.parseObject];
    [query whereKey:kBookModelForeignKeyName equalTo:self.parseObject];
    [query orderByDescending:kModelAttrUpdatedAt];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseRecipes, NSError *error) {
        if (!error) {
            NSArray *recipes = [parseRecipes collect:^id(PFObject *parseRecipe) {
                return [CKRecipe recipeForParseRecipe:parseRecipe user:self.user];
            }];
            DLog(@"fetch returned %i recipes", [recipes count]);
            success(recipes);
        } else {
            failure(error);
        }
    }];
}


#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.coverPhotoName] forKey:@"coverPhotoName"];
    return descriptionProperties;
}

#pragma mark - Private methods

+ (CKBook *)createBookIfRequiredForParseBook:(PFObject *)parseBook user:(CKUser *)user {
    if (!parseBook) {
        parseBook = [CKBook parseBookForParseUser:(PFUser *)user.parseObject];
    }
    return [[CKBook alloc] initWithParseBook:parseBook user:user];
}

@end
