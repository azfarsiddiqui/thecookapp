//
//  PhotoCache.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ParsePhotoStore.h"
#import "UIImage+ProportionalFill.h"
#import "ImageHelper.h"
#import "SDImageCache.h"
#import "CKRecipeImage.h"
#import "NSString+Utilities.h"
#import "CKServerManager.h"

@interface ParsePhotoStore ()

// A monitor of downloads in progress
@property (nonatomic, strong) NSMutableArray *downloadsInProgress;

@end

@implementation ParsePhotoStore

- (id)init {
    if (self = [super init]) {
        self.downloadsInProgress = [NSMutableArray array];
    }
    return self;
}

- (void)storeImage:(UIImage *)image parseFile:(PFFile *)parseFile size:(CGSize)size {
    [self storeImage:image forKey:[self cacheKeyForParseFile:parseFile size:size]];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey {
    [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey];
}

- (void)removeImageForKey:(NSString *)cacheKey {
    [[SDImageCache sharedImageCache] removeImageForKey:cacheKey];
}

- (UIImage *)scaledImageForImage:(UIImage *)image name:(NSString *)name size:(CGSize)size {
    return [self scaledImageForImage:image name:name size:size cache:YES];
}

- (UIImage *)scaledImageForImage:(UIImage *)image name:(NSString *)name size:(CGSize)size cache:(BOOL)cache {
    UIImage *scaledImage = nil;
    if (cache) {
        NSString *cacheKey = [self cacheKeyForName:name size:size];
        scaledImage = [self cachedImageForKey:cacheKey];
        if (!scaledImage) {
            scaledImage = [ImageHelper scaledImage:image size:size];
            [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:cacheKey];
        }
    } else {
        scaledImage = [ImageHelper scaledImage:image size:size];
    }
    return scaledImage;
}

#pragma mark - Image retrieval and downloads.

- (void)imageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipe *)recipe size:(CGSize)size
                 completion:(void (^)(UIImage *image))completion {
    
    PFFile *parseFile = recipeImage.imageFile;
    __block UIImage *image = nil;
    
    if (parseFile) {
        
        // Get cached image for the persisted parseFile.
        image = [self cachedImageForParseFile:parseFile size:size];
        if (image) {
            completion(image);
        } else {
            
            // Otherwise download from Parse.
            [self downloadImageForParseFile:parseFile size:size completion:^(UIImage *image) {
                completion(image);
            }];
        }
        
    } else if ([recipeImage.imageUuid CK_containsText]) {
        
        // Get in-transit image for recipe.
        image = [self cachedImageForRecipeImage:recipeImage recipe:recipeImage size:size];
        if (image) {
            completion(image);
        } else {
            
            // Other load from any in-transit cache.
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                // Get any in-transit image and resize it.
                UIImage *inTransitImage = [[CKServerManager sharedInstance] imageForRecipe:recipe];
                if (inTransitImage) {
                    image = [inTransitImage imageCroppedToFitSize:size];
                }
                
                // Update cache and remove from in-progress downloads.
                if (image) {
                    [self storeImage:image forKey:[self cacheKeyForRecipeImage:recipeImage size:size]];
                    
                }
                
                // Send it off to the main queue.
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image);
                });
            });
            
        }
        
    }

}

- (void)thumbImageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipe *)recipe size:(CGSize)size
                      completion:(void (^)(UIImage *image))completion {
    
    PFFile *parseFile = recipeImage.thumbImageFile;
    __block UIImage *image = nil;
    
    if (parseFile) {
        
        // Get cached image for the persisted parseFile.
        image = [self cachedImageForParseFile:parseFile size:size];
        if (image) {
            completion(image);
        } else {
            
            // Otherwise download from Parse.
            [self downloadImageForParseFile:parseFile size:size completion:^(UIImage *image) {
                completion(image);
            }];
        }
        
    } else if ([recipeImage.thumbImageUuid CK_containsText]) {
        
        // Get in-transit image for recipe.
        image = [self cachedImageForThumbRecipeImage:recipeImage recipe:recipeImage size:size];
        if (image) {
            completion(image);
        } else {
            
            // Other load from any in-transit cache.
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                // Get any in-transit image and resize it.
                UIImage *inTransitImage = [[CKServerManager sharedInstance] thumbnailImageForRecipe:recipe];
                if (inTransitImage) {
                    image = [inTransitImage imageCroppedToFitSize:size];
                }
                
                // Update cache and remove from in-progress downloads.
                if (image) {
                    [self storeImage:image forKey:[self cacheKeyForThumbRecipeImage:recipeImage size:size]];
                    
                }
                
                // Send it off to the main queue.
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image);
                });
            });
            
        }
        
    }
    
}

