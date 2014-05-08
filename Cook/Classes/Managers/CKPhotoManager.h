//
//  CKUploadManager.h
//  Cook
//
//  Created by Jeff Tan-Ang on 25/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class CKUser;
@class CKBook;
@class CKRecipe;
@class CKRecipeImage;

@interface CKPhotoManager : NSObject

+ (CKPhotoManager *)sharedInstance;

// Image retrieval/downloads.
- (void)imageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
              progress:(void (^)(CGFloat progressRatio, NSString *name))progress
            completion:(void (^)(UIImage *image, NSString *name))completion;
- (void)thumbImageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
                   progress:(void (^)(CGFloat progressRatio, NSString *name))progress
                 completion:(void (^)(UIImage *thumbImage, NSString *name))completion;
- (void)imageForRecipe:(CKRecipe *)recipe size:(CGSize)size name:(NSString *)name
              progress:(void (^)(CGFloat progressRatio, NSString *name))progress
       thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
            completion:(void (^)(UIImage *image, NSString *name))completion;
- (void)imageForBook:(CKBook *)book size:(CGSize)size name:(NSString *)name
            progress:(void (^)(CGFloat progressRatio, NSString *name))progress
     thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
          completion:(void (^)(UIImage *image, NSString *name))completion;
- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size name:(NSString *)name
                 progress:(void (^)(CGFloat progressRatio))progress
               completion:(void (^)(UIImage *image, NSString *name))completion;
- (void)imageForUrl:(NSURL *)url size:(CGSize)size name:(NSString *)name
           progress:(void (^)(CGFloat progressRatio))progress
         completion:(void (^)(UIImage *image, NSString *name))completion;
- (void)imageForUrl:(NSURL *)url size:(CGSize)size name:(NSString *)name
           progress:(void (^)(CGFloat progressRatio))progress
      isSynchronous:(BOOL)isSynchronous
         completion:(void (^)(UIImage *image, NSString *name))completion;
- (void)featuredImageForRecipe:(CKRecipe *)recipe
                          size:(CGSize)size
                      progress:(void (^)(CGFloat progressRatio, NSString *name))progress
               thumbCompletion:(void (^)(UIImage *thumbImage, NSString *name))thumbCompletion
                    completion:(void (^)(UIImage *image, NSString *name))completion;

// Event-based photo loading.
- (void)thumbImageForRecipe:(CKRecipe *)recipe name:(NSString *)name size:(CGSize)size;
- (void)imageForRecipe:(CKRecipe *)recipe size:(CGSize)size;
- (void)fullImageForRecipe:(CKRecipe *)recipe size:(CGSize)size;
- (void)imageForBook:(CKBook *)book size:(CGSize)size;
- (void)imageForUrl:(NSURL *)url size:(CGSize)size;
- (void)blurredImageForRecipe:(CKRecipe *)recipe
                    tintColor:(UIColor *)tint
                   thumbImage:(UIImage *)image
                   completion:(void (^)(UIImage *blurredImage, NSString *name))completion;
- (void)blurredImageForRecipeWithImage:(UIImage *)image
                             tintColor:(UIColor *)tint
                            completion:(void (^)(UIImage *blurredImage))completion;
- (void)thumbImageForURL:(NSURL *)url size:(CGSize)size
              completion:(void (^)(UIImage *image, NSString *name))completion;

// Setup books, resizing etc.
- (void)generateImageAssets;
- (UIImage *)imageAssetForName:(NSString *)name;

// Image caching.
- (BOOL)imageCachedForKey:(NSString *)cacheKey;
- (UIImage *)cachedImageForKey:(NSString *)cacheKey;
- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey;
- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey toDisk:(BOOL)toDisk skipMemory:(BOOL)skipMemory;
- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey png:(BOOL)png;
- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey png:(BOOL)png toDisk:(BOOL)toDisk;
- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey png:(BOOL)png toDisk:(BOOL)toDisk
        skipMemory:(BOOL)skipMemory;
- (void)removeImageForKey:(NSString *)cacheKey;

// Image uploads, including thumbnail generation.
- (void)addImage:(UIImage *)image recipe:(CKRecipe *)recipe;
- (void)addImage:(UIImage *)image book:(CKBook *)book;
- (void)addImage:(UIImage *)image user:(CKUser *)user;

// Photo names.
- (NSString *)photoNameForRecipe:(CKRecipe *)recipe;
- (NSString *)photoNameForBook:(CKBook *)book;

// Cached title image for book.
- (UIImage *)cachedTitleImageForBook:(CKBook *)book;
- (void)cacheTitleImage:(UIImage *)image book:(CKBook *)book;

@end
