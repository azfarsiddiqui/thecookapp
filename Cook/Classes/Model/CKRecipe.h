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
#import "Category.h"

@class CKRecipeImage;

@interface CKRecipe : CKModel

@property (nonatomic, strong) NSString *story;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign, readonly) NSUInteger likes;
@property (nonatomic, assign) CGPoint recipeViewImageContentOffset;
@property (nonatomic, strong) NSArray *ingredients;
@property (nonatomic, assign) NSInteger cookingTimeInMinutes;
@property (nonatomic, assign) NSInteger prepTimeInMinutes;
@property (nonatomic, assign) NSInteger numServes;

@property(nonatomic,strong) CKUser *user;
@property(nonatomic,strong) Category *category;
@property(nonatomic,strong) CKRecipeImage *recipeImage;

//creation
+(CKRecipe*) recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user;
+(CKRecipe*) recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user book:(CKBook *)book;
+(CKRecipe*) recipeForUser:(CKUser *)user book:(CKBook *)book;
+(CKRecipe*) recipeForUser:(CKUser *)user book:(CKBook *)book category:(Category *)category;

//save
-(void) saveAndUploadImageWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure imageUploadProgress:(ProgressBlock)imageUploadProgress;
-(void) saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

//fetch
-(void) fetchCategoryNameWithSuccess:(GetObjectSuccessBlock)getObjectSuccess;

-(void) setImage:(UIImage *)image;
-(PFFile*) imageFile;
- (BOOL)hasPhotos;
-(BOOL) isUserRecipeAuthor:(CKUser*)user;

@end
