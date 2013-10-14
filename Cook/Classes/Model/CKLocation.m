//
//  CKLocation.m
//  Cook
//
//  Created by Jeff Tan-Ang on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKLocation.h"
#import "NSString+Utilities.h"

@implementation CKLocation

+ (CKLocation *)locationWithCoreLocation:(CLLocation *)location placemark:(CLPlacemark *)placemark {
    PFObject *parseLocation = [self objectWithDefaultSecurityWithClassName:kLocationModelName];
    
    // Lat/long
    if (location) {
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude
                                                      longitude:location.coordinate.longitude];
        [parseLocation setObject:geoPoint forKey:kLocationGeoPoint];
    }
    
    // Placemark.
    if (placemark) {
        [parseLocation setObject:[NSString CK_safeString:placemark.name] forKey:kModelAttrName];
        [parseLocation setObject:[NSString CK_safeString:placemark.ISOcountryCode] forKey:kLocationCountryCode];
        [parseLocation setObject:[NSString CK_safeString:placemark.country] forKey:kLocationCountry];
        [parseLocation setObject:[NSString CK_safeString:placemark.postalCode] forKey:kLocationPostalCode];
        [parseLocation setObject:[NSString CK_safeString:placemark.administrativeArea] forKey:kLocationAdministrativeArea];
        [parseLocation setObject:[NSString CK_safeString:placemark.subAdministrativeArea] forKey:kLocationSubAdministrativeArea];
        [parseLocation setObject:[NSString CK_safeString:placemark.locality] forKey:kLocationLocality];
        [parseLocation setObject:[NSString CK_safeString:placemark.subLocality] forKey:kLocationSubLocality];
    }
    
    return [[CKLocation alloc] initWithParseObject:parseLocation];
}

#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kModelAttrName]] forKey:kModelAttrName];
    [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationCountryCode]] forKey:kLocationCountryCode];
    [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationCountry]] forKey:kLocationCountry];
    [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationPostalCode]] forKey:kLocationPostalCode];
    [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationAdministrativeArea]] forKey:kLocationAdministrativeArea];
    [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationSubAdministrativeArea]] forKey:kLocationSubAdministrativeArea];
    [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationLocality]] forKey:kLocationLocality];
    [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationSubLocality]] forKey:kLocationSubLocality];
    return descriptionProperties;
}

@end
