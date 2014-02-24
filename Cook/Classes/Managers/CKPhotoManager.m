//
//  CKUploadManager.m
//  Cook
//
//  Created by Jeff Tan-Ang on 25/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKPhotoManager.h"
#import "ImageHelper.h"
#import "CKRecipeImage.h"
#import "CKRecipe.h"
#import "CKBook.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"
#import "NSString+Utilities.h"
#import "CKUser.h"
#import "CKBookCover.h"
#import "EventHelper.h"
#import "AppHelper.h"

@interface CKPhotoManager ()

@property (nonatomic, strong) NSMutableDictionary *transferInProgress;
@property (nonatomic, strong) NSOperationQueue *imageDownloadQueue;

@end

@implementation CKPhotoManager

#define kImageCompression           0.6
#define kThumbImageCompression      0.6
#define kBookTitleImagePrefix       @"titleImageForBook-"
#define kGeneratedAssetDirectory    @"generatedAssets"

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
        self.transferInProgress = [NSMutableDictionary dictionary];
        self.imageDownloadQueue = [[NSOperationQueue alloc] init];
        
        // 4 downloads at the same time.
        self.imageDownloadQueue.maxConcurrentOperationCount = 4;
        
        [SDImageCache sharedImageCache].maxCacheSize = (400 * 1024 * 1024); //Limit cache to 400MB
    }
    return self;
}

#pragma mark - Image retrieval and downloads.

// Fullsize image retrieval for the given recipe at the specified size and name for callback completion comparison.
- (void)imageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)iname
              progress:(void (^)(CGFloat progressRatio, NSString *name))progress
            completion:(void (^)(UIImage *image, NSString *name))completion {
    
    NSString *imageName = iname;
    if (!imageName) {
        imageName = [self photoNameForRecipe:recipe];
    }
    __weak CKPhotoManager *weakSelf = self;
    [self checkInTransferImageForRecipe:recipe size:size name:imageName
                             completion:^(UIImage *image, NSString *name) {
                                 
                                 // Found in-transfer image, return immediately.
                                 completion(image, name);
                                 
                             } otherwiseHandler:^{
                                 
                                 // Otherwise try and load the parseFile.
                                 [weakSelf imageForParseFile:recipe.recipeImage.imageFile size:size name:imageName
                                                    progress:^(CGFloat progressRatio) {
                                                        progress(progressRatio, imageName);
                                                    } completion:^(UIImage *image, NSString *name) {
                                                        completion(image, name);
                                                    }];
                             }];
}

// Thumbnail image retrieval for the given recipe at the specified size and name for callbacl completion comparison.
- (void)thumbImageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)iname
                   progress:(void (^)(CGFloat progressRatio, NSString *name))progress
                 completion:(void (^)(UIImage *thumbImage, NSString *name))completion {
    NSString *imageName = iname;
    if (!imageName) {
        imageName = [self photoNameForRecipe:recipe];
    }
    __weak CKPhotoManager *weakSelf = self;
    [self checkInTransferImageForRecipe:recipe size:size name:imageName
                             completion:^(UIImage *image, NSString *name) {
                                 
                                 // Found in-transfer image, return immediately.
                                 completion(image, name);
                                 
                             } otherwiseHandler:^{
                                 
                                 // Check if we have a thumbnail image, otherwise load the big one.
                                 if (recipe.recipeImage.thumbImageFile) {
                                     [weakSelf imageForParseFile:recipe.recipeImage.thumbImageFile size:size name:imageName
                                                           thumb:YES
                                                        progress:^(CGFloat progressRatio) {
                                                            progress(progressRatio, imageName);
                                                        } completion:^(UIImage *image, NSString *name) {
                                                            completion(image, name);
                                                        }];
                                 } else {
                                     [weakSelf imageForParseFile:recipe.recipeImage.imageFile size:size name:imageName
                                                        progress:^(CGFloat progressRatio) {
                                                            progress(progressRatio, imageName);
                                                        } completion:^(UIImage *image, NSString *name) {
                                                            completion(image, name);
                                                        }];
                                 }
                                 
                             }];
}

