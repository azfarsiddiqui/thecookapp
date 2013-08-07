//
//  CKServerManager.h
//  Cook
//
//  Created by Jeff Tan-Ang on 26/09/12.
//  Copyright (c) 2012 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKServerManager : NSObject

+ (CKServerManager *)sharedInstance;

- (void)start;
- (void)stop;

- (BOOL)handleFacebookCallback:(NSURL *)url;
- (void)requestForCurrentLocation:(void(^)(double latitude, double longitude))completion
                          failure:(void(^)(NSError *error))failure;

@end
