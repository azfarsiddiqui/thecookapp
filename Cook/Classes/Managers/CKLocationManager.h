//
//  CKLocationManager.h
//  Cook
//
//  Created by Jeff Tan-Ang on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CKLocation;

@interface CKLocationManager : NSObject

+ (CKLocationManager *)sharedInstance;

- (void)requestForCurrentLocation:(void (^)(CKLocation *location))completion
                          failure:(void(^)(NSError *error))failure;

@end