// Image retrieval for the given recipe at the specified size and with logical name for callback completion comparison.
// Returns the thumbnail first if both required network access, otherwise fullsized image is returned first. Use case
// is for full recipe details screen. The progress is of the fullsize image.
- (void)imageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
              progress:(void (^)(CGFloat progressRatio, NSString *name))progress
       thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
            completion:(void (^)(UIImage *image, NSString *name))completion {
    
    __weak CKPhotoManager *weakSelf = self;
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
                                         
                                         // Get the thumbnail.
                                         [weakSelf thumbImageForRecipe:recipe size:[ImageHelper thumbSize] name:name
                                                              progress:^(CGFloat progressRatio, NSString *name) {
                                                                  // No reporting of progress for thumbnail.
                                                              } completion:^(UIImage *thumbImage, NSString *name) {
                                                                  thumbCompletion(thumbImage, name);
                                                              }];
                                         
                                         // Get the fullsize image with progress reporting.
                                         [weakSelf imageForRecipe:recipe size:size name:name
                                                         progress:^(CGFloat progressRatio, NSString *name) {
                                                             if (progress) {
                                                                 progress(progressRatio, name);
                                                             }
                                                         }
                                                       completion:^(UIImage *image, NSString *name) {
                                                           completion(image, name);
                                                       }];
                                         
                                     }
                                     
                                 } else {
                                     completion(nil, name);
                                 }
                             }];
}

- (void)featuredImageForRecipe:(CKRecipe *)recipe
                          size:(CGSize)size
                      progress:(void (^)(CGFloat progressRatio, NSString *name))progress
               thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
                    completion:(void (^)(UIImage *image, NSString *name))completion {
    
    __weak CKPhotoManager *weakSelf = self;
    [self checkInTransferImageForRecipe:recipe size:size name:[self photoNameForRecipe:recipe]
                             completion:^(UIImage *image, NSString *name) {
                                 
                                 // Found in-transfer image, return immediately.
                                 completion(image, name);
                                 
                             } otherwiseHandler:^{
                                 NSString *name = [self photoNameForRecipe:recipe];
                                 PFFile *fullsizeFile = recipe.recipeImage.imageFile;
                                 if (fullsizeFile) {
                                     
                                     // Check if a fullsized file was cached, then just return that immediately and bypass thumbnail processing.
                                     UIImage *cachedFullsizeImage = [self cachedImageForParseFile:fullsizeFile size:size];
                                     if (cachedFullsizeImage) {
                                         completion(cachedFullsizeImage, name);
                                     } else {
                                         // Get the fullsize image with progress reporting.
                                         [weakSelf imageForRecipe:recipe size:size name:name
                                                         progress:^(CGFloat progressRatio, NSString *name) {
                                                             if (progress) {
                                                                 progress(progressRatio, name);
                                                             }
                                                         }
                                                       completion:^(UIImage *image, NSString *name) {
                                                           completion(image, name);
                                                       }];
                                     }
                                     
                                     // Get thumb file and return either cached or downloaded image
                                     PFFile *thumbFile = recipe.recipeImage.thumbImageFile;
                                     if (thumbFile) {
                                         UIImage *cachedThumbImage = [self cachedImageForParseFile:thumbFile size:size];
                                         if (cachedThumbImage) {
                                             thumbCompletion(cachedThumbImage, name);
                                         } else {
                                             // Get the thumbnail.
                                             [weakSelf thumbImageForRecipe:recipe size:[ImageHelper thumbSize] name:name
                                                                  progress:^(CGFloat progressRatio, NSString *name) {
                                                                      // No reporting of progress for thumbnail.
                                                                  } completion:^(UIImage *thumbImage, NSString *name) {
                                                                      thumbCompletion(thumbImage, name);
                                                                  }];
                                         }
                                     }
                                     
                                 } else {
                                     completion(nil, name);
                                 }
                             }];
}

- (void)imageForBook:(CKBook *)book size:(CGSize)size name:(NSString *)name
            progress:(void (^)(CGFloat progressRatio, NSString *name))progress
     thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
          completion:(void (^)(UIImage *image, NSString *name))completion {
    
    __weak CKPhotoManager *weakSelf = self;
    PFFile *fullsizeFile = book.coverPhotoFile;
    if (fullsizeFile) {
        
        // Check if a fullsized file was cached, then just return that immediately and bypass thumbnail processing.
        UIImage *cachedFullsizeImage = [self cachedImageForParseFile:fullsizeFile size:size];
        if (cachedFullsizeImage) {
            completion(cachedFullsizeImage, name);
        } else {
            
            // Get the fullsize image with progress reporting.
            [weakSelf imageForParseFile:fullsizeFile size:size name:name
                               progress:^(CGFloat progressRatio) {
                                   progress(progressRatio, name);
                               } completion:^(UIImage *image, NSString *name) {
                                   completion(image, name);
                               }];
            
            // Get the thumbnail.
            [weakSelf imageForParseFile:book.coverPhotoThumbFile size:[ImageHelper thumbSize] name:name
                               progress:^(CGFloat progressRatio) {
                                   // No reporting of progress for thumbnail.
                               } completion:^(UIImage *image, NSString *name) {
                                   completion(image, name);
                               }];
        }
        
    } else {
        completion(nil, name);
    }

}

- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size name:(NSString *)name
                 progress:(void (^)(CGFloat progressRatio))progress
               completion:(void (^)(UIImage *image, NSString *name))completion {
    
    [self imageForParseFile:parseFile size:size name:name thumb:NO progress:progress completion:completion];
}

- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size name:(NSString *)name thumb:(BOOL)thumb
                 progress:(void (^)(CGFloat progressRatio))progress
               completion:(void (^)(UIImage *image, NSString *name))completion {
    
    if (parseFile) {
        
        __weak CKPhotoManager *weakSelf = self;
        
        @autoreleasepool {
            // Get cached image for the persisted parseFile.
            UIImage *image = [weakSelf cachedImageForParseFile:parseFile size:size];
            if (image) {
                
                // Return cached image.
                completion(image, name);
                
            } else {
                
                // Generate a cache key for the given file and size combination.
                NSString *cacheKey = [self cacheKeyForParseFile:parseFile size:size];
                
                // Return if a download is in progress for this cacheKey.
                if ([self transferInProgressForCacheKey:cacheKey]) {
                    return;
                }
                
                // Otherwise download from Parse in an operation.
                NSBlockOperation *imageDownloadOperation = [NSBlockOperation blockOperationWithBlock:^{
                    [weakSelf downloadImageForParseFile:parseFile size:size name:name thumb:thumb
                                               progress:^(CGFloat progressRatio) {
                                                   progress(progressRatio);
                                               }
                                             completion:^(UIImage *image, NSString *name) {
                                                 completion(image, name);
                                             }];
                }];
                
                // Thumbs are highest priority to download.
                // imageDownloadOperation.queuePriority = thumb ? NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
                imageDownloadOperation.queuePriority = thumb ? NSOperationQueuePriorityNormal : NSOperationQueuePriorityHigh;
                [weakSelf.imageDownloadQueue addOperation:imageDownloadOperation];

            }
        }
        
    } else {
        
        // Return no image.
        completion(nil, name);
    }
    
}

- (void)imageForUrl:(NSURL *)url size:(CGSize)size name:(NSString *)name
           progress:(void (^)(CGFloat progressRatio))progress
         completion:(void (^)(UIImage *image, NSString *name))completion {
    [self imageForUrl:url size:size name:name progress:progress isSynchronous:NO completion:completion];
}

- (void)imageForUrl:(NSURL *)url size:(CGSize)size name:(NSString *)name
           progress:(void (^)(CGFloat progressRatio))progress
      isSynchronous:(BOOL)isSynchronous
         completion:(void (^)(UIImage *image, NSString *name))completion {
    if (url) {

        __weak CKPhotoManager *weakSelf = self;
        
        @autoreleasepool {
            // Get cached image for the persisted parseFile.
            UIImage *image = [weakSelf cachedImageForName:[url absoluteString] size:size];
            if (image) {
                
                // Return cached image.
                completion(image, name);
                
            } else {
                
                // Otherwise download directly via URL.
                [weakSelf downloadImageForUrl:url size:size name:name
                                     progress:^(CGFloat progressRatio) {
                                         progress(progressRatio);
                                     }
                                isSynchronous:isSynchronous
                                   completion:^(UIImage *image, NSString *name) {
                                       completion(image, name);
                                   }];
            }
        }

    } else {
        
        // Return no image.
        completion(nil, name);
    }
}

#pragma mark - Event-based image loading.

- (void)thumbImageForRecipe:(CKRecipe *)recipe size:(CGSize)size {
    
    NSString *photoName = [self photoNameForRecipe:recipe];
    
    __weak CKPhotoManager *weakSelf = self;
    [self checkInTransferImageForRecipe:recipe size:size name:photoName
                             completion:^(UIImage *image, NSString *name) {
                                 
                                 [EventHelper postPhotoLoadingImage:image name:name thumb:YES];
                                 
                             } otherwiseHandler:^{
                                 
                                 if (recipe.recipeImage.thumbImageFile) {
                                     [weakSelf imageForParseFile:recipe.recipeImage.thumbImageFile size:size name:photoName
                                                           thumb:YES
                                                        progress:^(CGFloat progressRatio) {
                                                            // Ignore progress for event-based loading.
                                                        } completion:^(UIImage *image, NSString *name) {
                                                            [EventHelper postPhotoLoadingImage:image name:name thumb:YES];
                                                        }];
                                 } else {
                                     [weakSelf imageForParseFile:recipe.recipeImage.imageFile size:size name:photoName
                                                        progress:^(CGFloat progressRatio) {
                                                            // Ignore progress for event-based loading.
                                                        } completion:^(UIImage *image, NSString *name) {
                                                            [EventHelper postPhotoLoadingImage:image name:name thumb:YES];
                                                        }];
                                 }
                                 
                             }];
}

