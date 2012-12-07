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

@interface CKRecipe : CKModel

@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign, readonly) NSUInteger likes;
@property (nonatomic, assign) CGPoint recipeViewImageContentOffset;
@property (nonatomic, strong) NSArray *ingredients;
@property (nonatomic, assign) float cookingTimeInSeconds;
@property (nonatomic, assign) int numServes;

@property(nonatomic,strong) Category *category;

//creation
+(CKRecipe*) recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user;
+(CKRecipe*) recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user book:(CKBook *)book;
+(CKRecipe*) recipeForUser:(CKUser *)user book:(CKBook *)book category:(Category *)category;

//save
-(void) saveAndUploadImageWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure imageUploadProgress:(ProgressBlock)imageUploadProgress;
-(void) saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;

//fetch
+(void) fetchImagesForRecipe:(CKRecipe*)recipe success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
-(void) fetchCategoryNameWithSuccess:(GetObjectSuccessBlock)getObjectSuccess;

-(void) setImage:(UIImage *)image;
-(PFFile*) imageFile;
@end
