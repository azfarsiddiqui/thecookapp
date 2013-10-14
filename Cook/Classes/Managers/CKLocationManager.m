//
//  CKLocationManager.m
//  Cook
//
//  Created by Jeff Tan-Ang on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKLocationManager.h"
#import <Parse/Parse.h>
#import "CKLocation.h"

@interface CKLocationManager ()

@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation CKLocationManager

+ (CKLocationManager *)sharedInstance {
    static dispatch_once_t pred;
    static CKLocationManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[CKLocationManager alloc] init];
    });
    return sharedInstance;
}


- (void)requestForCurrentLocation:(void (^)(CKLocation *location))completion
                          failure:(void(^)(NSError *error))failure {
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            DLog(@"Got current location %@", geoPoint);
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                
                CLPlacemark *placemark = nil;
                if (!error) {
                    if ([placemarks count] > 0) {
                        placemark = [placemarks firstObject];
                    }
                }
                completion([CKLocation locationWithCoreLocation:location placemark:placemark]);
            }];
            
        } else {
            DLog(@"Unable to get current location [%@]", [error localizedDescription]);
            failure(error);
        }
    }];

}

#pragma mark - Properties

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

@end