- (void)imageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
            thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
                 completion:(void (^)(UIImage *image, NSString *name))completion {
    
    // Do we have a cached fullsized image? Then fetch that and bypass the thumbnail.
    if (![self hasCachedImageForRecipeImage:recipeImage size:size]) {
        
        // Gets thumb image.
        [self thumbImageForRecipeImage:recipeImage recipe:recipe size:size
                            completion:^(UIImage *thumbImage) {
                                thumbCompletion(thumbImage, name);
                            }];
    }
    
    // Gets fullsize image.
    [self imageForRecipeImage:recipeImage recipe:recipe size:size
                   completion:^(UIImage *image) {
                       completion(image, name);
                   }];
    
}

- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size completion:(void (^)(UIImage *image))completion {
    UIImage *image = [self cachedImageForParseFile:parseFile size:size];
    if (image) {
        completion(image);
    } else {
        [self downloadImageForParseFile:parseFile size:size completion:^(UIImage *image) {
            completion(image);
        }];
    }
}

- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size indexPath:(NSIndexPath *)indexPath
               completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion {
    
    [self imageForParseFile:parseFile size:size completion:^(UIImage *image) {
        completion(indexPath, image);
    }];
}

- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size indexPath:(NSIndexPath *)indexPath
                       completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion {
    
    [self downloadImageForParseFile:parseFile size:size completion:^(UIImage *image) {
        completion(indexPath, image);
    }];
}

- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size completion:(void (^)(UIImage *image))completion {
    
    NSString *cacheKey = [self cacheKeyForParseFile:parseFile size:size];

    // Return if a download is in progress for this cacheKey.
    if ([self.downloadsInProgress containsObject:cacheKey]) {
        return;
    }
    
    DLog(@"Downloading file %@", parseFile.url);
    
    // Mark as in-progress downloads.
    [self.downloadsInProgress addObject:cacheKey];
    
    [parseFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                UIImage *image = [UIImage imageWithData:data];
                UIImage *imageToFit = [image imageCroppedToFitSize:size];
                
                // Update cache and remove from in-progress downloads.
                if (imageToFit) {
                    
                    // Cache the image.
                    [self storeImage:imageToFit forKey:cacheKey];
                    [self.downloadsInProgress removeObject:cacheKey];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(imageToFit);
                    });
                }
            });
        } else {
            DLog(@"Got file with data, error %@", [error localizedDescription]);
        }
    }];
    
}

// Checks to see if we have the fullsize cached image for the given CKRecipeImage.
- (BOOL)hasCachedImageForRecipeImage:(CKRecipeImage *)recipeImage size:(CGSize)size {
    BOOL cached = NO;
    if (recipeImage.imageFile) {
        cached = [self hasCachedImageForParseFile:recipeImage.imageFile size:size];
    } else if (recipeImage.imageUuid) {
        NSString *cacheKey = [self cacheKeyForRecipeImage:recipeImage size:size];
        cached = [self hasCachedImageForKey:cacheKey];
    }
    return cached;
}

// Checks if there was a cached image for the given PFFile
- (BOOL)hasCachedImageForParseFile:(PFFile *)parseFile size:(CGSize)size {
    return ([self cachedImageForParseFile:parseFile size:size] != nil);
}

// Checks if there was a cached image for the given key.
- (BOOL)hasCachedImageForKey:(NSString *)cacheKey {
    return ([self cachedImageForKey:cacheKey] != nil);
}

- (UIImage *)cachedImageForKey:(NSString *)cacheKey {
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
    }
    return cachedImage;
}

#pragma mark - Private methods

- (UIImage *)cachedImageForParseFile:(PFFile *)parseFile size:(CGSize)size {
    NSString *cacheKey = [self cacheKeyForParseFile:parseFile size:size];
    return [self cachedImageForKey:cacheKey];
}

- (UIImage *)cachedImageForRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipeImage *)recipe size:(CGSize)size {
    NSString *cacheKey = [self cacheKeyForName:recipeImage.imageUuid size:size];
    return [self cachedImageForKey:cacheKey];
}

- (UIImage *)cachedImageForThumbRecipeImage:(CKRecipeImage *)recipeImage recipe:(CKRecipeImage *)recipe size:(CGSize)size {
    NSString *cacheKey = [self cacheKeyForName:recipeImage.thumbImageUuid size:size];
    return [self cachedImageForKey:cacheKey];
}

- (NSString *)cacheKeyForRecipeImage:(CKRecipeImage *)recipeImage size:(CGSize)size {
    return [self cacheKeyForName:recipeImage.imageUuid size:size];
}

- (NSString *)cacheKeyForThumbRecipeImage:(CKRecipeImage *)recipeImage size:(CGSize)size {
    return [self cacheKeyForName:recipeImage.thumbImageUuid size:size];
}

- (NSString *)cacheKeyForParseFile:(PFFile *)parseFile size:(CGSize)size {
    return [self cacheKeyForName:parseFile.url size:size];
}

- (NSString *)cacheKeyForName:(NSString *)name size:(CGSize)size {
    return [NSString stringWithFormat:@"%@_%d_%d", name, (NSInteger)size.width, (NSInteger)size.height];
}

@end
