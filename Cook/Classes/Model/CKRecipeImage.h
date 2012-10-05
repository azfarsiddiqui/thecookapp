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

+(CKRecipeImage *) recipeImageForParseRecipeImage:(PFObject *)parseRecipeImage;
+(CKRecipeImage*) recipeImageForImage:(UIImage *)image imageName:(NSString *)imageName;

-(PFFile *)imageFile;

@end
