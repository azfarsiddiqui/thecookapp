//
//  PhotoCache.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class CKRecipeImage;
@class CKRecipe;

@interface ParsePhotoStore : NSObject

// Manually store/remove an image into the cache.
- (void)storeImage:(UIImage *)image parseFile:(PFFile *)parseFile size:(CGSize)size;
- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey;
- (void)removeImageForKey:(NSString *)cacheKey;

// Returns the cached image of a scaled size - non-Parse related.
- (UIImage *)scaledImageForImage:(UIImage *)image name:(NSString *)name size:(CGSize)size;
- (UIImage *)scaledImageForImage:(UIImage *)image name:(NSString *)name size:(CGSize)size cache:(BOOL)cache;

// Image retrieval and downloads.
- (void)imageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipe *)recipe size:(CGSize)size
                 completion:(void (^)(UIImage *image))completion;
- (void)thumbImageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipe *)recipe size:(CGSize)size
                      completion:(void (^)(UIImage *image))completion;
- (void)imageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipe *)recipe size:(CGSize)size
                  indexPath:(NSIndexPath *)indexPath
                 completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion;
- (void)thumbImageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipe *)recipe size:(CGSize)size
                       indexPath:(NSIndexPath *)indexPath completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion;

// Gets the image for the given CKRecipeImage model, and completes in 2 steps: thumbnail and fullsize. Optionally
// passing a name for completion blocks to identify the images.
- (void)imageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
            thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
                 completion:(void (^)(UIImage *image, NSString *name))completion;

- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size completion:(void (^)(UIImage *image))completion;
- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size indexPath:(NSIndexPath *)indexPath
               completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion;

// Initiates the downloads of the parseFile for the given size.
- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size indexPath:(NSIndexPath *)indexPath
                       completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion;
- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size completion:(void (^)(UIImage *image))completion;

// Checks if there was a cached image for the given key.
- (BOOL)hasCachedImageForRecipeImage:(CKRecipeImage *)recipeImage size:(CGSize)size;
- (BOOL)hasCachedImageForParseFile:(PFFile *)parseFile size:(CGSize)size;
- (BOOL)hasCachedImageForKey:(NSString *)cacheKey;
- (UIImage *)cachedImageForKey:(NSString *)cacheKey;

@end
