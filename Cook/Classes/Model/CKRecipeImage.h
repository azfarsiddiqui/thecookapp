//
//  CKRecipeImage.h
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"
#import "CKRecipeImage.h"

@interface CKRecipeImage : CKModel

@property (nonatomic, strong) PFFile *imageFile;
@property (nonatomic, strong) PFFile *thumbImageFile;

// UUIDs for images that are being uploaded, doesn't get persisted to Parse.
@property (nonatomic, strong) NSString *imageUuid;
@property (nonatomic, strong) NSString *thumbImageUuid;

+ (CKRecipeImage *)recipeImage;
+ (CKRecipeImage *)recipeImageForParseRecipeImage:(PFObject *)parseRecipeImage;
+ (CKRecipeImage *)recipeImageForImage:(UIImage *)image imageName:(NSString *)imageName;

@end
