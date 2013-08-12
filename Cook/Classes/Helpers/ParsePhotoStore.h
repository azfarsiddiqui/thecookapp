//
//  PhotoCache.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParsePhotoStore : NSObject

// Manually store an image into the cache.
- (void)storeImage:(UIImage *)image parseFile:(PFFile *)parseFile size:(CGSize)size;
- (void)storeImage:(UIImage *)image forKey:(NSString *)cacheKey;

// Resturns the cached image of a scaled size - non-Parse related.
- (UIImage *)scaledImageForImage:(UIImage *)image name:(NSString *)name size:(CGSize)size;

// Returns the cached image if exists otherwise initiates downloads. Both cases return in blocks.
- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size completion:(void (^)(UIImage *image))completion;
- (void)imageForParseFile:(PFFile *)parseFile size:(CGSize)size indexPath:(NSIndexPath *)indexPath
               completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion;

// Initiates the downloads of the parseFile for the given size.
- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size indexPath:(NSIndexPath *)indexPath
                       completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion;
- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size completion:(void (^)(UIImage *image))completion;

// Checks if there was a cached image for the given key.
- (BOOL)hasCachedImageForKey:(NSString *)cacheKey;
- (UIImage *)cachedImageForKey:(NSString *)cacheKey;

@end
