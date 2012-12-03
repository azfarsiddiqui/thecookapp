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
#import "CKBookCover.h"

@implementation CKBook

+ (void)bookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
    [query includeKey:kUserModelForeignKeyName];
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
    [parseBook setObject:kBookAttrDefaultCaptionValue forKey:kBookAttrCaption];
    [parseBook setObject:[CKBookCover initialCover] forKey:kBookAttrCover];
    [parseBook setObject:[CKBookCover initialIllustration] forKey:kBookAttrIllustration];
    return parseBook;
}

+ (PFObject *)createParseBookForParseUser:(PFUser *)parseUser {
    PFObject *parseBook = [CKBook createParseBook];
    [parseBook setObject:parseUser forKey:kUserModelForeignKeyName];
    return parseBook;
}

+ (void)followBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    // User Book follows
    PFQuery *userBookFollowsQuery = [PFQuery queryWithClassName:kUserBookFollowModelName];
    [userBookFollowsQuery setCachePolicy:kPFCachePolicyNetworkElseCache];
    [userBookFollowsQuery includeKey:kBookModelForeignKeyName]; // Include the books
    [userBookFollowsQuery includeKey:[NSString stringWithFormat:@"%@.%@", kBookModelForeignKeyName, kUserModelForeignKeyName]];
    [userBookFollowsQuery whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [userBookFollowsQuery orderByAscending:kUserBookFollowAttrOrder];
    [userBookFollowsQuery findObjectsInBackgroundWithBlock:^(NSArray *parseFollows, NSError *error) {
        if (!error) {
            
            // Extract the books.
            NSArray *books = [parseFollows collect:^id(PFObject *parseFollow) {
                PFObject *parseBook = [parseFollow objectForKey:kBookModelForeignKeyName];
                return [[CKBook alloc] initWithParseObject:parseBook];
            }];
            
            success(books);
            
        } else {
            DLog(@"Error loading books: %@", [error localizedDescription]);
            failure(error);
        }
    }];
    
}

+ (void)friendsBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    // Facebook friends.
    NSArray *facebookFriends = [user.parseUser objectForKey:kUserAttrFacebookFriends];
    
    // Friends query
    PFQuery *friendsQuery = [PFUser query];
    [friendsQuery setCachePolicy:kPFCachePolicyNetworkElseCache];
    [friendsQuery whereKey:kUserAttrFacebookId containedIn:facebookFriends];
    
    // Existing follows.
    PFQuery *followsQuery = [PFQuery queryWithClassName:kUserBookFollowModelName];
    [followsQuery whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [followsQuery setCachePolicy:kPFCachePolicyNetworkElseCache];

    // Friends books query.
    PFQuery *friendsBooksQuery = [PFQuery queryWithClassName:kBookModelName];
    [friendsBooksQuery setCachePolicy:kPFCachePolicyNetworkElseCache];
    [friendsBooksQuery whereKey:kUserModelForeignKeyName matchesQuery:friendsQuery];
    [friendsBooksQuery whereKey:kModelObjectId doesNotMatchKey:kBookModelForeignKeyName inQuery:followsQuery];
    [friendsBooksQuery findObjectsInBackgroundWithBlock:^(NSArray *parseBooks, NSError *error) {
        
        if (!error) {
            
            // Extract the books.
            NSArray *books = [parseBooks collect:^id(PFObject *parseBook) {
                return [[CKBook alloc] initWithParseObject:parseBook];
            }];
            
            success(books);
            
        } else {
            DLog(@"Error loading user friends: %@", [error localizedDescription]);
            failure(error);
        }
        
    }];
    
}

+ (void)featuredBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query includeKey:kUserModelForeignKeyName];
    [query setLimit:20];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseBooks, NSError *error) {
        if (!error) {
            NSArray *books = [parseBooks collect:^id(PFObject *parseBook) {
                return [[CKBook alloc] initWithParseObject:parseBook];
            }];
            success(books);
        } else {
            failure(error);
        }
        
    }];
}

+ (CKBook *)myInitialBook {
    PFObject *parseBook = [PFObject objectWithClassName:kBookModelName];
    [parseBook setObject:kBookAttrDefaultNameValue forKey:kModelAttrName];
    [parseBook setObject:[CKBookCover initialCover] forKey:kBookAttrCover];
    [parseBook setObject:[CKBookCover initialIllustration] forKey:kBookAttrIllustration];
    return [[CKBook alloc] initWithParseObject:parseBook];
}