- (void)imageForRecipe:(CKRecipe *)recipe size:(CGSize)size {
    
    NSString *photoName = [self photoNameForRecipe:recipe];
    
    __weak CKPhotoManager *weakSelf = self;
    [self checkInTransferImageForRecipe:recipe size:size
                                   name:photoName
                             completion:^(UIImage *image, NSString *name) {
                                 
                                 [EventHelper postPhotoLoadingImage:image name:name thumb:NO];
                                 
                             } otherwiseHandler:^{
                                 
                                 PFFile *fullsizeFile = recipe.recipeImage.imageFile;
                                 if (fullsizeFile) {
                                     
                                     // Check if a fullsized file was cached, then just return that immediately and bypass thumbnail processing.
                                     UIImage *cachedFullsizeImage = [self cachedImageForParseFile:fullsizeFile size:size];
                                     if (cachedFullsizeImage) {
                                         [EventHelper postPhotoLoadingImage:cachedFullsizeImage name:photoName thumb:NO];
                                     } else {
                                         
                                         // Get the fullsize image with progress reporting.
                                         [weakSelf imageForRecipe:recipe size:size name:photoName
                                                         progress:^(CGFloat progressRatio, NSString *name) {
                                                             // Ignore progress for event-based loading.
                                                         }
                                                       completion:^(UIImage *image, NSString *name) {
                                                           [EventHelper postPhotoLoadingImage:image name:name thumb:NO];
                                                       }];
                                         
                                         // Get the thumbnail.
                                         [weakSelf thumbImageForRecipe:recipe size:[ImageHelper thumbSize] name:photoName
                                                              progress:^(CGFloat progressRatio, NSString *name) {
                                                                  // Ignore progress for event-based loading.
                                                              } completion:^(UIImage *thumbImage, NSString *name) {
                                                                  [EventHelper postPhotoLoadingImage:thumbImage name:name thumb:YES];
                                                              }];
                                     }
                                     
                                 } else {
                                     [EventHelper postPhotoLoadingImage:nil name:photoName thumb:NO];
                                 }
                             }];
}

- (void)imageForBook:(CKBook *)book size:(CGSize)size {
    
    NSString *photoName = [self photoNameForBook:book];
    [self checkInTransferImageForName:photoName size:size
                           completion:^(UIImage *image, NSString *name){
                               [EventHelper postPhotoLoadingImage:image name:photoName thumb:NO];
                               
                           } otherwiseHandler:^{
                               
                               __weak CKPhotoManager *weakSelf = self;
                               PFFile *fullsizeFile = book.coverPhotoFile;
                               if (fullsizeFile) {
                                   
                                   // Check if a fullsized file was cached, then just return that immediately and bypass thumbnail processing.
                                   UIImage *cachedFullsizeImage = [self cachedImageForParseFile:fullsizeFile size:size];
                                   if (cachedFullsizeImage) {
                                       [EventHelper postPhotoLoadingImage:cachedFullsizeImage name:photoName thumb:NO];
                                   } else {
                                       
                                       // Get the fullsize image with progress reporting.
                                       [weakSelf imageForParseFile:fullsizeFile size:size name:photoName
                                                          progress:^(CGFloat progressRatio) {
                                                              // Ignore progress for event-based loading.
                                                          } completion:^(UIImage *image, NSString *name) {
                                                              [EventHelper postPhotoLoadingImage:image name:name thumb:NO];
                                                          }];
                                       
                                       // Get the thumbnail.
                                       [weakSelf imageForParseFile:book.coverPhotoThumbFile size:[ImageHelper thumbSize] name:photoName
                                                          progress:^(CGFloat progressRatio) {
                                                              // Ignore progress for event-based loading.
                                                          } completion:^(UIImage *image, NSString *name) {
                                                              [EventHelper postPhotoLoadingImage:image name:name thumb:YES];
                                                          }];
                                   }
                                   
                               } else {
                                   [EventHelper postPhotoLoadingImage:nil name:photoName thumb:NO];
                               }
                               
                           }];
}

