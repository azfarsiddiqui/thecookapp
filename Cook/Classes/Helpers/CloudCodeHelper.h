//
//  CloudCodeHelper.h
//  Cook
//
//  Created by Jeff Tan-Ang on 25/07/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudCodeHelper : NSObject

+ (NSDictionary *)commonCloudCodeParams;
+ (NSDictionary *)commonCloudCodeParamsWithExtraParams:(NSDictionary *)extraParams;

@end
