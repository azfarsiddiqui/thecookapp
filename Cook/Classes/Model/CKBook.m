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
#import "MRCEnumerable.h"
#import "BookCover.h"

@interface CKBook ()

+ (CKBook *)createBookIfRequiredForParseBook:(PFObject *)parseBook user:(CKUser *)user;

@end

@implementation CKBook

+ (void)bookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
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

+ (PFObject *)createParseBook {
    PFObject *parseBook = [PFObject objectWithClassName:kBookModelName];
    [parseBook setObject:kBookAttrDefaultNameValue forKey:kModelAttrName];
    [parseBook setObject:[BookCover initialCover] forKey:kBookAttrCover];
    [parseBook setObject:[BookCover initialIllustration] forKey:kBookAttrIllustration];
    return parseBook;
}

+ (PFObject *)createParseBookForParseUser:(PFUser *)parseUser {
    PFObject *parseBook = [CKBook createParseBook];
    [parseBook setObject:parseUser forKey:kUserModelForeignKeyName];
    return parseBook;
}

+ (void)friendsBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    // Auto follow any friends first before loading books.
    [user autoFollowCompletion:^{
        [CKBook loadFriendsBooksForUser:user success:success failure:failure];
    }
                       failure:^(NSError *error) {
                           failure(error);
                       }];
}

+ (CKBook *)myInitialBook {
    PFObject *parseBook = [PFObject objectWithClassName:kBookModelName];
    [parseBook setObject:kBookAttrDefaultNameValue forKey:kModelAttrName];
    [parseBook setObject:[BookCover initialCover] forKey:kBookAttrCover];
    [parseBook setObject:[BookCover initialIllustration] forKey:kBookAttrIllustration];
    return [[CKBook alloc] initWithParseObject:parseBook];
}

+ (CKBook *)defaultBook {
    PFObject *parseBook = [PFObject objectWithClassName:kBookModelName];
    [parseBook setObject:kBookAttrDefaultNameValue forKey:kModelAttrName];
    [parseBook setObject:[BookCover defaultCover] forKey:kBookAttrCover];
    [parseBook setObject:[BookCover defaultIllustration] forKey:kBookAttrIllustration];
    return [[CKBook alloc] initWithParseObject:parseBook];
}

#pragma mark - Instance 

- (id)initWithParseObject:(PFObject *)parseObject {
    if (self = [super initWithParseObject:parseObject]) {
        PFUser *parseUser = [parseObject objectForKey:kUserModelForeignKeyName];
        if (parseUser) {
            self.user = [[CKUser alloc] initWithParseUser:parseUser];
        }
    }
    return self;
}

- (id)initWithParseBook:(PFObject *)parseBook user:(CKUser *)user {
    if (self = [super initWithParseObject:parseBook]) {
        self.user = user;
    }
    return self;
}

- (void)setCover:(NSString *)cover {
    [self.parseObject setObject:cover forKey:kBookAttrCover];
}

- (NSString *)cover {
    return [self.parseObject objectForKey:kBookAttrCover];
}

- (void)setIllustration:(NSString *)illustration {
    [self.parseObject setObject:illustration forKey:kBookAttrIllustration];
}

- (NSString *)illustration {
    return [self.parseObject objectForKey:kBookAttrIllustration];
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

- (NSString *)userName {
    return self.user.name;
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.cover] forKey:kBookAttrCover];
    [descriptionProperties setValue:[NSString CK_safeString:self.illustration] forKey:kBookAttrIllustration];
    return descriptionProperties;
}

#pragma mark - Private methods

+ (CKBook *)createBookIfRequiredForParseBook:(PFObject *)parseBook user:(CKUser *)user {
    if (!parseBook) {
        parseBook = [CKBook createParseBookForParseUser:(PFUser *)user.parseObject];
    }
    return [[CKBook alloc] initWithParseBook:parseBook user:user];
}

+ (void)loadFriendsBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success
                        failure:(ObjectFailureBlock)failure {
    
    // Friends books query.
    NSArray *friendUserKeys = [[user followIds] collect:^id(NSString *friendObjectId) {
        return [PFUser objectWithoutDataWithClassName:kUserModelName objectId:friendObjectId];
    }];
    PFQuery *friendsBooksQuery = [PFQuery queryWithClassName:kBookModelName];
    [friendsBooksQuery setCachePolicy:kPFCachePolicyNetworkElseCache];
    [friendsBooksQuery whereKey:kUserModelForeignKeyName containedIn:friendUserKeys];
    [friendsBooksQuery orderByAscending:kModelAttrName];
    [friendsBooksQuery includeKey:kUserModelForeignKeyName];  // Load associated user.
    [friendsBooksQuery findObjectsInBackgroundWithBlock:^(NSArray *parseBooks, NSError *error) {
        if (!error) {
            
            // Get my friends books.
            NSArray *friendsParseBooks = [parseBooks select:^BOOL(PFObject *parseBook) {
                PFUser *parseUser = [parseBook objectForKey:kUserModelForeignKeyName];
                return ![parseUser.objectId isEqualToString:user.parseUser.objectId];
            }];
            NSArray *friendsBooks = [friendsParseBooks collect:^id(PFObject *parseBook) {
                return [[CKBook alloc] initWithParseObject:parseBook];
            }];
            DLog(@"Found friends books: %@", friendsBooks);
            
            // Return my book and friends books.
            success(friendsBooks);
            
        } else {
            DLog(@"Error loading books: %@", [error localizedDescription]);
            failure(error);
        }
    }];
}

@end