- (void)imageForUrl:(NSURL *)url size:(CGSize)size {
    if (url) {
        
        NSString *name = [[url absoluteString] lowercaseString];
        __weak CKPhotoManager *weakSelf = self;
        @autoreleasepool {
            
            // Get cached image for the persisted parseFile.
            UIImage *image = [weakSelf cachedImageForName:name size:size];
            if (image) {
                [EventHelper postPhotoLoadingImage:image name:name thumb:NO];
            } else {
                
                // Otherwise download directly via URL.
                [weakSelf downloadImageForUrl:url size:size name:name
                                     progress:^(CGFloat progressRatio) {
                                     }
                                isSynchronous:NO
                                   completion:^(UIImage *image, NSString *name) {
                                       [EventHelper postPhotoLoadingImage:image name:name thumb:NO];
                                   }];
            }
        }
        
    } else {
        [EventHelper postPhotoLoadingImage:nil name:nil thumb:NO];
    }
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
    
    DLog(@"Uploading images for recipe [%@]", recipe.objectId);
    
    // Fullsize and thumbnail.
    NSData *imageData = UIImageJPEGRepresentation(image, kImageCompression);
    PFFile *imageFile = [PFFile fileWithName:@"fullsize.jpg" data:imageData];
    UIImage *thumbImage = [ImageHelper thumbImageForImage:image];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, kThumbImageCompression);
    PFFile *thumbImageFile = [PFFile fileWithName:@"thumbnail.jpg" data:thumbImageData];
    
    // Initialise transfer progress for recipe image, using its imageUuid.
    [self updateTransferProgress:@(0) cacheKey:recipe.recipeImage.imageUuid];
    
    // Save a copy while transfer is being processed. This is so that the user could still see his/her own images.
    [self storeImage:image forKey:recipeImage.imageUuid toDisk:YES skipMemory:NO];
    
    // Now upload the thumb sized.
    __weak CKPhotoManager *weakSelf = self;
    NSString *cacheKey = recipeImage.imageUuid;
    
    [thumbImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            DLog(@"Thumbnail image uploaded successfully.");
            
            // Attach it to the recipe image.
            recipeImage.thumbImageFile = thumbImageFile;
            
            // Now upload fullsized.
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    
                    // Associate with recipe.
                    [recipeImage associateWithRecipe:recipe];
                    
                    // Attach it to the recipe image.
                    recipeImage.imageFile = imageFile;
                    
                    // Clear the placeholders.
                    recipeImage.thumbImageUuid = nil;
                    recipeImage.imageUuid = nil;
                    
                    // Save the recipe image to Parse.
                    [recipeImage saveInBackground:^{
                        
                        NSLog(@"Fullsize image uploaded successfully");
                        
                        // Successful, and remove the local copy
                        [weakSelf clearTransferForCacheKey:cacheKey];
                        
                        // Clear in-memory cache, but retain the disk one.
                        [weakSelf clearCachedImageForKey:cacheKey fromDisk:NO];
                        
                        // End background task.
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                        
                    } failure:^(NSError *error) {
                        
                        // Failed, and still remove the local copy
                        [weakSelf clearTransferForCacheKey:cacheKey];
                        
                        // End background task.
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                    }];
                    
                } else {
                    
                    DLog(@"Fullsize image error %@", [error localizedDescription]);
                    
                    // Failed, and still remove the local copy
                    [weakSelf clearTransferForCacheKey:cacheKey];
                    
                    // End background task.
                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                }
                
            } progressBlock:^(int percentage) {
                
                // Update progress on full size upload.
                [weakSelf updateTransferProgress:percentage cacheKey:cacheKey];
                
            }];
            
        } else {
            
            DLog(@"Thumbnail image error %@", [error localizedDescription]);
            
            // Failed, and still remove the local copy
            [weakSelf clearTransferForCacheKey:cacheKey];
            
            // End background task.
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    }];
    
}

- (void)addImage:(UIImage *)image book:(CKBook *)book {
    
    // Store the image locally while it is being uploaded.
    NSString *photoName = [self photoNameForBook:book];
    [self storeImage:image forKey:photoName];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    __block UIBackgroundTaskIdentifier *backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
    }];
    
    DLog(@"Uploading images for book [%@]", book.objectId);
    
    // Fullsize and thumbnail.
    NSData *imageData = UIImageJPEGRepresentation(image, kImageCompression);
    PFFile *imageFile = [PFFile fileWithName:@"cover.jpg" data:imageData];
    UIImage *thumbImage = [ImageHelper thumbImageForImage:image];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, kThumbImageCompression);
    PFFile *thumbImageFile = [PFFile fileWithName:@"coverthumb.jpg" data:thumbImageData];
    
    // Now upload the thumb sized.
    [thumbImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            DLog(@"Book thumbnail cover uploaded successfully.");
            
            // Attach it to the book.
            book.coverPhotoThumbFile = thumbImageFile;
            
            // Now upload fullsized.
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    
                    // Attach it to the book.
                    book.coverPhotoFile = imageFile;
                    
                    // Save the book to Parse.
                    [book saveInBackground:^{
                        
                        DLog(@"Book fullsize cover uploaded successfully.");
                        
                        // Remove from stored image.
                        [self removeImageForKey:photoName];
                        
                        // End background task.
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                        
                    } failure:^(NSError *error) {

                        // Remove from stored image.
                        [self removeImageForKey:photoName];
                        
                        // End background task.
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                    }];
                    
                } else {
                    
                    DLog(@"Fullsize image error %@", [error localizedDescription]);
                    
                    // Remove from stored image.
                    [self removeImageForKey:photoName];
                    
                    // End background task.
                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                }
                
            }];
            
        } else {
            
            // Remove from stored image.
            [self removeImageForKey:photoName];
            
            DLog(@"Thumbnail image error %@", [error localizedDescription]);
            
            // End background task.
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    }];
}