+ (CKBook *)defaultBook {
    PFObject *parseBook = [PFObject objectWithClassName:kBookModelName];
    [parseBook setObject:kBookAttrDefaultNameValue forKey:kModelAttrName];
    [parseBook setObject:[CKBookCover defaultCover] forKey:kBookAttrCover];
    [parseBook setObject:[CKBookCover defaultIllustration] forKey:kBookAttrIllustration];
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

- (void)setCaption:(NSString *)caption {
    [self.parseObject setObject:caption forKey:kBookAttrCaption];
}

- (NSString *)caption {
    NSString *caption = [self.parseObject objectForKey:kBookAttrCaption];
    if ([caption length] == 0) {
        return kBookAttrDefaultCaptionValue;
    } else {
        return caption;
    }
}

- (void)setNumRecipes:(NSInteger)numRecipes {
    [self.parseObject setObject:[NSNumber numberWithInteger:numRecipes] forKey:kBookAttrNumRecipes];
}

- (NSInteger)numRecipes {
    return [[self.parseObject objectForKey:kBookAttrNumRecipes] integerValue];
}

- (NSInteger)numCategories {
    return [self.categories count];
}

- (NSArray *)categories {
    return [self.parseObject objectForKey:kBookAttrCategories];
}

- (void)listRecipesSuccess:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kRecipeModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query whereKey:kUserModelForeignKeyName equalTo:self.user.parseObject];
    [query whereKey:kBookModelForeignKeyName equalTo:self.parseObject];
    [query includeKey:kCategoryModelForeignKeyName];
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

- (BOOL)editable {
    return [self.user.objectId isEqualToString:[CKUser currentUser].objectId];
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

+ (void)loadBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success
                        failure:(ObjectFailureBlock)failure {
    
    // Admin book follow.
    PFQuery *adminFollowBookQuery = [PFQuery queryWithClassName:kBookFollowModelName];
    [adminFollowBookQuery whereKey:kBookFollowAttrAdmin equalTo:[NSNumber numberWithBool:YES]];
    
    // Merged follow query for the current user.
    PFQuery *followBookQuery = [PFQuery queryWithClassName:kBookFollowModelName];
    [followBookQuery whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [followBookQuery whereKey:kBookFollowAttrMerge equalTo:[NSNumber numberWithBool:YES]];
    
    // Combined query.
    PFQuery *booksQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:adminFollowBookQuery, followBookQuery, nil]];
    [booksQuery includeKey:kBookModelForeignKeyName];  // Load associated books.
    [booksQuery includeKey:[NSString stringWithFormat:@"%@.%@", kBookModelForeignKeyName, kUserModelForeignKeyName]];  // Load associated users.
    [booksQuery findObjectsInBackgroundWithBlock:^(NSArray *parseFollows, NSError *error) {
        if (!error) {
            
            // Get my friends books.
            NSArray *friendsBooks = [parseFollows collect:^id(PFObject *parseFollow) {
                PFObject *parseBook = [parseFollow objectForKey:kBookModelForeignKeyName];
                return [[CKBook alloc] initWithParseObject:parseBook];
            }];
            
            // Only return unique books - workaround for duplicated books because of follow persistence inconsistency.
            NSMutableArray *bookIds = [NSMutableArray array];
            NSMutableArray *uniqueFriendsBooks = [NSMutableArray array];
            for (CKBook *book in friendsBooks) {
                if (![bookIds containsObject:book.objectId]) {
                    [bookIds addObject:book.objectId];
                    [uniqueFriendsBooks addObject:book];
                }
            }
            
            // Sort them by admin, then user names.
            NSSortDescriptor *adminSorter = [[NSSortDescriptor alloc] initWithKey:@"user.admin" ascending:NO];
            NSSortDescriptor *nameSorter = [[NSSortDescriptor alloc] initWithKey:@"user.name" ascending:YES];
            
            // Return my book and friends books.
            success([uniqueFriendsBooks sortedArrayUsingDescriptors:[NSArray arrayWithObjects:adminSorter, nameSorter, nil]]);
            
        } else {
            DLog(@"Error loading books: %@", [error localizedDescription]);
            failure(error);
        }
    }];
}

@end
