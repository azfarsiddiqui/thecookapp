//
//  CKBook.m
//  Cook
//
//  Created by Jeff Tan-Ang on 2/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKBook.h"
#import "CKRecipe.h"
#import "CKRecipePin.h"
#import "NSString+Utilities.h"
#import "MRCEnumerable.h"
#import "CKBookCover.h"
#import "CKPhotoManager.h"
#import "AppHelper.h"
#import "CKBookManager.h"
#import "CKRecipeTag.h"
#import "CloudCodeHelper.h"

@interface CKBook ()

@end

@implementation CKBook

@synthesize titleRecipe = _titleRecipe;

+ (void)bookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
    [query includeKey:kUserModelForeignKeyName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *parseBook, NSError *error) {
        if (!error) {
            success([CKBook bookWithParseObject:parseBook]);
        } else {
            failure(error);
        }
    }];
}

+ (void)dashboardBookForUser:(CKUser *)user success:(GetCachedObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
    [query includeKey:kUserModelForeignKeyName];
    
    // Check if we have a cached result to be passed back to the caller.
    BOOL hasCachedResult = [query hasCachedResult];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseResults, NSError *error) {
        
        if (!error) {
            
            // Do we have a matching book, assume one book to start off with.
            PFObject *parseBook = nil;
            if ([parseResults count] > 0) {
                parseBook = [parseResults objectAtIndex:0];
            }
            
            // If there was no book, then create it!
            if (!parseBook) {
                
                // Create new book.
                [CKBook createBookForUser:user
                                 succeess:^(CKBook *book) {
                                     
                                     // Pre-cache
                                     PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
                                     [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
                                     [query whereKey:kUserModelForeignKeyName equalTo:user.parseObject];
                                     [query includeKey:kUserModelForeignKeyName];
                                     [query findObjectsInBackgroundWithBlock:^(NSArray *parseResults, NSError *error) {
                                         // Ignore, only for pre-caching purposes.
                                     }];
                                     
                                     success(book, NO);
                                     
                                 } failure:^(NSError *error) {
                                     failure(error);
                                 }];
            } else {
                success([[CKBook alloc] initWithParseBook:parseBook user:user], hasCachedResult);
            }
            
        } else {
            failure(error);
        }
        
    }];

}

+ (void)dashboardGuestBookSuccess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    // This creates it locally and not persisted, may be extended for network fetch.
    PFObject *parseBook = [PFObject objectWithClassName:kBookModelName];
    [parseBook setObject:NSLocalizedString(kBookAttrGuestCaptionValue, nil) forKey:kModelAttrName];
    [parseBook setObject:NSLocalizedString(kBookAttrGuestNameValue, nil) forKey:kBookAttrAuthor];
    [parseBook setObject:[CKBookCover guestCover] forKey:kBookAttrCover];
    
    CKBook *guestBook = [[CKBook alloc] initWithParseObject:parseBook];
    guestBook.guest = YES;
    
    success(guestBook);
}

+ (void)dashboardBooksForUser:(CKUser *)user success:(DashboardBooksSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"dashboardBooks"
                       withParameters:[CloudCodeHelper commonCloudCodeParams]
                                block:^(NSDictionary *results, NSError *error) {
                                    
                                    // My book.
                                    CKBook *myBook = nil;
                                    PFObject *myParseBook = [results objectForKey:@"myBook"];
                                    if (myParseBook) {
                                        myBook = [[CKBook alloc] initWithParseBook:myParseBook user:user];
                                    }
                                    
                                    // Followed books.
                                    NSArray *books = [results objectForKey:@"books"];
                                    
                                    // Updates
                                    NSDictionary *bookUpdates = [results objectForKey:@"updates"];
                                    DLog(@"Book Updates: %@", bookUpdates);
                                    
                                    if (!error) {
                                        success(myBook, [CKBook booksFromParseBooks:books], bookUpdates);
                                    } else {
                                        DLog(@"Error loading follow books: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

+ (void)dashboardFollowBooksSuccess:(FollowBooksSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"followBooks_v1_1"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{ @"sortDescending" : @"true" }]
                                block:^(NSDictionary *results, NSError *error) {
                                    NSArray *books = [results objectForKey:@"books"];
                                    NSDictionary *bookUpdates = [results objectForKey:@"updates"];
                                    DLog(@"Book Updates: %@", bookUpdates);
                                    if (!error) {
                                        success([CKBook booksFromParseBooks:books], bookUpdates);
                                    } else {
                                        DLog(@"Error loading follow books: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

+ (void)createBookForUser:(CKUser *)user succeess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFObject *book = [self createParseBookForParseUser:user.parseUser];
    [book saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            success([[CKBook alloc] initWithParseBook:book user:user]);
        } else {
            DLog(@"Error loading user friends: %@", [error localizedDescription]);
            failure(error);
        }
    }];
}

+ (PFObject *)createParseBook {
    
    PFObject *parseBook = [self objectWithDefaultSecurityWithClassName:kBookModelName];
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
    
    // No friends for guest-user.
    if (!user) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            success(nil);
        });
        return;
    }
    
    [PFCloud callFunctionInBackground:@"friendsBooks"
                       withParameters:[CloudCodeHelper commonCloudCodeParams]
                                block:^(NSDictionary *booksResults, NSError *error) {
                                    
                                    if (!error) {
                                        [self processStoreBooksFromResults:booksResults success:success failure:failure];
                                    } else {
                                        DLog(@"Error loading friends/suggested books: %@", [error localizedDescription]);
                                    }
                                }];
    
}

+ (void)facebookSuggestedBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success
                              failure:(ObjectFailureBlock)failure {
    
    [self facebookSuggestedBooksForFacebookIds:user.facebookFriends success:success failure:failure];
}

+ (void)facebookSuggestedBooksForFacebookIds:(NSArray *)facebookIds success:(ListObjectsSuccessBlock)success
                                     failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"facebookSuggestedBooks"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{ @"friendIds" : facebookIds }]
                                block:^(NSDictionary *booksResults, NSError *error) {
                                    
                                    if (!error) {
                                        [self processStoreBooksFromResults:booksResults
                                                                   success:^(NSArray *books){
                                                                       
                                                                       // Annotate them to be suggested books.
                                                                       [books each:^(CKBook *book) {
                                                                           book.status = kBookStatusFBSuggested;
                                                                       }];
                                                                       
                                                                       success(books);
                                                                       
                                                                   } failure:failure];
                                    } else {
                                        DLog(@"Error loading friends/suggested books: %@", [error localizedDescription]);
                                    }
                                }];
    
}

