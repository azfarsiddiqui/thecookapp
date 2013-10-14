//
//  CKRecipe.h
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"
#import "CKUser.h"
#import "CKBook.h"

typedef NS_ENUM(NSUInteger, CKPrivacy) {
    CKPrivacyPrivate,
    CKPrivacyFriends,
    CKPrivacyGlobal
};

@class CKRecipeImage;
@class CKLocation;

typedef void(^RecipeCommentsLikesSuccessBlock)(NSArray *comments, NSArray *likes);

@interface CKRecipe : CKModel

@property(nonatomic, strong) CKBook *book;
@property(nonatomic, strong) CKUser *user;

@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSString *story;
@property (nonatomic, strong) NSString *method;

@property (nonatomic, assign) NSNumber *numServes;
@property (nonatomic, assign) NSNumber *prepTimeInMinutes;
@property (nonatomic, assign) NSNumber *cookingTimeInMinutes;

@property (nonatomic, assign, readonly) NSUInteger likes;
@property (nonatomic, assign) CGPoint recipeViewImageContentOffset;
@property (nonatomic, strong) NSArray *ingredients;

@property (nonatomic, assign) CKPrivacy privacy;
@property(nonatomic, strong) CKLocation *geoLocation;

@property(nonatomic, strong) CKRecipeImage *recipeImage;

@property (nonatomic, assign, readonly) NSInteger numViews;
@property (nonatomic, assign, readonly) NSInteger numLikes;
@property (nonatomic, assign, readonly) NSInteger numComments;

// Max serves/prep/cook.
+ (NSInteger)maxServes;
+ (NSInteger)maxPrepTimeInMinutes;
+ (NSInteger)maxCookTimeInMinutes;

// Creation
+ (CKRecipe *)recipeForBook:(CKBook *)book;
+ (CKRecipe *)recipeForBook:(CKBook *)book page:(NSString *)page;
+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user;
+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user book:(CKBook *)book;
+ (CKRecipe *)recipeForUser:(CKUser *)user book:(CKBook *)book;

// Query.
+ (void)recipeForObjectId:(NSString *)objectId success:(GetObjectSuccessBlock)success
                  failure:(ObjectFailureBlock)failure;

// Save
- (void)saveWithImage:(UIImage *)image startProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress
             progress:(ProgressBlock)progress completion:(ObjectSuccessBlock)success
              failure:(ObjectFailureBlock)failure;

// Likes
- (void)like:(BOOL)like user:(CKUser *)user completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)likedByUser:(CKUser *)user completion:(BoolObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)numLikesWithCompletion:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Comments
- (void)comment:(NSString *)comment user:(CKUser *)user completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)numCommentsWithCompletion:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)commentsWithCompletion:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)commentsLikesWithCompletion:(RecipeCommentsLikesSuccessBlock)success failure:(ObjectFailureBlock)failure;

- (void)setImage:(UIImage *)image;
- (PFFile *)imageFile;
- (BOOL)isOwner;
- (BOOL)isUserRecipeAuthor:(CKUser*)user;
- (BOOL)shareable;

// Clear location.
- (void)clearLocation;

// Data existence methods
- (BOOL)hasPhotos;
- (BOOL)hasTitle;
- (BOOL)hasStory;
- (BOOL)hasMethod;
- (BOOL)hasIngredients;

// Stats.
- (void)incrementPageViewInBackground;

- (NSURL *)userPhotoUrl;

@end
