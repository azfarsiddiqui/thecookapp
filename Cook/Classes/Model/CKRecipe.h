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

@class CKRecipeImage;

@interface CKRecipe : CKModel

@property(nonatomic, strong) CKBook *book;
@property(nonatomic, strong) CKUser *user;

@property (nonatomic, assign) BOOL privacy;
@property (nonatomic, strong) NSString *page;
@property (nonatomic, strong) NSString *story;
@property (nonatomic, strong) NSString *method;

@property (nonatomic, assign) NSInteger numServes;
@property (nonatomic, assign) NSInteger prepTimeInMinutes;
@property (nonatomic, assign) NSInteger cookingTimeInMinutes;

@property (nonatomic, assign, readonly) NSUInteger likes;
@property (nonatomic, assign) CGPoint recipeViewImageContentOffset;
@property (nonatomic, strong) NSArray *ingredients;

@property(nonatomic, strong) CKRecipeImage *recipeImage;

// Creation
+ (CKRecipe *)recipeForBook:(CKBook *)book;
+ (CKRecipe *)recipeForBook:(CKBook *)book page:(NSString *)page;
+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user;
+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user book:(CKBook *)book;
+ (CKRecipe *)recipeForUser:(CKUser *)user book:(CKBook *)book;

// Save
- (void)saveWithImage:(UIImage *)image uploadProgress:(ProgressBlock)progress completion:(ObjectSuccessBlock)success
              failure:(ObjectFailureBlock)failure;
- (void)saveWithImage:(UIImage *)image startProgress:(CGFloat)startProgress endProgress:(CGFloat)endProgress
             progress:(ProgressBlock)progress completion:(ObjectSuccessBlock)success
              failure:(ObjectFailureBlock)failure;
- (void)saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Likes
- (void)like:(BOOL)like user:(CKUser *)user completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)likedByUser:(CKUser *)user completion:(BoolObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)numLikesWithCompletion:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Comments
- (void)comment:(NSString *)comment user:(CKUser *)user completion:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)numCommentsWithCompletion:(NumObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
- (void)commentsWithCompletion:(ListObjectsSuccessBlock)success failure:(ObjectFailureBlock)failure;

- (void)setImage:(UIImage *)image;
- (PFFile *)imageFile;
- (BOOL)hasPhotos;
- (BOOL)isUserRecipeAuthor:(CKUser*)user;

@end