+ (void)friendsAndSuggestedBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success
                                failure:(ObjectFailureBlock)failure {
    
    // No friends for guest-user.
    if (!user) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            success(nil);
        });
        return;
    }
    
    [PFCloud callFunctionInBackground:@"friendsAndSuggestedBooks"
                       withParameters:[CloudCodeHelper commonCloudCodeParams]
                                block:^(NSDictionary *booksResults, NSError *error) {
                                    
                                    if (!error) {
                                        
                                        // Combine the friends and suggested books.
                                        NSArray *friendsBooks = [booksResults objectForKey:@"friends"];
                                        NSMutableArray *friendsSuggestedBooks = [NSMutableArray arrayWithArray:friendsBooks];
                                        NSArray *suggestedBooks = [booksResults objectForKey:@"suggested"];
                                        [friendsSuggestedBooks addObjectsFromArray:suggestedBooks];
                                        NSArray *followedBookIds = [booksResults objectForKey:@"followedBookIds"];
                                        
                                        // Annotate for following and suggested status.
                                        [self annotateForFriendsBooks:friendsBooks
                                                       suggestedBooks:suggestedBooks
                                                                 user:user
                                                      followedBookIds:followedBookIds
                                                              success:^(NSArray *annotatedBooks) {
                                                                  success(annotatedBooks);
                                                              }
                                                              failure:^(NSError *error) {
                                                                  failure(error);
                                                              }];
                                    } else {
                                        DLog(@"Error loading friends/suggested books: %@", [error localizedDescription]);
                                    }
                                }];
}

+ (BOOL)dashboardBookLoadCacheMissError:(NSError *)error {
    return ([error.domain isEqualToString:@"Parse"] && [error code] == kPFErrorCacheMiss);
}

#pragma mark - Store books.

+ (void)categoriesBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"storeCategoriesBooks"
                       withParameters:[CloudCodeHelper commonCloudCodeParams]
                                block:^(NSDictionary *results, NSError *error) {
                                    
                                    if (error) {
                                        failure(error);
                                    } else {
                                        [self processStoreBooksFromResults:results success:success failure:failure];
                                    }
                                    
                                }];
}

+ (void)featuredBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"storeFeatureBooks"
                       withParameters:[CloudCodeHelper commonCloudCodeParams]
                                block:^(NSDictionary *results, NSError *error) {
                                    
                                    if (error) {
                                        failure(error);
                                    } else {
                                        [self processStoreBooksFromResults:results success:success failure:failure];
                                    }
                                    
                                }];
}

+ (void)worldBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"storeWorldBooks"
                       withParameters:[CloudCodeHelper commonCloudCodeParams]
                                block:^(NSDictionary *results, NSError *error) {
                                    
                                    if (error) {
                                        failure(error);
                                    } else {
                                        [self processStoreBooksFromResults:results success:success failure:failure];
                                    }
                                }];
}

#pragma mark - Instance

