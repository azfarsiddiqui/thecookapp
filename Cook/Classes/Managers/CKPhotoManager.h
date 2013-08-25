//
//  CKUploadManager.h
//  Cook
//
//  Created by Jeff Tan-Ang on 25/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class CKRecipe;
@class CKRecipeImage;

@interface CKPhotoManager : NSObject

+ (CKPhotoManager *)sharedInstance;

// Image retrieval/downloads.
- (void)imageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
              progress:(void (^)(int percentage, NSString *name))progress
            completion:(void (^)(UIImage *image, NSString *name))completion;
- (void)thumbImageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
                   progress:(void (^)(int percentage, NSString *name))progress
                 completion:(void (^)(UIImage *thumbImage, NSString *name))completion;
- (void)imageForRecipe:(CKRecipe *)recipe thumbSize:(CGSize)thumbSize size:(CGSize)size name:(NSString *)name
              progress:(void (^)(int percentage, NSString *name))progress
       thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
            completion:(void (^)(UIImage *image, NSString *name))completion;

// Image caching.
- (BOOL)imageCachedForKey:(NSString *)cacheKey;
- (UIImage *)cachedImageForKey:(NSString *)cacheKey;
- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey;
- (void)removeImageForKey:(NSString *)cacheKey;

// Image uploads, including thumbnail generation.
- (void)addImage:(UIImage *)image recipe:(CKRecipe *)recipe;

@end