- (void)addImage:(UIImage *)image user:(CKUser *)user {
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    __block UIBackgroundTaskIdentifier *backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
    }];
    
    DLog(@"Uploading images for user [%@]", user.objectId);
    
    // Just the thumbnail size for the user photo.
    UIImage *thumbImage = image;
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, kThumbImageCompression);
    PFFile *thumbImageFile = [PFFile fileWithName:@"profile.jpg" data:thumbImageData];
    
    // Now upload the thumb sized.
    [thumbImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            DLog(@"Profile photo uploaded successfully.");
            
            // Attach it to the book.
            user.profilePhoto = thumbImageFile;
            
            // Save the book to Parse.
            [user saveInBackground:^{
                
                DLog(@"User saved successfully.");
                [CKUser refreshCurrentUser];
                // End background task.
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
                
            } failure:^(NSError *error) {
                
                // End background task.
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
            }];
            
        } else {
            
            DLog(@"Profile photo image error %@", [error localizedDescription]);
            
            // End background task.
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    }];
}

#pragma mark - Setup books.

- (void)generateImageAssets {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        
        @autoreleasepool {
            
            // Do we have generated assets already?
            NSString *documentsDirectoryPath = [[AppHelper sharedInstance] documentsPathForDirectoryName:kGeneratedAssetDirectory];
            BOOL isDir;
            [[NSFileManager defaultManager] fileExistsAtPath:documentsDirectoryPath isDirectory:&isDir];
            if (isDir) {
                return;
            }
            
            // Create the generated assets.
            [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
            NSArray *illustrations = [[CKBookCover illustrations] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            // Illustrations.
            for (NSString *illustration in illustrations) {
                
                UIImage *image = [CKBookCover imageForIllustration:illustration];
                UIImage *smallImage = [ImageHelper scaledImage:image size:[CKBookCover smallCoverImageSize]];
                NSString *smallIllustrationPath = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath,
                                                   [CKBookCover smallImageNameForIllustration:illustration]];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:smallIllustrationPath]) {
                    [UIImagePNGRepresentation(smallImage) writeToFile:smallIllustrationPath atomically:YES];
                    DLog(@"Scaled small illustration[%@]", illustration);
                }
            }
            
            // Covers.
            NSArray *covers = [CKBookCover covers];
            for (NSString *cover in covers) {
                
                UIImage *image = [CKBookCover imageForCover:cover];
                UIImage *smallImage = [ImageHelper scaledImage:image size:[CKBookCover smallCoverImageSize]];
                NSString *coverIllustrationPath = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath,
                                                   [CKBookCover smallImageNameForCover:cover]];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:coverIllustrationPath]) {
                    [UIImagePNGRepresentation(smallImage) writeToFile:coverIllustrationPath atomically:YES];
                    DLog(@"Scaled small cover[%@]", cover);
                }
                
            }
        }
        
    });
    
}

- (UIImage *)imageAssetForName:(NSString *)name {
    NSString *documentsDirectoryPath = [[AppHelper sharedInstance] documentsPathForDirectoryName:kGeneratedAssetDirectory];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath, name];
    return [UIImage imageWithContentsOfFile:imagePath];
}

#pragma mark - Image caching.

- (BOOL)imageCachedForKey:(NSString *)cacheKey {
    return ([self cachedImageForKey:cacheKey] != nil);
}

- (UIImage *)cachedImageForKey:(NSString *)cacheKey {
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:cacheKey];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
        
        if ([[cacheKey uppercaseString] rangeOfString:@"THUMBNAIL"].location != NSNotFound) {
            [[SDImageCache sharedImageCache] storeThumbInCache:cachedImage forKey:cacheKey];
        }
    }
    return cachedImage;
}