+ (CKBook *)bookWithParseObject:(PFObject *)parseObject {
    return [[CKBook alloc] initWithParseObject:parseObject];
}

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

- (NSString *)name {
    if (self.captionLocalised) {
        return [self localisedValueForKey:@"caption"];
    } else {
        return [self.parseObject objectForKey:kModelAttrName];
    }
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

- (void)setAuthor:(NSString *)author {
    [self.parseObject setObject:[NSString CK_safeString:author] forKey:kBookAttrAuthor];
}

- (NSString *)author {
    return [self.parseObject objectForKey:kBookAttrAuthor];
}

- (void)setStory:(NSString *)story {
    [self.parseObject setObject:story forKey:kBookAttrStory];
}

- (NSString *)story {
    if (self.summaryLocalised) {
        return [self localisedValueForKey:@"summary"];
    } else {
        return [self.parseObject objectForKey:kBookAttrStory];
    }
}

- (void)setNumRecipes:(NSInteger)numRecipes {
    [self.parseObject setObject:[NSNumber numberWithInteger:numRecipes] forKey:kBookAttrNumRecipes];
}

- (NSInteger)numRecipes {
    return [[self.parseObject objectForKey:kBookAttrNumRecipes] integerValue];
}

- (void)setPages:(NSArray *)pages {
    [self.parseObject setObject:pages forKey:kBookAttrPages];
}

- (NSArray *)pages {
    return [self.parseObject objectForKey:kBookAttrPages];
}

- (BOOL)featured {
    return [[self.parseObject objectForKey:kBookAttrFeatured] boolValue];
}

- (BOOL)showLikes {
    return [[self.parseObject objectForKey:kBookAttrShowLikes] boolValue];
}

- (void)bookRecipesSuccess:(BookRecipesSuccessBlock)success failure:(ObjectFailureBlock)failure {
    DLog();
    
    [PFCloud callFunctionInBackground:@"bookRecipes_v1_4"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{
                                        @"bookId": self.objectId,
                                        @"userId": self.user.objectId
                                        }]
                                block:^(NSDictionary *recipeResults, NSError *error) {
                                    if (!error) {
                                        
                                        PFObject *parseBook = [recipeResults objectForKey:@"book"];
                                        NSDictionary *parsePageRecipes = [recipeResults objectForKey:@"pageRecipes"];
                                        NSDictionary *pageBatches = [recipeResults objectForKey:@"pageBatches"];
                                        NSDictionary *pageRecipeCount = [recipeResults objectForKey:@"pageRecipeCount"];
                                        NSDate *accessDate = [recipeResults objectForKey:@"accessDate"];
                                        NSDictionary *pageRankings = [recipeResults objectForKey:@"pageRankings"];
                                        NSDictionary *parsePagePhotos = [recipeResults objectForKey:@"pagePhotos"];
                                        
                                        // Grab tags.
                                        NSArray *parseTags = [recipeResults objectForKey:@"tags"];
                                        if ([parseTags count] > 0) {
                                            NSArray *tags = [parseTags collect:^id(PFObject *parseTag) {
                                                return [[CKRecipeTag alloc] initWithParseObject:parseTag];
                                            }];
                                            [CKBookManager sharedInstance].tagArray = tags;
                                        }
                                        
                                        // Wrap the recipes in our model.
                                        NSMutableDictionary *pageRecipes = [NSMutableDictionary dictionary];
                                        [parsePageRecipes each:^(NSString *page, NSArray *parseRecipesOrPins) {
                                            
                                            NSArray *recipesOrPins = [parseRecipesOrPins collect:^id(PFObject *parseRecipeOrPin) {
                                                return [self modelRecipeOrPinForParseObject:parseRecipeOrPin];
                                            }];
                                            
                                           [pageRecipes setObject:recipesOrPins forKey:page];
                                            
                                        }];
                                        
                                        // Wrap parse objects into our model.
                                        NSMutableDictionary *pagePhotos = [NSMutableDictionary dictionary];
                                        [parsePagePhotos each:^(NSString *page, PFObject *parseRecipeOrPin) {
                                            [pagePhotos setObject:[self modelRecipeOrPinForParseObject:parseRecipeOrPin]
                                                           forKey:page];
                                        }];
                                        
                                        
                                        success(parseBook, pageRecipes, pageBatches, pageRecipeCount, pageRankings,
                                                pagePhotos, accessDate);
                                        
                                    } else {
                                        DLog(@"Error loading recipes: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

- (void)recipesForPage:(NSString *)page batchIndex:(NSInteger)batchIndex success:(PageRecipesSuccessBlock)success
               failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"pageRecipes_v1_4"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{
                                        @"bookId" : self.objectId,
                                        @"userId" : self.user.objectId,
                                        @"page" : page,
                                        @"batchIndex" : @(batchIndex)
                                        }]
                                block:^(NSDictionary *recipeResults, NSError *error) {
                                    
                                    if (!error) {
                                        
                                        PFObject *parseBook = [recipeResults objectForKey:@"book"];
                                        NSArray *parseRecipesOrPins = [recipeResults objectForKey:@"recipes"];
                                        NSInteger batchIndex = [[recipeResults objectForKey:@"batchIndex"] integerValue];
                                        NSString *page = [recipeResults objectForKey:@"page"];
                                        
                                        // Wrap the recipes or pins in our model.
                                        NSArray *recipesOrPins = [parseRecipesOrPins collect:^id(PFObject *parseRecipeOrPin) {
                                            return [self modelRecipeOrPinForParseObject:parseRecipeOrPin];
                                        }];
                                    
                                        DLog(@"Loaded more recipes[%ld] for page[%@] batchIndex[%ld]", (long)[recipesOrPins count], page, (long)batchIndex);
                                        success([CKBook bookWithParseObject:parseBook], page, batchIndex, recipesOrPins);
                                        
                                    } else {
                                        DLog(@"Error loading recipes: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

- (void)likedRecipesForBatchIndex:(NSInteger)requestedBatchIndex success:(LikedRecipesSuccessBlock)success
               failure:(ObjectFailureBlock)failure {
    
    [PFCloud callFunctionInBackground:@"likedRecipes_v1_4"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{
                                        @"bookId" : self.objectId,
                                        @"userId" : self.user.objectId,
                                        @"batchIndex" : @(requestedBatchIndex)
                                        }]
                                block:^(NSDictionary *recipeResults, NSError *error) {
                                    
                                    if (!error) {
                                        
                                        PFObject *parseBook = [recipeResults objectForKey:@"book"];
                                        NSArray *parseRecipesOrPins = [recipeResults objectForKey:@"recipes"];
                                        NSInteger batchIndex = [[recipeResults objectForKey:@"batchIndex"] integerValue];
                                        
                                        // Wrap the recipes or pins in our model.
                                        NSArray *likedRecipes = [parseRecipesOrPins collect:^id(PFObject *parseRecipeOrPin) {
                                            return [self modelRecipeOrPinForParseObject:parseRecipeOrPin];
                                        }];
                                        
                                        DLog(@"Loaded more recipes[%ld] for batchIndex[%ld]", (long)[likedRecipes count], (long)batchIndex);
                                        success([CKBook bookWithParseObject:parseBook], batchIndex, likedRecipes);
                                        
                                    } else {
                                        DLog(@"Error loading recipes: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

- (void)numRecipesSuccess:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *query = [PFQuery queryWithClassName:kRecipeModelName];
    [query setCachePolicy:kPFCachePolicyNetworkElseCache];
    [query whereKey:kBookModelForeignKeyName equalTo:self.parseObject];
    [query countObjectsInBackgroundWithBlock:^(int num, NSError *error) {
        if (!error) {
            success(num);
        } else {
            failure(error);
        }
    }];
}

- (CKRecipe *)titleRecipe {
    if (!_titleRecipe) {
        PFObject *parseRecipe = [self.parseObject objectForKey:kBookAttrTitleRecipe];
        if (parseRecipe) {
            _titleRecipe = [[CKRecipe alloc] initWithParseObject:parseRecipe];
        }
    }
    return _titleRecipe;
}

- (void)setTitleRecipe:(CKRecipe *)titleRecipe {
    if (titleRecipe) {
        [self.parseObject setObject:titleRecipe.parseObject forKey:kBookAttrTitleRecipe];
    } else {
        [self.parseObject removeObjectForKey:kBookAttrTitleRecipe];
    }
}

- (BOOL)hasRemoteImage {
    BOOL hasRemoteImage = NO;
    BOOL retina = [[AppHelper sharedInstance] isRetina];
    
    if (retina) {
        
        hasRemoteImage = (self.illustrationImageFile != nil);
        
    } else {
        
        // Fallsback on retina.
        hasRemoteImage = (self.illustrationLowImageFile != nil) || (self.illustrationImageFile != nil);
        
    }
    
    return hasRemoteImage;
}

- (NSURL *)remoteImageUrl {
    BOOL retina = [[AppHelper sharedInstance] isRetina];
    NSString *urlString = nil;
    if (retina) {
        
        urlString = self.illustrationImageFile.url;
        
    } else {
        
        // Fallsback on retina.
        urlString = (self.illustrationLowImageFile == nil) ? self.illustrationImageFile.url : self.illustrationLowImageFile.url;
        
    }
    return [NSURL URLWithString:urlString];
}

- (BOOL)disabled {
    return [[self.parseObject objectForKey:kBookAttrDisabled] boolValue];
}

- (BOOL)captionLocalised {
    return ([[self localisedValueForKey:@"caption"] length] > 0);
}

- (BOOL)titleLocalised {
    return ([[self localisedValueForKey:@"title"] length] > 0);
}

- (BOOL)summaryLocalised {
    return ([[self localisedValueForKey:@"summary"] length] > 0);
}

#pragma mark - Searches

+ (void)searchBooksByKeyword:(NSString *)keyword success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    DLog(@"keyword[%@]", keyword);
   
    NSString *searchTerm = [keyword CK_whitespaceTrimmed];
    if ([searchTerm length] < 2) {
        failure(nil);
        return;
    }
    
    DLog(@"searching keyword[%@]", searchTerm);
    [PFCloud callFunctionInBackground:@"storeSearchBooks"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{ @"keyword" : searchTerm }]
                                block:^(NSDictionary *results, NSError *error) {                                    
                                    if (error) {
                                        failure(error);
                                    } else {
                                        [self processStoreBooksFromResults:results success:success failure:failure];
                                    }
                                }];
}

- (NSString *)userName {
    
    if (self.titleLocalised) {
        
        return [self localisedValueForKey:@"title"];
        
    } else {
        
        NSString *author = self.author;
        if ([author length] > 0) {
            return author;
        } else {
            return self.user.name;
        }
    }
}

- (BOOL)editable {
    return (!self.guest && [self.user.objectId isEqualToString:[CKUser currentUser].objectId]);
}

- (void)addFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFObject *follow = [CKModel objectWithDefaultSecurityWithClassName:kUserBookFollowModelName];
    [follow setObject:user.parseUser forKey:kUserModelForeignKeyName];
    [follow setObject:self.parseObject forKey:kBookModelForeignKeyName];
    [follow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            success();
        } else {
            DLog(@"Error loading books: %@", [error localizedDescription]);
            failure(error);
        }
    }];
}

- (void)removeFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *follow = [PFQuery queryWithClassName:kUserBookFollowModelName];
    [follow whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [follow whereKey:kBookModelForeignKeyName equalTo:self.parseObject];
    [follow getFirstObjectInBackgroundWithBlock:^(PFObject *parseFollow, NSError *error) {
        if (!error) {
            [parseFollow deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    success();
                } else {
                    DLog(@"Error loading follows: %@", [error localizedDescription]);
                    failure(error);
                }
            }];
        } else {
            DLog(@"Error loading follows: %@", [error localizedDescription]);
            failure(error);
        }
    }];
    
}

- (void)isFollowedByUser:(CKUser *)user success:(BoolObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    PFQuery *follow = [PFQuery queryWithClassName:kUserBookFollowModelName];
    [follow whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [follow whereKey:kBookModelForeignKeyName equalTo:self.parseObject];
    [follow countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            success([[NSNumber numberWithInt:number] boolValue]);
        } else {
            failure(error);
        }
    }];
}

- (void)deletePage:(NSString *)page success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    if (![page CK_containsText]) {
        failure(nil);
    }
    
    [PFCloud callFunctionInBackground:@"bookDeletePage"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{ @"bookId" : self.objectId, @"page" : page }]
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        DLog(@"Deleted page from book and its associated recipes");
                                        
                                        // Remove page from the local book.
                                        NSArray *pages = self.pages;
                                        self.pages = [pages reject:^BOOL(NSString *existingPage) {
                                            return [existingPage CK_equalsIgnoreCase:page];
                                        }];
                                        
                                        success();
                                    } else {
                                        DLog(@"Error deleting page: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

- (void)renamePage:(NSString *)page toPage:(NSString *)toPage success:(ObjectSuccessBlock)success
           failure:(ObjectFailureBlock)failure {
    
    DLog(@"page [%@] toPage [%@]", [page CK_containsText] ? @"YES" : @"NO", [toPage CK_containsText] ? @"YES" : @"NO");
    if (![page CK_containsText] || ![toPage CK_containsText]) {
        failure(nil);
        return;
    }
    
    [PFCloud callFunctionInBackground:@"bookRenamePage"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{ @"bookId" : self.objectId, @"fromPage" : page, @"toPage" : toPage }]
                                block:^(id result, NSError *error) {
                                    if (!error) {
                                        DLog(@"Renamed page for book and its associated recipes");
                                        
                                        // Replace page in book.
                                        NSMutableArray *pages = [NSMutableArray arrayWithArray:self.pages];
                                        NSUInteger pageIndex = [self.pages indexOfObject:page];
                                        [pages replaceObjectAtIndex:pageIndex withObject:toPage];
                                        self.pages = pages;
                                        
                                        success();
                                        
                                    } else {
                                        DLog(@"Error renaming page: %@", [error localizedDescription]);
                                        failure(error);
                                    }
                                }];
}

- (void)bookInfoCompletion:(BookInfoSuccessBlock)completion failure:(ObjectFailureBlock)failure; {
    [PFCloud callFunctionInBackground:@"bookInfo"
                       withParameters:[CloudCodeHelper commonCloudCodeParamsWithExtraParams:@{ @"bookId" : self.objectId, @"userId" : self.user.objectId }]
                                block:^(NSDictionary *results, NSError *error) {
                                    
                                    NSUInteger followCount = [[results objectForKey:@"followCount"] unsignedIntegerValue];
                                    BOOL areFriends = [[results objectForKey:@"friends"] boolValue];
                                    BOOL followed = [[results objectForKey:@"followed"] boolValue];
                                    NSUInteger recipeCount = [[results objectForKey:@"recipeCount"] unsignedIntegerValue];
                                    NSUInteger privateRecipesCount = [[results objectForKey:@"privateRecipesCount"] unsignedIntegerValue];
                                    NSUInteger friendsRecipesCount = [[results objectForKey:@"friendsRecipesCount"] unsignedIntegerValue];
                                    NSUInteger publicRecipesCount = [[results objectForKey:@"publicRecipesCount"] unsignedIntegerValue];
                                    
                                    if (!error) {
                                        completion(followCount, areFriends, followed, recipeCount, privateRecipesCount,
                                                   friendsRecipesCount, publicRecipesCount);
                                    } else {
                                        DLog(@"Error loading book info: %@", [error localizedDescription]);
                                    }
                                }];
    
}

- (void)saveWithImage:(UIImage *)image completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    if (image) {
        DLog(@"Saving book with image.");
        [[CKPhotoManager sharedInstance] addImage:image book:self];
    } else {
        DLog(@"Saving book without image.");
        [self saveInBackground];
    }
}

- (BOOL)isThisMyFriendsBook {
    NSString *userId = [self.user facebookId];
    CKUser *currentUser = [CKUser currentUser];
    NSArray *facebookFriendIds = [currentUser.parseUser objectForKey:kUserAttrFacebookFriends];
    return [facebookFriendIds containsObject:userId];
}

- (BOOL)isOwner {
    return [self isUserBookAuthor:[CKUser currentUser]];
}

- (BOOL)isOwner:(CKUser *)user {
    return [self isUserBookAuthor:user];
}

- (BOOL)isUserBookAuthor:(CKUser *)user {
    return [self.user isEqual:user];
}

- (BOOL)isPublic {
    // Featured books are public.
    return self.featured;
}

- (BOOL)hasCoverPhoto {
    return (self.coverPhotoFile != nil);
}

- (BOOL)localisedForPage:(NSString *)page {
    if (!self.localised) {
        return NO;
    }
    
    BOOL localisedForPage = NO;
    
    NSDictionary *keyFormats = [self.localisationFormats objectForKey:@"pages"];
    
    if ([keyFormats count] > 0) {
        NSArray *pages = nil;
        id keysObj = [keyFormats objectForKey:@"keys"];
        if ([keysObj isKindOfClass:[NSArray class]]) {
            pages = (NSArray *)keysObj;
            localisedForPage = [pages containsObject:page];
        }
    }
    
    return localisedForPage;
}

- (void)setCoverPhotoFile:(PFFile *)coverPhotoFile {
    if (coverPhotoFile) {
        [self.parseObject setObject:coverPhotoFile forKey:kBookAttrCoverPhoto];
    } else {
        [self.parseObject removeObjectForKey:kBookAttrCoverPhoto];
    }
}

- (PFFile *)coverPhotoFile {
    return [self.parseObject objectForKey:kBookAttrCoverPhoto];
}

- (void)setCoverPhotoThumbFile:(PFFile *)coverPhotoThumbFile {
    if (coverPhotoThumbFile) {
        [self.parseObject setObject:coverPhotoThumbFile forKey:kBookAttrCoverPhotoThumb];
    } else {
        [self.parseObject removeObjectForKey:kBookAttrCoverPhotoThumb];
    }
}

- (PFFile *)coverPhotoThumbFile {
    return [self.parseObject objectForKey:kBookAttrCoverPhotoThumb];
}

- (void)setIllustrationImageFile:(PFFile *)illustrationImageFile {
    if (illustrationImageFile) {
        [self.parseObject setObject:illustrationImageFile forKey:kBookAttrIllustrationImage];
    } else {
        [self.parseObject removeObjectForKey:kBookAttrIllustrationImage];
    }
}

- (PFFile *)illustrationImageFile {
    return [self.parseObject objectForKey:kBookAttrIllustrationImage];
}

- (void)setIllustrationLowImageFile:(PFFile *)illustrationLowImageFile {
    if (illustrationLowImageFile) {
        [self.parseObject setObject:illustrationLowImageFile forKey:kBookAttrIllustrationLowImage];
    } else {
        [self.parseObject removeObjectForKey:kBookAttrIllustrationLowImage];
    }
}

- (PFFile *)illustrationLowImageFile {
    return [self.parseObject objectForKey:kBookAttrIllustrationLowImage];
}

#pragma mark - CKModel

- (void)saveInBackground:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure {
    [self.parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // If it is my own book, refresh the cache by forcing an own book load.
            if ([self isOwner]) {
                
                // Pre-cache
                PFQuery *query = [PFQuery queryWithClassName:kBookModelName];
                [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
                [query whereKey:kUserModelForeignKeyName equalTo:self.user.parseObject];
                [query includeKey:kUserModelForeignKeyName];
                [query findObjectsInBackgroundWithBlock:^(NSArray *parseResults, NSError *error) {
                    
                    // Ignore, only for pre-caching purposes.
                    DLog(@"Pre-cached own book.");
                }];
            }
            
            success();
            
        } else {
            failure(error);
        }
    }];
}

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:self.cover] forKey:kBookAttrCover];
    [descriptionProperties setValue:[NSString CK_safeString:self.illustration] forKey:kBookAttrIllustration];
    [descriptionProperties setValue:[NSString CK_stringForBoolean:self.featured] forKey:kBookAttrFeatured];
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

