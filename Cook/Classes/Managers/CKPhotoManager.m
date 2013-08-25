//
//  CKUploadManager.m
//  Cook
//
//  Created by Jeff Tan-Ang on 25/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPhotoManager.h"
#import "ParsePhotoStore.h"
#import "ImageHelper.h"
#import "CKRecipeImage.h"
#import "CKRecipe.h"
#import "SDImageCache.h"
#import "NSString+Utilities.h"
#import "CKUser.h"

@interface CKPhotoManager ()

@property (nonatomic, strong) ParsePhotoStore *photoStore;
@property (nonatomic, strong) NSMutableDictionary *transferInProgress;

@end

@implementation CKPhotoManager

+ (CKPhotoManager *)sharedInstance {
    static dispatch_once_t pred;
    static CKPhotoManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKPhotoManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.photoStore = [[ParsePhotoStore alloc] init];
        self.transferInProgress = [NSMutableDictionary dictionary];
    }
    return self;
}

// Fullsize image retrieval for the given recipe at the specified size and name for callback completion comparison.
- (void)imageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
              progress:(void (^)(int percentage, NSString *name))progress
            completion:(void (^)(UIImage *image, NSString *name))completion {
    
    [self checkInTransferImageForRecipe:recipe size:size name:name
                             completion:^(UIImage *image, NSString *name) {
                                 
                                 // Found in-transfer image, return immediately.
                                 completion(image, name);
                                 
                             } otherwiseHandler:^{
                                 
                                 // Otherwise try and load the parseFile.
                                 [self imageForParseFile:recipe.recipeImage.imageFile size:size name:name
                                                progress:^(int percentage) {
                                                    progress(percentage, name);
                                                } completion:^(UIImage *image, NSString *name) {
                                                    completion(image, name);
                                                }];
                             }];
}

// Thumbnail image retrieval for the given recipe at the specified size and name for callbacl completion comparison.
- (void)thumbImageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
                   progress:(void (^)(int percentage, NSString *name))progress
                 completion:(void (^)(UIImage *thumbImage, NSString *name))completion {
    
    [self checkInTransferImageForRecipe:recipe size:size name:name
                             completion:^(UIImage *image, NSString *name) {
                                 
                                 // Found in-transfer image, return immediately.
                                 completion(image, name);
                                 
                             } otherwiseHandler:^{
                                 
                                 // Otherwise try and load the parseFile.
                                 [self imageForParseFile:recipe.recipeImage.thumbImageFile size:size name:name
                                                progress:^(int percentage) {
                                                    progress(percentage, name);
                                                } completion:^(UIImage *image, NSString *name) {
                                                    completion(image, name);
                                                }];
                             }];
}

// Image retrieval for the given recipe at the specified size and with logical name for callback completion comparison.
// Returns the thumbnail first if both required network access, otherwise fullsized image is returned first. Use case
// is for full recipe details screen. The progress is of the fullsize image.
- (void)imageForRecipe:(CKRecipe *)recipe thumbSize:(CGSize)thumbSize size:(CGSize)size name:(NSString *)name
              progress:(void (^)(int percentage, NSString *name))progress
       thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
            completion:(void (^)(UIImage *image, NSString *name))completion {
    
    [self checkInTransferImageForRecipe:recipe size:size name:name
                             completion:^(UIImage *image, NSString *name) {
                                 
                                 // Found in-transfer image, return immediately.
                                 completion(image, name);
                                 
                             } otherwiseHandler:^{
                                 
                                 PFFile *fullsizeFile = recipe.recipeImage.imageFile;
                                 if (fullsizeFile) {
                                     
                                     // Check if a fullsized file was cached, then just return that immediately and bypass thumbnail processing.
                                     UIImage *cachedFullsizeImage = [self cachedImageForParseFile:fullsizeFile size:size];
                                     if (cachedFullsizeImage) {
                                         completion(cachedFullsizeImage, name);
                                     } else {
                                         
                                         // Get the fullsize image with progress reporting.
                                         [self imageForRecipe:recipe size:size name:name
                                                     progress:^(int percentage, NSString *name) {
                                                         progress(percentage, name);
                                                     }
                                                   completion:^(UIImage *image, NSString *name) {
                                                       completion(image, name);
                                                   }];
                                         
                                         // Get the thumbnail.
                                         [self thumbImageForRecipe:recipe size:thumbSize name:name
                                                          progress:^(int percentage, NSString *name) {
                                                              // No reporting of progress for thumbnail.
                                                          } completion:^(UIImage *thumbImage, NSString *name) {
                                                              thumbCompletion(thumbImage, name);
                                                          }];
                                     }
                                     
                                 } else {
                                     completion(nil, name);
                                 }
                             }];
}

