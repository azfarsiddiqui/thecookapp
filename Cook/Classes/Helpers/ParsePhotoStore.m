//
//  PhotoCache.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "ParsePhotoStore.h"
#import "UIImage+ProportionalFill.h"

@interface ParsePhotoStore ()

// A cache of URL+Size => UIImage
@property (nonatomic, strong) NSMutableDictionary *cache;

// A monitor of downloads in progress
@property (nonatomic, strong) NSMutableArray *downloadsInProgress;

- (NSString *)cacheKeyForParseFile:(PFFile *)parseFile size:(CGSize)size;

@end

@implementation ParsePhotoStore

- (id)init {
    if (self = [super init]) {
        self.cache = [NSMutableDictionary dictionary];
        self.downloadsInProgress = [NSMutableArray array];
    }
    return self;
}

- (void)storeImage:(UIImage *)image parseFile:(PFFile *)parseFile size:(CGSize)size {
    [self.cache setObject:image forKey:[self cacheKeyForParseFile:parseFile size:size]];
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
        DLog(@"Got file with data, error %@", [error localizedDescription]);
        if (!error) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                UIImage *image = [UIImage imageWithData:data];
                UIImage *imageToFit = [image imageCroppedToFitSize:size];
                
                // Update cache and remove from in-progress downloads.
                if (imageToFit) {
                    [self.cache setObject:imageToFit forKey:cacheKey];
                    [self.downloadsInProgress removeObject:cacheKey];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(imageToFit);
                    });
                }
            });
            
        }
    }];
    
}

#pragma mark - Private methods

- (UIImage *)cachedImageForParseFile:(PFFile *)parseFile size:(CGSize)size {
    return [self.cache objectForKey:[self cacheKeyForParseFile:parseFile size:size]];
}

- (NSString *)cacheKeyForParseFile:(PFFile *)parseFile size:(CGSize)size {
    return [NSString stringWithFormat:@"%@_%@", parseFile.url, NSStringFromCGSize(size)];
}

@end