+ (void)annotateFollowedBooks:(NSArray *)parseBooks followedBookIds:(NSArray *)followedBookIds
                      success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
    success([parseBooks collect:^id(PFObject *parseBook) {
        CKBook *book = [[CKBook alloc] initWithParseObject:parseBook];
        book.status = [followedBookIds containsObject:book.objectId] ? kBookStatusFollowed : kBookStatusNone;
        return book;
    }]);
}

+ (void)annotateFollowedBooks:(NSArray *)parseBooks user:(CKUser *)user success:(ListObjectsSuccessBlock)success
                      failure:(ObjectFailureBlock)failure {
    
    // Existing follows.
    PFQuery *followsQuery = [PFQuery queryWithClassName:kUserBookFollowModelName];
    [followsQuery whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [followsQuery findObjectsInBackgroundWithBlock:^(NSArray *parseFollows, NSError *error)  {
        
        if (!error) {
            
            // Collect the object ids.
            NSArray *objectIds = [parseFollows collect:^id(PFObject *parseFollow) {
                PFObject *parseBook = [parseFollow objectForKey:kBookModelForeignKeyName];
                return parseBook.objectId;
            }];
            
            // Return CKBook model objects.
            NSArray *books = [parseBooks collect:^id(PFObject *parseBook) {
                CKBook *book = [[CKBook alloc] initWithParseObject:parseBook];
                book.status = [objectIds containsObject:book.objectId] ? kBookStatusFollowed : kBookStatusNone;
                return book;
            }];
            
            success(books);
            
        } else {
            
            DLog(@"Error filtering friends books by follows: %@", [error localizedDescription]);
            failure(error);
        }
        
        
    }];
}

+ (void)annotateForFriendsBooks:(NSArray *)parseFriendsBooks suggestedBooks:(NSArray *)parseSuggestedBooks
                           user:(CKUser *)user followedBookIds:(NSArray *)followedBookIds
                        success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure {
    
        // Annotate. friends books with follow indicators.
        NSArray *friendsBooks = [parseFriendsBooks collect:^id(PFObject *parseBook) {
            CKBook *book = [[CKBook alloc] initWithParseObject:parseBook];
            
            // Book followed?
            BOOL isFollowed = [followedBookIds containsObject:book.objectId];
            if (isFollowed) {
                book.status = kBookStatusFollowed;
            } else {
                book.status = kBookStatusNone;
            }
            
            return book;
        }];
        
        // Annotate. friends books with follow indicators.
        NSArray *suggestedBooks = [parseSuggestedBooks collect:^id(PFObject *parseBook) {
            CKBook *book = [[CKBook alloc] initWithParseObject:parseBook];
            
            // Book followed?
            BOOL isFollowed = [followedBookIds containsObject:book.objectId];
            if (isFollowed) {
                book.status = kBookStatusFollowed;
            } else {
                book.status = kBookStatusFBSuggested;
            }
            
            return book;
        }];
        
        // Results
        NSMutableArray *combinedBooks = [NSMutableArray new];
        if ([friendsBooks count] > 0) {
            [combinedBooks addObjectsFromArray:friendsBooks];
        }
        if ([suggestedBooks count] > 0) {
            [combinedBooks addObjectsFromArray:suggestedBooks];
        }
        success(combinedBooks);
        
}

+ (void)filterFollowedBooks:(NSArray *)parseBooks user:(CKUser *)user success:(ListObjectsSuccessBlock)success
                    failure:(ObjectFailureBlock)failure {
    
    // Existing follows.
    PFQuery *followsQuery = [PFQuery queryWithClassName:kUserBookFollowModelName];
    [followsQuery whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [followsQuery findObjectsInBackgroundWithBlock:^(NSArray *parseFollows, NSError *error)  {
        
        if (!error) {
            
            // Collect the object ids.
            NSArray *objectIds = [parseFollows collect:^id(PFObject *parseFollow) {
                PFObject *parseBook = [parseFollow objectForKey:kBookModelForeignKeyName];
                return parseBook.objectId;
            }];
            
            // Filter out the books that are not followed.
            NSArray *filteredParsebooks = [parseBooks reject:^BOOL(PFObject *parseBook) {
                return [objectIds containsObject:parseBook.objectId];
            }];
            
            // Return CKBook model objects.
            NSArray *books = [filteredParsebooks collect:^id(PFObject *parseBook) {
                return [[CKBook alloc] initWithParseObject:parseBook];
            }];
            
            success(books);
            
        } else {
            
            DLog(@"Error filtering friends books by follows: %@", [error localizedDescription]);
            failure(error);
        }
        
        
    }];
}

+ (void)filterFriendsBooks:(NSArray *)parseBooks user:(CKUser *)user success:(ListObjectsSuccessBlock)success
                   failure:(ObjectFailureBlock)failure {
    
    // Existing friends.
    PFQuery *friendsQuery = [PFQuery queryWithClassName:kUserFriendModelName];
    [friendsQuery whereKey:kUserModelForeignKeyName equalTo:user.parseUser];
    [friendsQuery whereKey:kUserFriendAttrConnected equalTo:@YES];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *parseFriends, NSError *error)  {
        
        if (!error) {
            
            // Collect the object ids of friends.
            NSArray *objectIds = [parseFriends collect:^id(PFObject *parseFriend) {
                PFUser *parseFriendUser = [parseFriend objectForKey:kUserFriendFriend];
                return parseFriendUser.objectId;
            }];
            
            // Filter out the books that are not followed.
            NSArray *filteredParsebooks = [parseBooks reject:^BOOL(PFObject *parseBook) {
                PFUser *parseUser = [parseBook objectForKey:kUserModelForeignKeyName];
                return [objectIds containsObject:parseUser.objectId];
            }];
            
            // Return CKBook model objects.
            NSArray *books = [filteredParsebooks collect:^id(PFObject *parseBook) {
                return [[CKBook alloc] initWithParseObject:parseBook];
            }];
            
            success(books);
            
        } else {
            
            DLog(@"Error filtering friends books by follows: %@", [error localizedDescription]);
            failure(error);
        }
        
        
    }];
}