- (void)clearCachedImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk {
    [[SDImageCache sharedImageCache] removeImageForKey:key fromDisk:fromDisk];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey {
    [self storeImage:image forKey:cacheKey png:NO];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey toDisk:(BOOL)toDisk skipMemory:(BOOL)skipMemory {
    [self storeImage:image forKey:cacheKey png:NO toDisk:toDisk skipMemory:skipMemory];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey png:(BOOL)png {
    [self storeImage:image forKey:cacheKey png:png toDisk:YES];
    [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey png:png toDisk:YES];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey png:(BOOL)png toDisk:(BOOL)toDisk {
    
    [self storeImage:image forKey:cacheKey png:png toDisk:toDisk skipMemory:YES];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey png:(BOOL)png toDisk:(BOOL)toDisk
        skipMemory:(BOOL)skipMemory {
    
    [[SDImageCache sharedImageCache] storeImage:image forKey:cacheKey png:png toDisk:toDisk skipMemory:skipMemory];
}

- (void)removeImageForKey:(NSString *)cacheKey {
    [[SDImageCache sharedImageCache] removeImageForKey:cacheKey];
}

#pragma mark - Retrieval methods

- (NSString *)photoNameForRecipe:(CKRecipe *)recipe {
    return [NSString stringWithFormat:@"recipe_%@", recipe.objectId];
}

- (NSString *)photoNameForBook:(CKBook *)book {
    return [NSString stringWithFormat:@"book_%@", book.objectId];
}

#pragma mark - Cached title images for book.

- (UIImage *)cachedTitleImageForBook:(CKBook *)book {
    return [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self cachedTitleImageKeyForBook:book] skipMemory:YES];
}

- (void)cacheTitleImage:(UIImage *)image book:(CKBook *)book {
    [[SDImageCache sharedImageCache] storeImage:image forKey:[self cachedTitleImageKeyForBook:book] toDisk:YES];
}

#pragma mark - Private methods

- (void)inTransferImageForName:(NSString *)name size:(CGSize)size completion:(void (^)(UIImage *image, NSString *name))completion {
    
    // Check the in-transfer image area to see if we have the image there first.
    UIImage *inTransferImage = [self cachedImageForKey:name];
    if (inTransferImage) {
        DLog(@"Found in-transfer image, using it instead.");
        
        // Check if we have the cached image of that size.
        NSString *cacheKey = [self cacheKeyForName:name size:size];
        UIImage *cachedImage = [self cachedImageForKey:cacheKey];
        if (cachedImage) {
            completion(cachedImage, name);
        } else {
            
            // Go ahead and process on a separate queue.
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                @autoreleasepool {
                    
                    // Crop the image to the required size.
                    UIImage *imageToFit = [ImageHelper croppedImage:inTransferImage size:size];
                    
                    // Keep it in the cache.
                    [self storeImage:imageToFit forKey:cacheKey];
                    
                    // Callback on mainqueue.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(imageToFit, name);
                    });
                }
                
            });
        }
    } else {
        completion(nil, name);
    }
}

- (void)checkInTransferImageForName:(NSString *)name size:(CGSize)size
                         completion:(void (^)(UIImage *image, NSString *name))completion
                   otherwiseHandler:(void (^)())otherwiseHandler {
    
    [self inTransferImageForName:name size:size completion:^(UIImage *image, NSString *name) {
        if (image) {
            DLog(@"Found in-transfer image with name [%@]", name);
            completion(image, name);
        } else {
            otherwiseHandler();
        }
        
    }];
}

