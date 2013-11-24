//
//  CKLocation.h
//  Cook
//
//  Created by Jeff Tan-Ang on 14/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKModel.h"

@interface CKLocation : CKModel

+ (CKLocation *)locationWithCoreLocation:(CLLocation *)location placemark:(CLPlacemark *)placemark;
- (NSString *)displayName;

@end
