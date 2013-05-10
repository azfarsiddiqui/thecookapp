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
#import "CKCategory.h"

@class CKRecipeImage;

@interface CKRecipe : CKModel

@property(nonatomic, strong) CKBook *book;
@property(nonatomic, strong) CKUser *user;

@property (nonatomic, assign) BOOL privacy;
@property(nonatomic, strong) CKCategory *category;
@property (nonatomic, strong) NSString *story;
@property (nonatomic, strong) NSString *method;

@property (nonatomic, assign) NSInteger numServes;
@property (nonatomic, assign) NSInteger prepTimeInMinutes;
@property (nonatomic, assign) NSInteger cookingTimeInMinutes;

@property (nonatomic, assign, readonly) NSUInteger likes;
@property (nonatomic, assign) CGPoint recipeViewImageContentOffset;
@property (nonatomic, strong) NSMutableArray *ingredients;

@property(nonatomic, strong) CKRecipeImage *recipeImage;

// Creation
+ (CKRecipe *)recipeForBook:(CKBook *)book;
+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user;
+ (CKRecipe *)recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user book:(CKBook *)book;
+ (CKRecipe *)recipeForUser:(CKUser *)user book:(CKBook *)book;
+ (CKRecipe *)recipeForUser:(CKUser *)user book:(CKBook *)book category:(CKCategory *)category;

// Save
- (void)saveWithImage:(UIImage *)image uploadProgress:(ProgressBlock)progress completion:(ObjectSuccessBlock)success
              failure:(ObjectFailureBlock)failure;
- (void)saveAndUploadImageWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure imageUploadProgress:(ProgressBlock)imageUploadProgress;
- (void)saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

// Fetch
- (void)fetchCategoryNameWithSuccess:(GetObjectSuccessBlock)getObjectSuccess;

- (void)setImage:(UIImage *)image;
- (PFFile *)imageFile;
- (BOOL)hasPhotos;
- (BOOL)isUserRecipeAuthor:(CKUser*)user;

@end