- (void)inTransferImageForRecipeImage:(CKRecipeImage *)recipeImage size:(CGSize)size name:(NSString *)name
                           completion:(void (^)(UIImage *image, NSString *name))completion {
    
    if ([recipeImage.imageUuid CK_containsText]) {
        
        // Get the in-transfer image.
        UIImage *image = [self cachedImageForKey:recipeImage.imageUuid];
        if (image) {
            
            // Return in-transfer image.
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                @autoreleasepool {
                    // Resize the image.
                    UIImage *imageToFit = [ImageHelper croppedImage:image size:size];
                    
                    // Callback on mainqueue.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(imageToFit, name);
                    });
                }
                
            });
            
        } else {
            
            // Didn't find in-transfer image, returning none.
//            DLog(@"No in-transfer image, returning nil");
            completion(nil, name);
        }
        
    } else {
        
        // Return no image.
//        DLog(@"No image, returning nil");
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
                         progress:(void (^)(CGFloat progressRatio))progress
                       completion:(void (^)(UIImage *image, NSString *name))completion {
    
    [self downloadImageForParseFile:parseFile size:size name:name thumb:NO progress:progress completion:completion];
}

- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size name:(NSString *)name thumb:(BOOL)thumb
                         progress:(void (^)(CGFloat progressRatio))progress
                       completion:(void (^)(UIImage *image, NSString *name))completion {
    
    DLog(@"Downloading file %@", parseFile.url);
    
    // Generate a cache key for the given file and size combination.
    NSString *cacheKey = [self cacheKeyForParseFile:parseFile size:size];
    
    // Mark as in-progress transfer. Just set as zero progress for downloads until we need progress.
    [self updateTransferProgress:@(0) cacheKey:cacheKey];
    
    // Go ahead and download the file with progress updates.
    [parseFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (!error) {
            
            // Go ahead and download on a separate queue.
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                
                @autoreleasepool {
                    
                    UIImage *image = [UIImage imageWithData:data];
                    UIImage *imageToFit = [ImageHelper croppedImage:image size:size];
                    image = nil;
                    // Keep it in the cache. If thumbnail, store in memory cache
                    [self storeImage:imageToFit forKey:cacheKey];
                    
                    // Mark as completed transfer.
                    [self clearTransferForCacheKey:cacheKey];
                    
                    // Callback on mainqueue.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(imageToFit, name);
                    });
                }
                
            });
            
        } else {
            DLog(@"Got file with data, error %@", [error localizedDescription]);
            
            // Mark as failed transfer.
            [self clearTransferForCacheKey:cacheKey];
            
            completion(nil, name);
        }
        
    } progressBlock:^(int progressPercentage) {
        if (progressPercentage % 10 == 0) {
            
            // Report progress only for thumb.
            if (!thumb) {
                [EventHelper postPhotoLoadingProgress:(progressPercentage / 100.0) name:name];
            }
            // DLog(@"CacheKey[%@] Progress[%d]", cacheKey, progressPercentage);
        }
        
        // Update the transfer progress.
        [self updateTransferProgress:@(progressPercentage / 100.0) cacheKey:cacheKey];
        progress(progressPercentage);
        
    }];
    
}

- (void)downloadImageForUrl:(NSURL *)url size:(CGSize)size name:(NSString *)name
                   progress:(void (^)(CGFloat progressRatio))progress
              isSynchronous:(BOOL)isSynchronous
                 completion:(void (^)(UIImage *image, NSString *name))completion {
    
    // Generate a cache key for the given file and size combination.
    NSString *cacheKey = [self cacheKeyForName:[url absoluteString] size:size];
    
    // Return if a download is in progress for this cacheKey.
    if ([self transferInProgressForCacheKey:cacheKey]) {
        return;
    }
    
    DLog(@"Downloading URL %@", url);
    
    if (!isSynchronous)
    {
        // Mark as in-progress transfer. Just set as zero progress for downloads until we need progress.
        [self updateTransferProgress:@(0) cacheKey:cacheKey];
    }
    
    __weak CKPhotoManager *weakSelf = self;
    
    // Go ahead and download the file with progress updates.
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url options:0
                                                         progress:^(NSUInteger receivedSize, long long expectedSize) {
                                                             if (expectedSize > 0) {
                                                                 progress(receivedSize / expectedSize);
                                                             }
                                                         } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                             
                                                             if (!error) {
                                                                 
                                                                 @autoreleasepool {
                                                                     UIImage *image = [UIImage imageWithData:data];
                                                                     UIImage *imageToFit = [ImageHelper croppedImage:image size:size];
                                                                     
                                                                     // Keep it in the cache.
                                                                     [weakSelf storeImage:imageToFit forKey:cacheKey png:YES];
                                                                     
                                                                     if (!isSynchronous)
                                                                     {
                                                                         // Mark as completed transfer.
                                                                         [weakSelf.transferInProgress removeObjectForKey:cacheKey];
                                                                     }
                                                                     
                                                                     // Callback on mainqueue.
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         completion(imageToFit, name);
                                                                     });
                                                                 }
                                                                 
                                                             } else {
                                                                 
                                                                 // Mark as failed transfer.
                                                                 [weakSelf clearTransferForCacheKey:cacheKey];

                                                             }
                                                         }];
}

- (UIImage *)cachedImageForParseFile:(PFFile *)parseFile size:(CGSize)size {
    NSString *cacheKey = [self cacheKeyForParseFile:parseFile size:size];
    return [self cachedImageForKey:cacheKey];
}

- (UIImage *)cachedImageForName:(NSString *)name size:(CGSize)size {
    NSString *cacheKey = [self cacheKeyForName:name size:size];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(_transferInProgress) {
            [_transferInProgress setObject:@(percentage / 100.0) forKey:cacheKey];
        }
    });
}

- (void)clearTransferForCacheKey:(NSString *)cacheKey {
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(_transferInProgress) {
            [_transferInProgress removeObjectForKey:cacheKey];
        }
    });
}

- (NSString *)cachedTitleImageKeyForBook:(CKBook *)book {
    return [NSString stringWithFormat:@"%@%@", kBookTitleImagePrefix, book.objectId];
}

@end
