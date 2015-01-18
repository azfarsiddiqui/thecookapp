//
//  CKRecipeImage.h
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"
#import "CKRecipeImage.h"

@class CKRecipe;

@interface CKRecipeImage : CKModel

@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) PFFile *thumbImageFile;

// UUIDs for images that are being uploaded, doesn't get persisted to Parse.
@property (nonatomic, strong) NSString *imageUuid;
@property (nonatomic, strong) NSString *thumbImageUuid;
@property (nonatomic, assign) NSInteger imageWidth;
@property (nonatomic, assign) NSInteger imageHeight;
@property (nonatomic, assign) CGFloat imageMemory;

+ (CKRecipeImage *)recipeImage;
+ (CKRecipeImage *)recipeImageForRecipe:(CKRecipe *)recipe;
+ (CKRecipeImage *)existingRecipeImageForRecipeObject:(PFObject *)recipeObject;
+ (CKRecipeImage *)recipeImageForParseRecipeImage:(PFObject *)parseRecipeImage;
+ (CKRecipeImage *)recipeImageForImage:(UIImage *)image imageName:(NSString *)imageName;

- (void)associateWithRecipe:(CKRecipe *)recipe;

@end
