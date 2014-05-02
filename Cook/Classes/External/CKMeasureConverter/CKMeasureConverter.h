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
    CKMeasureTypeImperial = 4,
    CKMeasureTypeNone = 5
};

typedef NS_ENUM(NSUInteger, CKFractionConvertType) {
    CKFractionConvertTypeWhole = 1,
    CKFractionConvertTypeHalf = 2,
    CKFractionConvertTypeFourth = 4,
    CKFractionConvertTypeEighth = 8,
    CKFractionConvertTypeTenth = 10,
    CKFractionConvertTypeSixteenth = 16
};

@protocol CKMeasureConverterDelegate <NSObject>

- (BOOL)isConvertible;

@end

@interface CKMeasureConverter : NSObject

@property (nonatomic, strong) NSScanner *scanner;

- (id)initWithAttributedString:(NSAttributedString *)inputString
                 toMeasureType:(CKMeasurementType)toType
                highlightColor:(UIColor *)highlightColor
                      delegate:(id<CKMeasureConverterDelegate>)delegate
                     tokenOnly:(BOOL)isTokenOnly;

- (NSAttributedString *)convert;
- (CGFloat)numOfConvertibleElements;

+ (NSString *)displayStringForMeasureType:(CKMeasurementType)measureType;

@end