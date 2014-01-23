//
//  CKMeasureConverter.m
//  TestConversion
//
//  Created by Gerald Kim on 18/12/2013.
//  Copyright (c) 2013 Cook. All rights reserved.
//

#import "CKMeasureConverter.h"

#pragma mark - CKReplaceConvert helper
@interface CKReplaceConvert : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) NSAttributedString *string;

@end

@implementation CKReplaceConvert

@end

#pragma mark -

@interface CKMeasureConverter ()

@property (nonatomic, strong) NSAttributedString *inputString;
@property (nonatomic, assign) CKMeasurementType fromLocale;
@property (nonatomic, assign) CKMeasurementType toLocale;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) NSMutableArray *replaceArray; //array of replaceConverts

@end

@implementation CKMeasureConverter

- (id)initWithAttributedString:(NSAttributedString *)inputString fromLocale:(CKMeasurementType)fromLocale toLocale:(CKMeasurementType)toLocale highlightColor:(UIColor *)highlightColor {
    if (self = [super init]) {
        self.scanner = [NSScanner scannerWithString:[inputString.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        self.inputString = inputString;
        self.fromLocale = fromLocale;
        self.toLocale = toLocale;
        self.highlightColor = highlightColor;
        self.replaceArray = [NSMutableArray array];
    }
    return self;
}

- (NSAttributedString *)convert {
    if ([self.scanner isAtEnd]) {
        return [self replaceWithFound]; //reached the end, nothing to scan
    }
    NSInteger startPos = 0;
    NSInteger endPos = 0;
    //Scan for numbers
    startPos = self.scanner.scanLocation;
    CGFloat currentNum = [self scanNumber];
    //If no numbers found after all, (eg. //SAUCE for section headers), invalid and can't convert, keep searching
    if (currentNum <= 0) {
        self.scanner.scanLocation++;
        if ([self.scanner isAtEnd]) {
            return [self replaceWithFound]; //reached the end, nothing to scan
        }
        return [self convert];
    } else {
        //Scan for strings
        NSString *parsedString = [self scanString];
        endPos = self.scanner.scanLocation;
        if (parsedString.length > 0) {
            DLog(@"Scanned result is: %f %@. Start pos: %i end pos: %i", currentNum, parsedString, startPos, endPos);
            CKReplaceConvert *replaceObj = [[CKReplaceConvert alloc] init];
            replaceObj.string = [self convertFromNumber:currentNum unit:parsedString];
            replaceObj.range = NSMakeRange(startPos, endPos - startPos);
            [self.replaceArray addObject:replaceObj];
            return [self convert];
        }
    }
    return [self replaceWithFound];
}

//Grabs values from conversion plist based on inputs and calculates conversion
- (NSAttributedString *)convertFromNumber:(CGFloat)fromNumber unit:(NSString *)unitString {
    NSDictionary *convertToDict = [[self unitTypes] objectForKey:[unitString uppercaseString]];
    NSDictionary *convertDict = [convertToDict objectForKey:[self typeToString:self.toLocale]];
    NSString *convertedString = [convertDict objectForKey:@"name"];
    CGFloat convertNum = [[convertDict objectForKey:@"conversion"] floatValue];
    NSString *convertedNumString = [self roundFrom:(fromNumber * convertNum) withFractionType:[[convertDict objectForKey:@"fraction"] intValue]];
    NSAttributedString *returnString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", convertedNumString, convertedString]
                                                                       attributes:@{NSForegroundColorAttributeName: self.highlightColor}];
    return returnString;
}

//Goes backward through array and replaces strings with converted values
- (NSAttributedString *)replaceWithFound {
    NSMutableAttributedString *outputString = [[NSMutableAttributedString alloc] initWithAttributedString:self.inputString];
    //Needs to be backwards to not mess up locations
    for (CKReplaceConvert *replaceObj in [[self.replaceArray reverseObjectEnumerator] allObjects]) {
        [outputString deleteCharactersInRange:replaceObj.range];
        [outputString insertAttributedString:replaceObj.string atIndex:replaceObj.range.location];
    }
    return outputString;
}

#pragma mark - Parsing methods

//Finds a string that matches a unit from the plist
- (NSString *)scanString {
    //Trying to ignore all whitespaces and weird characters I can think of
    NSMutableCharacterSet *unitCharacterIgnoreSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [unitCharacterIgnoreSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [unitCharacterIgnoreSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    [self.scanner setCharactersToBeSkipped:unitCharacterIgnoreSet];
    
    NSString *measureString;
    [self.scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&measureString];
    
    //Need to special case 'fl oz' since it has a space in it
    if ([[measureString uppercaseString] isEqualToString:@"FL"]) {
        NSString *finishMeasureString;
        [self.scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&finishMeasureString];
        if ([[finishMeasureString uppercaseString] isEqualToString:@"OZ"]) {
            measureString = @"fl oz";
        }
    }
    
    if (measureString && [[[self unitTypes] allKeys] containsObject:[measureString uppercaseString]]) {
        return measureString;
    } else
        return nil;
}

//Scans for a number that might have fractions and returns converted number
- (CGFloat)scanNumber {
    CGFloat firstNumber = 0, wholeNumber = 0, numerator = 0, denominator = 0;
    [self.scanner setCharactersToBeSkipped:nil];
    BOOL found = [self.scanner scanFloat:&firstNumber];
    //Didn't find a number, can't convert, return invalid
    if (!found) {
        return 0;
    }
    NSCharacterSet *divideSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    BOOL foundSpace = [self.scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
    if (foundSpace) { //Found a space, this is definitely a whole number, need to look for a possible numerator
        wholeNumber = firstNumber;
        BOOL foundNumerator = [self.scanner scanFloat:&numerator];
        if (!foundNumerator) { //Didn't find a numerator
            return wholeNumber;
        }
    } else { //Didn't find a space, this must be the numerator
        numerator = firstNumber;
    }
    BOOL foundDivide = [self.scanner scanCharactersFromSet:divideSet intoString:nil];
    //This might be a fraction since we found a divide symbol, is there a denominator?
    if (foundDivide) {
        
        BOOL foundDenominator = [self.scanner scanFloat:&denominator];
        if (foundDenominator && denominator > 0) { //Yup, got a denominator, treat as a fraction
            return wholeNumber + (numerator / denominator);
        }
    }
    return 0;
}

#pragma mark - Ingredient detection

- (NSDictionary *)unitTypes {
    NSDictionary *localeTypes = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"conversions" ofType:@"plist"]];
    return [localeTypes objectForKey:[self typeToString:self.fromLocale]];
}

- (NSString *)typeToString:(CKMeasurementType)locale {
    NSString *localeString = @"";
    if (locale == CKMeasureTypeImperial) {
        localeString = @"Imperial";
    } else if (locale == CKMeasureTypeMetric) {
        localeString = @"Metric";
    } else if (locale == CKMeasureTypeAUMetric) {
        localeString = @"AUMetric";
    } else if (locale == CKMeasureTypeUKMetric) {
        localeString = @"UKMetric";
    }
    return localeString;
}

#pragma mark - Convert from decimal to fraction

//The only method that should actually be used...
- (NSString *)roundFrom:(CGFloat)fromNum withFractionType:(NSInteger)fractionValue {
    switch (fractionValue) {
        case CKFractionConvertTypeWhole: return [self convertWhole:fromNum];
        case CKFractionConvertTypeHalf: return [self convertHalf:fromNum];
        case CKFractionConvertTypeFourth: return [self convertFourths:fromNum];
        case CKFractionConvertTypeEighth: return [self convertEights:fromNum];
        case CKFractionConvertTypeTenth: return [self convertTenths:fromNum];
        default: return [self convertTenths:fromNum];
    }
}

//For large metric measures, keep decimal but round to tenth
- (NSString *)convertTenths:(CGFloat)input {
    CGFloat rounded = roundf(input * 100)/ 100;
    return [NSString stringWithFormat:@"%.1f", rounded];
}

- (NSString *)convertEights:(CGFloat)input {
    NSArray *array = @[@"",@"\u215B",@"\u00BC",@"\u2153",@"\u00BD",@"\u2154",@"\u00BE",@"\u215E",@""];
    return [self convertToFraction:input keyArray:array];
}

- (NSString *)convertFourths:(CGFloat)input {
    NSArray *array = @[@"", @"\u00BC", @"\u00BD", @"\u00BE", @""];
    return [self convertToFraction:input keyArray:array];
}

- (NSString *)convertHalf:(CGFloat)input {
    NSArray *array = @[@"", @"\u00BD", @""];
    return [self convertToFraction:input keyArray:array];
}

- (NSString *)convertWhole:(CGFloat)input {
    return [NSString stringWithFormat:@"%i", (NSInteger)roundf(input)];
}

- (NSString *)convertToFraction:(CGFloat)input keyArray:(NSArray *)array {
    
    if ([array count] > 2) {
        CGFloat denomination = [array count] - 1;
        
        NSInteger fractions = lroundf((input - (NSInteger)input)/((CGFloat)1/denomination));
        if(fractions == 0 || fractions == denomination) {
            return [NSString stringWithFormat:@"%ld",lroundf(input)];
        } else {
            if([[array objectAtIndex:fractions] isEqualToString:@""]) {
                if (input < 1) {
                    return [NSString stringWithFormat:@"%i/%f",(NSInteger)fractions,denomination];
                } else {
                    return [NSString stringWithFormat:@"%i %i/%f",(NSInteger)input,(NSInteger)fractions,denomination];
                }
            } else {
                if (input < 1) {
                    return [NSString stringWithFormat:@"%@",[array objectAtIndex:fractions]];
                } else {
                    return [NSString stringWithFormat:@"%i %@",(NSInteger)input,[array objectAtIndex:fractions]];
                }
            }
        }
    }
    return @"";
}

@end