+ (NSArray *)booksFromParseBooks:(NSArray *)parseBooks {
    return [parseBooks collect:^id(PFObject *parseBook) {
        return [[CKBook alloc] initWithParseObject:parseBook];
    }];
}

+ (void)processStoreBooksFromResults:(NSDictionary *)results success:(ListObjectsSuccessBlock)success
                             failure:(ObjectFailureBlock) failure {
    
    NSArray *parseBooks = [results objectForKey:@"books"];
    NSArray *followedBookIds = [results objectForKey:@"followedBookIds"];
    
    [self annotateFollowedBooks:parseBooks
                followedBookIds:followedBookIds
                        success:^(NSArray *annotatedBooks) {
                            success(annotatedBooks);
                        } failure:^(NSError *error) {
                            failure(error);
                        }];
}

- (CKModel *)modelRecipeOrPinForParseObject:(PFObject *)parseRecipeOrPin {
    PFObject *parseRecipe = parseRecipeOrPin;
    PFUser *parseUser = [parseRecipeOrPin objectForKey:kUserModelForeignKeyName];
    
    if ([parseRecipeOrPin.parseClassName isEqualToString:kRecipePinModelName]) {
        parseRecipe = [parseRecipeOrPin objectForKey:kRecipeModelForeignKeyName];
        parseUser = [parseRecipe objectForKey:kUserModelForeignKeyName];
        
        CKRecipe *recipe = [CKRecipe recipeForParseRecipe:parseRecipe
                                                     user:[CKUser userWithParseUser:parseUser]
                                                     book:self];
        CKRecipePin *recipePin = [[CKRecipePin alloc] initWithParseObject:parseRecipeOrPin];
        recipePin.recipe = recipe;
        return recipePin;
        
    } else {
        
        // User will be populated for non-owned recipes, like pins.
        if (parseUser && ![parseUser.objectId isEqualToString:self.user.objectId]) {
            
            return [CKRecipe recipeForParseRecipe:parseRecipe
                                             user:[CKUser userWithParseUser:parseUser]
                                             book:self];
        } else {
            
            // Otherwise these are my recipes.
            return [CKRecipe recipeForParseRecipe:parseRecipe user:self.user book:self];
        }
    }
}

@end
