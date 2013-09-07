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

typedef void(^BookRecipesSuccessBlock)(NSArray *recipes, NSDate *bookLastAccessedDate, NSDictionary *pageFeaturedRecipes, NSString *bookFeaturedRecipeId);
typedef void(^BenchtopBooksSuccessBlock)(CKBook *myBook, NSArray *friendsBooks);

@interface CKBook : CKModel

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
@property (nonatomic, assign) BOOL followed;
@property (nonatomic, assign) BOOL guest;

// Cover photos.
@property (nonatomic, strong) PFFile *coverPhotoFile;
@property (nonatomic, strong) PFFile *coverPhotoThumbFile;

// Fetches
+ (void)fetchBookForUser:(CKUser *)user success:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)fetchGuestBookSuccess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)fetchFollowBooksSuccess:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)fetchRecipesSuccess:(BookRecipesSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)numRecipesSuccess:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Persistence
+ (void)createBookForUser:(CKUser *)user succeess:(GetObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)followBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)friendsBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)suggestedBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
+ (void)featuredBooksForUser:(CKUser *)user success:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)addFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)removeFollower:(CKUser *)user success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)isFollowedByUser:(CKUser *)user success:(BoolObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)deletePage:(NSString *)page success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Saves.
- (void)saveWithImage:(UIImage *)image completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Parse operations
+ (PFObject *)createParseBookForParseUser:(PFUser *)parseUser;
+ (PFObject *)createParseBook;

- (id)initWithParseBook:(PFObject *)parseBook user:(CKUser *)user;
- (NSString *)userName;
- (BOOL)editable;
- (BOOL)isThisMyFriendsBook;
- (BOOL)isOwner;
- (BOOL)isUserBookAuthor:(CKUser*)user;
- (BOOL)isPublic;
- (BOOL)hasCoverPhoto;

@end
