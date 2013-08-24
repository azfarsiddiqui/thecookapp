//
//  CKRecipeImage.m
//  Cook
//
//  Created by Jonny Sagorin on 10/5/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKConstants.h"
#import "CKRecipeImage.h"
#import "ImageHelper.h"

@implementation CKRecipeImage

+ (CKRecipeImage *)recipeImage {
    
    // Create parse object and wrapper.
    PFObject *parseRecipeImage = [self objectWithDefaultSecurityWithClassName:kRecipeImageModelName];
    return [[CKRecipeImage alloc] initWithParseObject:parseRecipeImage];
}

+ (CKRecipeImage*)recipeImageForImage:(UIImage *)image imageName:(NSString *)imageName {
    
    // Least compression on fullsize image.
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
    
    PFObject *parseRecipeImage = [self objectWithDefaultSecurityWithClassName:kRecipeImageModelName];
    [parseRecipeImage setObject:imageFile forKey:kRecipeImageAttrImageFile];
    
    return [self recipeImageForParseRecipeImage:parseRecipeImage];
}

+ (CKRecipeImage *)recipeImageForParseRecipeImage:(PFObject *)parseRecipeImage {
    CKRecipeImage *recipeImage = [[CKRecipeImage alloc] initWithParseObject:parseRecipeImage];
    return recipeImage;
}

#pragma mark - Properties

- (PFFile *)imageFile {
    return [self.parseObject objectForKey:kRecipeImageAttrImageFile];
}

- (void)setImageFile:(PFFile *)imageFile {
    [self.parseObject setObject:imageFile forKey:kRecipeImageAttrImageFile];
}

- (PFFile *)thumbImageFile {
    return [self.parseObject objectForKey:kRecipeImageAttrThumbImageFile];
}

- (void)setThumbImageFile:(PFFile *)thumbImageFile {
    [self.parseObject setObject:thumbImageFile forKey:kRecipeImageAttrThumbImageFile];
}

@end
