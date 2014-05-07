//
//  ConversionHelper.h
//  Cook
//
//  Created by Gerald on 7/05/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversionHelper : NSObject

@property (nonatomic, strong) NSDictionary *conversionsDict;
@property (nonatomic, strong) NSDictionary *upscaleDict;
@property (nonatomic, strong) NSDictionary *methodConversionsDict;
@property (nonatomic, strong) NSDictionary *unitRecognitionDict;

+ (ConversionHelper *)sharedInstance;
- (void)updatePlists;

@end