#pragma mark - Image uploads.

- (void)addImage:(UIImage *)image recipe:(CKRecipe *)recipe {
    
    // Get a reference to the RecipeImage, which should be set during the adding of the photo.
    CKRecipeImage *recipeImage = recipe.recipeImage;
    if (!recipeImage || ![recipeImage.imageUuid CK_containsText]) {
        DLog(@"No recipeImage found, or expecting non-empty imageUuid");
        return;
    }
        
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    __block UIBackgroundTaskIdentifier *backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
    }];
    
    // Fullsize and thumbnail.
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);  // Least compression.
    PFFile *imageFile = [PFFile fileWithName:@"fullsize.jpg" data:imageData];
    UIImage *thumbImage = [ImageHelper thumbImageForImage:image];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, 1.0);  // TODO Less compression?
    PFFile *thumbImageFile = [PFFile fileWithName:@"thumbnail.jpg" data:thumbImageData];
    
    // Initialise transfer progress for recipe image, using its imageUuid.
    [self updateTransferProgress:@(0) cacheKey:recipe.recipeImage.imageUuid];
    
    // Save a copy while transfer is being processed. This is so that the user could still see his/her own images.
    [self storeImage:image forKey:recipeImage.imageUuid];
    
    // Now upload the thumb sized.
    [thumbImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            DLog(@"Thumbnail image uploaded successfully.");
            
            // Attach it to the recipe image.
            recipeImage.thumbImageFile = thumbImageFile;
            
            // Now upload fullsized.
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    
                    // Attach it to the recipe image.
                    recipeImage.imageFile = imageFile;
                    
                    // Clear the placeholders.
                    recipeImage.thumbImageUuid = nil;
                    recipeImage.imageUuid = nil;
                    
                    // Save the recipe image to Parse.
                    [recipeImage saveInBackground:^{
                        
                        NSLog(@"Fullsize image uploaded successfully");
                        
                        // Successful, and remove the local copy
                        [self clearTransferForCacheKey:recipeImage.imageUuid];
                        
                        // End background task.
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                        
                    } failure:^(NSError *error) {
                        
                        // Failed, and still remove the local copy
                        [self clearTransferForCacheKey:recipeImage.imageUuid];
                        
                        // End background task.
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                    }];
                    
                } else {
                    
                    DLog(@"Fullsize image error %@", [error localizedDescription]);
                    
                    // Failed, and still remove the local copy
                    [self clearTransferForCacheKey:recipeImage.imageUuid];
                    
                    // End background task.
                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                }
                
            }];
            
        } else {
            
            DLog(@"Thumbnail image error %@", [error localizedDescription]);
            
            // Failed, and still remove the local copy
            [self clearTransferForCacheKey:recipeImage.imageUuid];
            
            // End background task.
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    }];
    
}

#pragma mark - Image caching.

- (BOOL)imageCachedForKey:(NSString *)cacheKey {
    return ([self cachedImageForKey:cacheKey] != nil);
}

- (UIImage *)cachedImageForKey:(NSString *)cacheKey {
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
    }
    return cachedImage;
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey {
    [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey];
}

- (void)removeImageForKey:(NSString *)cacheKey {
    [[SDImageCache sharedImageCache] removeImageForKey:cacheKey];
}

#pragma mark - Private methods

- (void)inTransferImageForRecipeImage:(CKRecipeImage *)recipeImage size:(CGSize)size name:(NSString *)name
                           completion:(void (^)(UIImage *image, NSString *name))completion {
    
    if ([recipeImage.imageUuid CK_containsText]) {
        
        // Get the in-transfer image.
        UIImage *image = [self cachedImageForKey:recipeImage.imageUuid];
        if (image) {
            
            // Return in-transfer image.
            DLog(@"Found in-transfer image.");
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                // Resize the image.
                UIImage *imageToFit = [ImageHelper croppedImage:image size:size];
                
                // Callback on mainqueue.
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(imageToFit, name);
                });
                
            });
            
        } else {
            
            // Didn't find in-transfer image, returning none.
            DLog(@"No in-transfer image, returning nil");
            completion(nil, name);
        }
        
    } else {
        
        // Return no image.
        DLog(@"No image, returning nil");
        completion(nil, name);
    }
    
}

- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size name:(NSString *)name
                 progress:(void (^)(int progress))progress
               completion:(void (^)(UIImage *image, NSString *name))completion {
    
    if (parseFile) {
        
        // Get cached image for the persisted parseFile.
        UIImage *image = [self cachedImageForParseFile:parseFile size:size];
        if (image) {
            
            // Return cached image.
            DLog(@"Found cached image.");
            completion(image, name);
            
        } else {
            
            // Otherwise download from Parse.
            [self downloadImageForParseFile:parseFile size:size name:name
                                   progress:^(int percentage) {
                                       progress(percentage);
                                   }
                                 completion:^(UIImage *image, NSString *name) {
                                     completion(image, name);
                                 }];
        }
        
    } else {
        
        // Return no image.
        DLog(@"No image, returning nil");
        completion(nil, name);
    }
    
}

- (void)checkInTransferImageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
                           completion:(void (^)(UIImage *image, NSString *name))completion
                     otherwiseHandler:(void (^)())otherwiseHandler {
    
    // If own recipe, check if we have in-transfer image.
    CKUser *currentUser = [CKUser currentUser];
    if ([currentUser isEqual:recipe.user]) {
        [self inTransferImageForRecipeImage:recipe.recipeImage size:size name:name
                                 completion:^(UIImage *image, NSString *name) {
                                     
                                     if (image) {
                                         
                                         // Found in-transfer image, return immediately.
                                         completion(image, name);
                                         
                                     } else {
                                         otherwiseHandler();
                                     }
                                 }];
    } else {
        otherwiseHandler();
    }
}

- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size name:(NSString *)name
                         progress:(void (^)(int progress))progress
                       completion:(void (^)(UIImage *image, NSString *name))completion {
    
    // Generate a cache key for the given file and size combination.
    NSString *cacheKey = [self cacheKeyForParseFile:parseFile size:size];
    
    // Return if a download is in progress for this cacheKey.
    if ([self transferInProgressForCacheKey:cacheKey]) {
        return;
    }
    
    DLog(@"Downloading file %@", parseFile.url);
    
    // Mark as in-progress transfer. Just set as zero progress for downloads until we need progress.
    [self updateTransferProgress:@(0) cacheKey:cacheKey];
    
    // Go ahead and download the file with progress updates.
    [parseFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (!error) {
            
            // Go ahead and download on a separate queue.
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                UIImage *image = [UIImage imageWithData:data];
                UIImage *imageToFit = [ImageHelper croppedImage:image size:size];
                
                // Keep it in the cache.
                [self storeImage:imageToFit forKey:cacheKey];
                
                // Mark as completed transfer.
                [self.transferInProgress removeObjectForKey:cacheKey];
                
                // Callback on mainqueue.
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(imageToFit, name);
                });
                
            });
            
        } else {
            DLog(@"Got file with data, error %@", [error localizedDescription]);
            
            // Mark as failed transfer.
            [self clearTransferForCacheKey:cacheKey];
            
            completion(nil, name);
        }
        
    } progressBlock:^(int progressPercentage) {
        DLog(@"CacheKey[%@] Progress[%d]", cacheKey, progressPercentage);
        
        // Update the transfer progress.
        [self updateTransferProgress:@(progressPercentage) cacheKey:cacheKey];
        progress(progressPercentage);
        
    }];
    
}

- (UIImage *)cachedImageForParseFile:(PFFile *)parseFile size:(CGSize)size {
    NSString *cacheKey = [self cacheKeyForParseFile:parseFile size:size];
    return [self cachedImageForKey:cacheKey];
}

- (NSString *)cacheKeyForParseFile:(PFFile *)parseFile size:(CGSize)size {
    return [self cacheKeyForName:parseFile.url size:size];
}

- (NSString *)cacheKeyForName:(NSString *)name size:(CGSize)size {
    return [NSString stringWithFormat:@"%@_%d_%d", name, (NSInteger)size.width, (NSInteger)size.height];
}

- (BOOL)transferInProgressForCacheKey:(NSString *)cacheKey {
    return ([self.transferInProgress objectForKey:cacheKey] != nil);
}

- (void)updateTransferProgress:(int)percentage cacheKey:(NSString *)cacheKey {
    [self.transferInProgress setObject:@(percentage / 100.0) forKey:cacheKey];
}

- (void)clearTransferForCacheKey:(NSString *)cacheKey {
    [self.transferInProgress removeObjectForKey:cacheKey];
}

@end
