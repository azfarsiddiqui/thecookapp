//
//  CKMeasureConverter.m
//  TestConversion
//
//  Created by Gerald Kim on 18/12/2013.
//  Copyright (c) 2013 Cook. All rights reserved.
//

#import "CKMeasureConverter.h"
#import "Theme.h"
#import "CKUser.h"

#pragma mark - CKReplaceConvert helper
@interface CKReplaceConvert : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSAttributedString *string;

@end

@implementation CKReplaceConvert

@end

#pragma mark -

@interface CKMeasureConverter ()

@property (nonatomic, strong) NSAttributedString *inputString;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, strong) NSMutableArray *replaceArray; //array of replaceConverts
@property (nonatomic, assign) CKMeasurementType toType;
@property (nonatomic, assign) BOOL isTokenOnly;

@end

@implementation CKMeasureConverter

- (id)initWithAttributedString:(NSAttributedString *)inputString toMeasureType:(CKMeasurementType)toType highlightColor:(UIColor *)highlightColor tokenOnly:(BOOL)isTokenOnly {
    if (self = [super init]) {
        self.scanner = [NSScanner scannerWithString:[inputString.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        self.inputString = inputString;
        self.highlightColor = highlightColor;
        self.replaceArray = [NSMutableArray array];
        self.isTokenOnly = isTokenOnly;
        self.toType = toType;
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
//            DLog(@"Scanned result is: %f %@. Start pos: %i end pos: %i", currentNum, parsedString, startPos, endPos);
            CKReplaceConvert *replaceObj = [[CKReplaceConvert alloc] init];
            replaceObj.string = [self convertFromNumber:currentNum unit:parsedString];
            replaceObj.range = NSMakeRange(startPos, endPos - startPos);
            if (replaceObj.string) {
                [self.replaceArray addObject:replaceObj];
            }
            return [self convert];
        } else {
            return [self convert];
        }
    }
    return [self replaceWithFound];
}

+ (NSString *)displayStringForMeasureType:(CKMeasurementType)measureType {
    switch (measureType) {
        case CKMeasureTypeImperial:
            return @"US IMPERIAL";
        case CKMeasureTypeMetric:
            return @"METRIC";
        default:
            return @"";
            break;
    }
}

#pragma mark - Utility methods

//Grabs values from conversion plist based on inputs and calculates conversion
- (NSAttributedString *)convertFromNumber:(CGFloat)fromNumber unit:(NSString *)unitString {
    NSArray *convertToArray = [[self unitTypes] objectForKey:[unitString uppercaseString]];

    NSDictionary *convertDict;
    //If more than 1 conversion type is available, need to assume it's the user's type and go from there
    if ([convertToArray count] > 1) {
        for (NSDictionary *obj in convertToArray) {
            if ([[obj objectForKey:@"originalType"] isEqualToString:[self typeToString:self.toType]]) {
                convertDict = obj;
            }
        }
    } else {
        convertDict = [convertToArray firstObject];
    }
    //Check if conversion is even needed
    if ([self typeFromString:[convertDict objectForKey:@"newType"]] != self.toType) {
        return nil;
    }
    NSString *convertString;
    
    NSString *convertedString = [convertDict objectForKey:@"name"];
    CGFloat convertNum = [[convertDict objectForKey:@"conversion"] floatValue];
    CGFloat convertedNum = (fromNumber * convertNum);
    BOOL isParenthesesConvert = NO;
    CKMeasurementType toLocale = [self typeFromString:[convertDict objectForKey:@"newType"]];
    //Special case temperature since it isn't a simple multiplication
    if ([unitString isEqualToString:@"°C"] && [convertedString isEqualToString:@"°F"]) {
        convertedNum = (fromNumber * 1.8) + 32;
        isParenthesesConvert = YES;
    } else if ([unitString isEqualToString:@"°F"] && [convertedString isEqualToString:@"°C"]) {
        convertedNum = (fromNumber - 32)/1.8;
        isParenthesesConvert = YES;
    }
    
    NSString *convertedNumString = [self roundFrom:convertedNum withFractionType:[[convertDict objectForKey:@"fraction"] intValue]];
    
    //Special case ml -> Imperial conversion
    if ([self isValidUnitString:unitString] && toLocale == CKMeasureTypeImperial && [[unitString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"ml"]) {
        
        if (fromNumber == 15 || (fromNumber >= 30 && fromNumber <= 60)) {
            //Convert to tablespoon
            convertedNum = fromNumber * 0.066666666; //tsp -> tbsp
            convertedString = @"tbsp";
            convertedNumString = [self roundFrom:convertedNum withFractionType:16];
        } else if (fromNumber > 60) {
            //Convert to cups
            convertedNum = fromNumber * .004237288; //tsp -> cup
            convertedString = @"cup";
            convertedNumString = [self roundFrom:convertedNum withFractionType:4];
        }
        
        if ((NSInteger)(roundf(convertedNum * 100)/100 * 10) % 10 != 0) {
            convertString = [NSString stringWithFormat:@"~%@ %@ (%i %@)", convertedNumString, convertedString, (int)fromNumber, unitString];
        } else {
            convertString = [NSString stringWithFormat:@"%@ %@", convertedNumString, convertedString];
        }
    } else {
        convertString = isParenthesesConvert ? [NSString stringWithFormat:@"%@ %@ (%.2f %@)", convertedNumString, convertedString, fromNumber, unitString] :
        [NSString stringWithFormat:@"%@ %@", convertedNumString, convertedString];
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 4.0;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSAttributedString *returnString = [[NSAttributedString alloc] initWithString:convertString
                                                                       attributes:@{NSForegroundColorAttributeName: self.highlightColor,
                                                                                    NSFontAttributeName: [Theme ingredientsListFont],
                                                                                    NSParagraphStyleAttributeName: paragraphStyle}];
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

- (BOOL)isValidUnitString:(NSString *)unitString {
    if (self.isTokenOnly && [unitString rangeOfString:@"\u200a"].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Parsing methods

//Finds a string that matches a unit from the plist
- (NSString *)scanString {
    //NOTES TO SELF: NSScanner is somehow still ignoring the hairline space used to detect token. Figure out why and how to stop it
    
    //Trying to ignore all whitespaces and weird characters I can think of
    NSMutableCharacterSet *unitCharacterIgnoreSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [unitCharacterIgnoreSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [unitCharacterIgnoreSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    [unitCharacterIgnoreSet removeCharactersInString:@"\u200a"];
    [self.scanner setCharactersToBeSkipped:unitCharacterIgnoreSet];
    
    NSString *measureString;
    NSMutableCharacterSet *unitCharacterSet = [NSMutableCharacterSet letterCharacterSet];
    [unitCharacterSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"°\u200a"]];
//    [unitCharacterSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@""]];
    [self.scanner scanCharactersFromSet:unitCharacterSet intoString:&measureString];
    
    NSString *checkMeasureString = [[measureString copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //Need to special case 'fl oz' since it has a space in it
    if ([[measureString uppercaseString] isEqualToString:@"FL"]) {
        NSString *finishMeasureString;
        [self.scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:&finishMeasureString];
        if ([[finishMeasureString uppercaseString] isEqualToString:@"OZ"]) {
            measureString = @"fl oz\u200a";
        }
    }
    
    //Checking for token and invalidating if class option has been set
    
    
    if (measureString && [[[self unitTypes] allKeys] containsObject:[checkMeasureString uppercaseString]]) {
        if (![self isValidUnitString:measureString]) {
            return nil;
        }
        return checkMeasureString;
    } else
        return nil;
}

//Scans for a number that might have fractions and returns converted number
- (CGFloat)scanNumber {
    float firstNumber = 0, wholeNumber = 0, numerator = 0, denominator = 0;
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

//Returns all unit types from plist
- (NSDictionary *)unitTypes {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"conversions" ofType:@"plist"]];
}

- (NSString *)typeToString:(CKMeasurementType)locale {
    NSString *localeString = @"";
    if (locale == CKMeasureTypeImperial) {
        localeString = @"Imperial";
    } else if (locale == CKMeasureTypeMetric) {
        localeString = @"Metric";
    }
    return localeString;
}

- (CKMeasurementType)typeFromString:(NSString *)typeString {
    if ([typeString isEqualToString:@"Metric"]) {
        return CKMeasureTypeMetric;
    } else if ([typeString isEqualToString:@"Imperial"]) {
        return CKMeasureTypeImperial;
    } else {
        return CKMeasureTypeNone;
    }
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
        case CKFractionConvertTypeSixteenth: return [self convertSixteenths:fromNum];
        default: return [self convertTenths:fromNum];
    }
}

//For large metric measures, keep decimal but round to tenth
- (NSString *)convertTenths:(CGFloat)input {
    CGFloat rounded = roundf(input * 100)/ 100;
    return [NSString stringWithFormat:@"%.1f", rounded];
}

- (NSString *)convertEights:(CGFloat)input {
    NSArray *array = @[@"",@"1/8",@"1/4",@"3/8",@"1/2",@"5/8",@"3/4",@"7/8",@""];
    return [self convertToFraction:input keyArray:array];
}

//For extra nice fuzzy eigths?
- (NSString *)convertSixteenths:(CGFloat)input {
    NSArray *array = @[@"",@"1/8",@"1/8",@"1/4",@"1/4",@"1/3",@"3/8",@"1/2",@"1/2",@"1/2",@"5/8",@"2/3",@"3/4",@"3/4",@"7/8",@"7/8",@""];
    return [self convertToFraction:input keyArray:array];
}

- (NSString *)convertFourths:(CGFloat)input {
    NSArray *array = @[@"", @"1/4", @"1/2", @"3/4", @""];
    return [self convertToFraction:input keyArray:array];
}

- (NSString *)convertHalf:(CGFloat)input {
    NSArray *array = @[@"", @"1/2", @""];
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
