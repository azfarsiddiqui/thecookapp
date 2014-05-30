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

- (NSString *)displayName {
    NSString *countryName = [self.parseObject objectForKey:kLocationCountry];
    
    // Fallback to country code if country displayName not found.
    if (![countryName CK_containsText]) {
        countryName = [[self.parseObject objectForKey:kLocationCountryCode] uppercaseString];
    }
    
    return countryName;
}

- (NSString *)localeDisplayName {
    NSString *countryName = nil;
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *countryCode = [self.parseObject objectForKey:kLocationCountryCode];
    if (countryCode && [countryCode length] > 0) {
        NSString *identifier = [NSLocale localeIdentifierFromComponents:[NSDictionary dictionaryWithObject:countryCode forKey:NSLocaleCountryCode]];
        countryName = [currentLocale displayNameForKey:NSLocaleIdentifier value:identifier];
    }
    
    return countryName;
}

#pragma mark - Properties


#pragma mark - CKModel

- (NSDictionary *)descriptionProperties {
    NSMutableDictionary *descriptionProperties = [NSMutableDictionary dictionaryWithDictionary:[super descriptionProperties]];
    if ([self.parseObject isDataAvailable]) {
        [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kModelAttrName]] forKey:kModelAttrName];
        [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationCountryCode]] forKey:kLocationCountryCode];
        [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationCountry]] forKey:kLocationCountry];
        [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationPostalCode]] forKey:kLocationPostalCode];
        [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationAdministrativeArea]] forKey:kLocationAdministrativeArea];
        [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationSubAdministrativeArea]] forKey:kLocationSubAdministrativeArea];
        [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationLocality]] forKey:kLocationLocality];
        [descriptionProperties setValue:[NSString CK_safeString:[self.parseObject objectForKey:kLocationSubLocality]] forKey:kLocationSubLocality];
    }
    return descriptionProperties;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    } else if (object == nil || ![object isKindOfClass:[CKLocation class]]
               || ![((CKLocation *)object).parseObject isDataAvailable]
               || ![self.parseObject isDataAvailable]) {
        return NO;
    } else {
        PFGeoPoint *geoPoint = [self.parseObject objectForKey:kLocationGeoPoint];
        PFGeoPoint *otherGeoPoint = [((CKLocation *)object).parseObject objectForKey:kLocationGeoPoint];
        if (geoPoint && otherGeoPoint) {
            CLLocation *location = [self locationFromGeoPoint:geoPoint];
            CLLocation *otherLocation = [self locationFromGeoPoint:otherGeoPoint];
            return ([location distanceFromLocation:otherLocation] < 10.0);
        } else {
            return NO;
        }
    }
}

- (CLLocation *)locationFromGeoPoint:(PFGeoPoint *)geoPoint {
    if (geoPoint) {
        return [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    } else {
        return nil;
    }
}

@end
