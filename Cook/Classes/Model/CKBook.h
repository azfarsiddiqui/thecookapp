//
//  CKBook.h
//  Cook
//
//  Created by Jeff Tan-Ang on 2/10/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Parse/Parse.h>
#import "CKModel.h"
#import "CKUser.h"

@class CKBook;
@class CKCategory;
@class CKRecipe;

typedef void(^BookRecipesSuccessBlock)(PFObject *parseBook, NSDictionary *pageRecipes, NSDictionary *pageBatches,
                                       NSDictionary *pageRecipeCount, NSDictionary *pageRankings,
                                       NSDictionary *pagePhotos, NSDate *bookLastAccessedDate);
typedef void(^PageRecipesSuccessBlock)(CKBook *book, NSString *page, NSInteger batchindex, NSArray *recipes);
typedef void(^LikedRecipesSuccessBlock)(CKBook *book, NSInteger batchindex, NSArray *recipes);
typedef void(^FollowBooksSuccessBlock)(NSArray *followBooks, NSDictionary *followBookUpdates);
typedef void(^DashboardBooksSuccessBlock)(CKBook *myBook, NSArray *followBooks, NSDictionary *followBookUpdates);
typedef void(^FriendsAndSuggestedBooksSuccessBlock)(NSArray *friendsBooks, NSArray *suggestedBooks);
typedef void(^BookInfoSuccessBlock)(NSUInteger followCount, BOOL areFriends, BOOL followed, NSUInteger recipeCount,
                                    NSUInteger privateRecipesCount, NSUInteger friendsRecipesCount,
                                    NSUInteger publicRecipesCount);

typedef enum {
    kBookStatusNone,
    kBookStatusFollowed,
    kBookStatusFBSuggested
} BookStatus;

@interface CKBook : CKModel

#define kHasSeenProfileHintKey @"hasSeenProfileHint"

@property (nonatomic, strong) CKUser *user;

@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *illustration;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *story;
@property (nonatomic, assign) NSInteger numRecipes;
@property (nonatomic, strong) NSArray *pages;
@property (nonatomic, strong) NSArray *currentCategories;
@property (nonatomic, assign) BOOL featured;
@property (nonatomic, assign) BOOL showLikes;
@property (nonatomic, assign) BookStatus status;
@property (nonatomic, assign) BOOL guest;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, strong) CKRecipe *titleRecipe;
@property (nonatomic, readonly) BOOL captionLocalised;
@property (nonatomic, readonly) BOOL titleLocalised;
@property (nonatomic, readonly) BOOL summaryLocalised;

// Cover photos.
@property (nonatomic, strong) PFFile *coverPhotoFile;
@property (nonatomic, strong) PFFile *coverPhotoThumbFile;

// Custom Illustration image.
@property (nonatomic, strong) PFFile *illustrationImageFile;
@property (nonatomic, strong) PFFile *illustrationLowImageFile;

// Fetches
+ (void)bookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)dashboardBookForUser:(CKUser *)user success:(GetCachedObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)dashboardGuestBookSuccess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)dashboardBooksForUser:(CKUser *)user success:(DashboardBooksSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)dashboardFollowBooksSuccess:(FollowBooksSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (BOOL)dashboardBookLoadCacheMissError:(NSError *)error;

- (void)bookRecipesSuccess:(BookRecipesSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)recipesForPage:(NSString *)page batchIndex:(NSInteger)batchIndex success:(PageRecipesSuccessBlock)success
               failure:(ObjectFailureBlock)failure;
- (void)likedRecipesForBatchIndex:(NSInteger)batchIndex success:(LikedRecipesSuccessBlock)success
                          failure:(ObjectFailureBlock)failure;
- (void)numRecipesSuccess:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

- (BOOL)hasRemoteImage;
- (NSURL *)remoteImageUrl;

// Searches
+ (void)searchBooksByKeyword:(NSString *)keyword success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Store
+ (void)categoriesBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)featuredBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)worldBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)friendsAndSuggestedBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Persistence
+ (void)createBookForUser:(CKUser *)user succeess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)followBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)friendsBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)facebookSuggestedBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)facebookSuggestedBooksForFacebookIds:(NSArray *)facebookIds success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

- (void)addFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)removeFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)isFollowedByUser:(CKUser *)user success:(BoolObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)deletePage:(NSString *)page success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)renamePage:(NSString *)page toPage:(NSString *)toPage success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)bookInfoCompletion:(BookInfoSuccessBlock)completion failure:(ObjectFailureBlock)failure;

// Saves.
- (void)saveWithImage:(UIImage *)image completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Parse operations
+ (PFObject *)createParseBookForParseUser:(PFUser *)parseUser;
+ (PFObject *)createParseBook;
+ (CKBook *)bookWithParseObject:(PFObject *)parseObject;

- (id)initWithParseBook:(PFObject *)parseBook user:(CKUser *)user;
- (NSString *)userName;
- (BOOL)editable;
- (BOOL)isThisMyFriendsBook;
- (BOOL)isOwner;
- (BOOL)isOwner:(CKUser *)user;
- (BOOL)isUserBookAuthor:(CKUser*)user;
- (BOOL)isPublic;
- (BOOL)hasCoverPhoto;

@end
