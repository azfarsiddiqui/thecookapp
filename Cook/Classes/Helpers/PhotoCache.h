//
//  PhotoCache.h
//  Cook
//
//  Created by Jeff Tan-Ang on 15/02/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PhotoCache : NSObject

- (UIImage *)cachedImageForParseFile:(PFFile *)parseFile size:(CGSize)size;
- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size indexPath:(NSIndexPath *)indexPath
                       completion:(void (^)(NSIndexPath *indexPath, UIImage *image))completion;
- (void)downloadImageForParseFile:(PFFile *)parseFile size:(CGSize)size completion:(void (^)(UIImage *image))completion;


@end
