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

- (UIImage *)scaledImageForImage:(UIImage *)image name:(NSString *)name size:(CGSize)size {
    
    NSString *cacheKey = [self cacheKeyForName:name size:size];
    UIImage *scaledImage = [self cachedImageForKey:cacheKey];
    if (!scaledImage) {
        scaledImage = [ImageHelper scaledImage:image size:size];
        [[SDImageCache sharedImageCache] storeImage:scaledImage forKey:cacheKey];
    }
    return scaledImage;
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

- (NSString *)cacheKeyForParseFile:(PFFile *)parseFile size:(CGSize)size {
    return [self cacheKeyForName:parseFile.url size:size];
}

- (NSString *)cacheKeyForName:(NSString *)name size:(CGSize)size {
    return [NSString stringWithFormat:@"%@_%d_%d", name, (NSInteger)size.width, (NSInteger)size.height];
}

@end
