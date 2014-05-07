//
//  ConversionHelper.m
//  Cook
//
//  Created by Gerald on 7/05/2014.
//  Copyright (c) 2014 Cook Apps Pty Ltd. All rights reserved.
//

#import "ConversionHelper.h"
#import "AppHelper.h"

@implementation ConversionHelper

#define PLIST_CONVERSIONS @"conversions"
#define PLIST_METHOD_CONVERSIONS @"methodConversions"
#define PLIST_UPSCALE @"upscale"
#define PLIST_UNIT_RECOGNITION @"unitRecognition"

+ (ConversionHelper *)sharedInstance {
    static dispatch_once_t pred;
    static ConversionHelper *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance =  [[ConversionHelper alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        //Seeding initial conversion values with bundled plists
        self.conversionsDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PLIST_CONVERSIONS ofType:@"plist"]];
        self.methodConversionsDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PLIST_METHOD_CONVERSIONS ofType:@"plist"]];
        self.upscaleDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PLIST_UPSCALE ofType:@"plist"]];
        self.unitRecognitionDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:PLIST_UNIT_RECOGNITION ofType:@"plist"]];
    }
    return self;
}

- (void)updatePlists {
    [self getLatestVersionOfPlistEventuallyForName:PLIST_CONVERSIONS];
    [self getLatestVersionOfPlistEventuallyForName:PLIST_METHOD_CONVERSIONS];
    [self getLatestVersionOfPlistEventuallyForName:PLIST_UPSCALE];
    [self getLatestVersionOfPlistEventuallyForName:PLIST_UNIT_RECOGNITION];
}

- (void)getLatestVersionOfPlistEventuallyForName:(NSString *)fileName {
    if ([AppHelper configValueForKey:@"CONVERSION_PLIST_BASE_URL"] && fileName) {
        NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.plist",
                                                  [AppHelper configValueForKey:@"CONVERSION_PLIST_BASE_URL"],
                                                  fileName]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSDictionary *testDictionary = [NSDictionary dictionaryWithContentsOfURL:requestURL];
            if (testDictionary && [testDictionary isKindOfClass:[NSDictionary class]] && [[testDictionary allKeys] count] > 3) {
                if ([fileName isEqualToString:PLIST_CONVERSIONS]) {
                    self.conversionsDict = testDictionary;
                } else if ([fileName isEqualToString:PLIST_METHOD_CONVERSIONS]) {
                    self.methodConversionsDict = testDictionary;
                } else if ([fileName isEqualToString:PLIST_UPSCALE]) {
                    self.upscaleDict = testDictionary;
                } else if ([fileName isEqualToString:PLIST_UNIT_RECOGNITION]) {
                    self.unitRecognitionDict = testDictionary;
                }
            }
        });
    }
}

@end
