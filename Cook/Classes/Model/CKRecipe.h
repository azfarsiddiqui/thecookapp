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
@property (nonatomic, strong) UIImage *image;

+(void) imagesForRecipe:(CKRecipe*)recipe success:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure;
+(CKRecipe*) recipeForParseRecipe:(PFObject *)parseRecipe user:(CKUser *)user;
+(CKRecipe*) recipeForUser:(CKUser *)user book:(CKBook *)book category:(Category *)category;

-(PFFile*) imageFile;
-(void) categoryNameWithSuccess:(GetObjectSuccessBlock)getObjectSuccess;
-(void) saveWithSuccess:(ObjectSuccessBlock)success failure:(ObjectFailureBlock)failure progress:(ProgressBlock)progress;
@end
