//
//  CKRecipeImage.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKConstants.h"
#import "CKRecipeImage.h"
@implementation CKRecipeImage

+ (CKRecipeImage*)recipeImageForImage:(UIImage *)image imageName:(NSString *)imageName
{
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
    PFObject *parseRecipeImage = [PFObject objectWithClassName:kRecipeImageModelName];
    [parseRecipeImage setObject:imageName forKey:kRecipeImageAttrImageName];
    [parseRecipeImage setObject:imageFile forKey:kRecipeImageAttrImageFile];
    
    return [[CKRecipeImage alloc] initWithParseObject:parseRecipeImage];
}

+(CKRecipeImage *)recipeImageForParseRecipeImage:(PFObject *)parseRecipeImage
{
    CKRecipeImage *recipeImage = [[CKRecipeImage alloc]initWithParseObject:parseRecipeImage];
    return recipeImage;
}



-(PFFile *)imageFile
{
    return [self.parseObject objectForKey:@"imageFile"];
}

@end
