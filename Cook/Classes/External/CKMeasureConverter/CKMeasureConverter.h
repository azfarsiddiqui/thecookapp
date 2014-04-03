//
//  CKMeasureConverter.h
//  TestConversion
//
//  Created by Gerald Kim on 18/12/2013.
//  Copyright (c) 2013 Cook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CKMeasurementType) {
    CKMeasureTypeMetric = 1,
    CKMeasureTypeUKMetric = 2,
    CKMeasureTypeAUMetric = 3,
    CKMeasureTypeImperial = 4,
    CKMeasureTypeNone = 5
};

typedef NS_ENUM(NSUInteger, CKFractionConvertType) {
    CKFractionConvertTypeWhole = 1,
    CKFractionConvertTypeHalf = 2,
    CKFractionConvertTypeFourth = 4,
    CKFractionConvertTypeEighth = 8,
    CKFractionConvertTypeTenth = 10
};
    
@interface CKMeasureConverter : NSObject

@property (nonatomic, strong) NSScanner *scanner;

- (id)initWithAttributedString:(NSAttributedString *)inputString
                    fromLocale:(CKMeasurementType)fromLocale
                      toLocale:(CKMeasurementType)toLocale
                highlightColor:(UIColor *)highlightColor
                     tokenOnly:(BOOL)isTokenOnly;
- (NSAttributedString *)convert;

@end