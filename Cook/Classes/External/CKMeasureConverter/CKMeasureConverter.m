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
#import "ConversionHelper.h"

#pragma mark - CKReplaceConvert helper
@interface CKReplaceConvert : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSAttributedString *string;
@property (nonatomic, strong) NSString *rangeString;

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
@property (nonatomic, strong) NSNumberFormatter *tempConverterFormatter;
@property (nonatomic, strong) NSNumberFormatter *tenthConverterFormatter;
@property (nonatomic, weak) id<CKMeasureConverterDelegate> delegate;

@end

@implementation CKMeasureConverter

- (id)initWithAttributedString:(NSAttributedString *)inputString toMeasureType:(CKMeasurementType)toType highlightColor:(UIColor *)highlightColor delegate:(id<CKMeasureConverterDelegate>)delegate tokenOnly:(BOOL)isTokenOnly {
    if (self = [super init]) {
        self.scanner = [NSScanner scannerWithString:[inputString.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        self.inputString = inputString;
        self.highlightColor = highlightColor;
        self.replaceArray = [NSMutableArray array];
        self.isTokenOnly = isTokenOnly;
        self.toType = toType;
        self.delegate = delegate;
        self.tempConverterFormatter = [[NSNumberFormatter alloc] init];
        [self.tempConverterFormatter setMaximumFractionDigits:2];
        self.tenthConverterFormatter = [[NSNumberFormatter alloc] init];
        [self.tenthConverterFormatter setMaximumFractionDigits:1];
        [self.tenthConverterFormatter setMinimumIntegerDigits:1];
    }
    return self;
}

//TODO: would be nice to refactor this, findConvertibleElements, and scanning methods into a superclass or something
- (instancetype)initForCheckWithInputString:(NSString *)inputString {
    if (self = [super init]) {
        self.scanner = [NSScanner scannerWithString:[inputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        self.inputString = [[NSAttributedString alloc] initWithString:inputString attributes:nil];
        self.isTokenOnly = NO;
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
        if ([self.scanner isAtEnd]) {
            return [self replaceWithFound]; //reached the end, nothing to scan
        }
        self.scanner.scanLocation++;
        return [self convert];
    } else {
        NSMutableArray *foundNums = [NSMutableArray arrayWithObject:@(currentNum)];
        //Scan for ranges
        NSString *rangeString = [self scanRange];
        if ([rangeString length] > 0) {
            CGFloat endNum = [self scanNumber];
            if (endNum > 0) {
                [foundNums addObject:@(endNum)];
            }
        }
        
        //Scan for strings
        NSString *parsedString = [self scanString];
        endPos = self.scanner.scanLocation;
        NSRange originalRange = NSMakeRange(startPos, endPos - startPos);
        NSString *originalString = [self.inputString.string substringWithRange:originalRange];
        if (parsedString.length > 0) {
            CKReplaceConvert *replaceObj = [[CKReplaceConvert alloc] init];
            replaceObj.string = [self convertFromNumber:foundNums unit:parsedString rangeString:rangeString originalString:originalString];
            replaceObj.range = originalRange;
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

- (BOOL)findConvertibleElements {
    if (self.scanner && [self.scanner isAtEnd]) {
        return NO; //reached the end, didn't find anything
    }
    NSInteger startPos = 0;
    NSInteger endPos = 0;
    //Scan for numbers
    startPos = self.scanner.scanLocation;
    CGFloat currentNum = [self scanNumber];
    //If no numbers found after all, (eg. //SAUCE for section headers), invalid and can't convert, keep searching
    if (currentNum <= 0) {
        if ([self.scanner isAtEnd]) {
            return NO; //reached the end, didn't find anything
        }
        self.scanner.scanLocation++;
        return [self findConvertibleElements];
    } else {
        NSString *rangeString = [self scanRange];
        if ([rangeString length] > 0) {
            // Found a range, just try and advance the scanner past the number to the string
            [self scanNumber];
        }
        //Scan for strings
        NSString *parsedString = [self scanString];
        endPos = self.scanner.scanLocation;
        // Need to see if parsed string is a temperature, ignore if so
        NSDictionary *checkDict = [ConversionHelper sharedInstance].unitRecognitionDict;
        if (parsedString.length > 0
            && ![[checkDict objectForKey:[parsedString uppercaseString]] isEqualToString:@"°F"]
            && ![[checkDict objectForKey:[parsedString uppercaseString]] isEqualToString:@"°C"]) {
            self.scanner = nil;
            return YES; //Found a number-string combo! This text block is convertible
        } else {
            return [self findConvertibleElements];
        }
    }
    return NO; // Dunno if this ever gets reached
}

+ (NSString *)displayStringForMeasureType:(CKMeasurementType)measureType {
    switch (measureType) {
        case CKMeasureTypeImperial:
            return NSLocalizedString(@"US IMPERIAL", nil);
        case CKMeasureTypeMetric:
            return NSLocalizedString(@"METRIC", nil);
        default:
            return @"";
            break;
    }
}

#pragma mark - Utility methods

//Grabs values from conversion plist based on inputs and calculates conversion
- (NSAttributedString *)convertFromNumber:(NSArray *)fromNumbers
                                     unit:(NSString *)unitString
                              rangeString:(NSString *)rangeString
                           originalString: (NSString *)originalString
{
    NSArray *convertToArray = [[self unitTypes] objectForKey:[unitString uppercaseString]];
    NSDictionary *convertDict;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 4.0;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    //If more than 1 conversion type is available, need to assume it's the user's type and go from there
    if ([convertToArray count] > 1) {
        // If guessing that convertTo type matches current type, cancel out
        if (![self.delegate isConvertible]) {
            return nil;
        }
        for (NSDictionary *obj in convertToArray) {
            if ([[obj objectForKey:@"newType"] isEqualToString:[self typeToString:self.toType]]) {
                convertDict = obj;
            }
        }
    } else {
        convertDict = [convertToArray firstObject];
    }
    //Check if conversion is even needed
    if ([self typeFromString:[convertDict objectForKey:@"newType"]] != self.toType
        && ![unitString isEqualToString:@"°F"]
        && ![unitString isEqualToString:@"°C"]
        && !self.isTokenOnly) {
        //Don't need to convert but do need to replace with highlighted version
        NSAttributedString *returnString = [[NSAttributedString alloc] initWithString:originalString
                                                                           attributes:@{NSForegroundColorAttributeName: self.highlightColor,
                                                                                        NSFontAttributeName: [Theme ingredientsListFont],
                                                                                        NSParagraphStyleAttributeName: paragraphStyle}];
        return returnString;
    }
    NSString *convertString;
    
    CGFloat convertNum = [[convertDict objectForKey:@"conversion"] floatValue];
    __block BOOL isParenthesesConvert = NO;
    __block BOOL isTemperatureConvert = NO;
    __block NSString *convertedString = [NSString new];
    __block NSMutableString *convertedNumString = [NSMutableString new];
    NSMutableString *secondaryNumString = [NSMutableString new];
    __block NSString *secondaryUnitString = [NSMutableString new];
    
    CKMeasurementType toLocale = [self typeFromString:[convertDict objectForKey:@"newType"]];
    __block NSString *limitString;
    
    [fromNumbers enumerateObjectsUsingBlock:^(NSNumber *number, NSUInteger idx, BOOL *stop) {
        CGFloat fromNumber = [number floatValue];
        CGFloat convertedNum = (fromNumber * convertNum);
        convertedString = [convertDict objectForKey:@"name"];
        
        //Special case temperature since it isn't a simple multiplication
        if ([unitString isEqualToString:@"°C"] && [convertedString isEqualToString:@"°F"]) {
            convertedNum = (fromNumber * 1.8) + 32;
            isTemperatureConvert = YES;
        } else if ([unitString isEqualToString:@"°F"] && [convertedString isEqualToString:@"°C"]) {
            convertedNum = (fromNumber - 32)/1.8;
            isTemperatureConvert = YES;
        }
        
        NSString *tempNumString = @"";
        NSNumber *fraction = [convertDict objectForKey:@"fraction"];
        CGFloat upscaledNum = [self upscaleNumber:convertedNum unitString:&convertedString fractionType:&fraction unitLimit:limitString];
        limitString = convertedString;
        tempNumString = [self roundFrom:upscaledNum withFractionType:[fraction integerValue]];
        
        //Need conversion check Dict to determine if this is a millimeter conversion
        NSDictionary *checkDict = [ConversionHelper sharedInstance].unitRecognitionDict;
        NSArray *checkML = [checkDict allKeysForObject:@"ML"];
        
        //Special case ml -> Imperial conversion
        if ([self isValidUnitString:unitString] && toLocale == CKMeasureTypeImperial &&
            [checkML containsObject:[[unitString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString]]) {
            
            if ((NSInteger)(roundf(upscaledNum * 100)/100 * 10) % 10 != 0) {
                isParenthesesConvert = YES;
                if ([convertedString isEqualToString:@"cup"]) {
                    tempNumString = [NSString stringWithFormat:@"~%@", tempNumString];
                }
                
                //Convert to fl oz to put in the parentheses
                if ([secondaryNumString length] > 0) {
                    [secondaryNumString appendString:@" - "];
                }
                
                [secondaryNumString appendString:[self roundFrom:fromNumber * 0.033814 withFractionType:10]];
                secondaryUnitString = @"fl oz";
                
                // If this is a range, we need to cut out the first primary value to keep it from getting ridiculously long
                if ([fromNumbers count] > 1 && idx == 0) {
                    tempNumString = @"";
                }
            }
        } else {
            if ([secondaryNumString length] > 0) {
                [secondaryNumString appendString:@" - "];
            }
            [secondaryNumString appendString:[self.tempConverterFormatter stringFromNumber:@(fromNumber)]];
            secondaryUnitString = unitString;
        }
        //Add built-up string to converted string if range
        if ([convertedNumString length] > 0) {
            // Need to check if the new incoming converted string isn't just the same number after upconversion
            [convertedNumString appendString:[NSString stringWithFormat:@" %@ ", rangeString]];
        }
        [convertedNumString appendString:tempNumString];
    }];
    
    if (!convertedNumString || !convertedString) {
        isParenthesesConvert = NO;
        return nil;
        convertedNumString = [NSMutableString stringWithFormat:@"%f", [((NSNumber *)[fromNumbers firstObject]) floatValue]];
        convertedString = [NSMutableString stringWithString:unitString];
    }
    
    if (isTemperatureConvert) {
        convertString = [NSString stringWithFormat:@"%@ %@ (%@ %@)", secondaryNumString, secondaryUnitString, convertedNumString, convertedString];
    } else if (isParenthesesConvert) {
        convertString = [NSString stringWithFormat:@"%@ %@ (%@ %@)", convertedNumString, convertedString, secondaryNumString, secondaryUnitString];
    } else {
        convertString = [NSString stringWithFormat:@"%@ %@", convertedNumString, convertedString];
    }
//        convertString = isParenthesesConvert ? [NSString stringWithFormat:@"%@ %@ (%.2f %@)", convertedNumString, convertedString, fromNumber, unitString] :
//        [NSString stringWithFormat:@"%@ %@", convertedNumString, convertedString];
    
    NSAttributedString *returnString = [[NSAttributedString alloc] initWithString:convertString
                                                                       attributes:@{NSForegroundColorAttributeName: self.highlightColor,
                                                                                    NSFontAttributeName: [Theme ingredientsListFont],
                                                                                    NSParagraphStyleAttributeName: paragraphStyle}];
    return returnString;
}

- (CGFloat)upscaleNumber:(CGFloat)amount unitString:(NSString **)unitString fractionType:(NSNumber **)fraction unitLimit:(NSString *)limitString {
    NSDictionary *upscaleDict = [ConversionHelper sharedInstance].upscaleDict;
    for (NSString *key in [upscaleDict allKeys]) {
        NSDictionary *obj = [upscaleDict objectForKey:key];
        CGFloat limit = [[obj objectForKey:@"limit"] floatValue];
        if ([key isEqualToString:*unitString] && amount > limit) {
            // If a limit was provided, stop upscaling here, otherwise keep recursively looping
            if (limitString && [limitString isEqualToString:key]) {
                return amount;
            } else {
                CGFloat upconvertNum = amount * [[obj objectForKey:@"conversion"] floatValue];
                *fraction = [obj objectForKey:@"fraction"];
                *unitString = [obj objectForKey:@"name"];
                return [self upscaleNumber:upconvertNum unitString:unitString fractionType:fraction unitLimit:limitString];
            }
        }
    }
    
    return amount;
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
    if (self.isTokenOnly && [unitString rangeOfString:@"\u200a"].location == NSNotFound && [unitString rangeOfString:@"°"].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Parsing methods

//Finds a string that matches a unit from the plist
- (NSString *)scanString {
    NSDictionary *checkDict = [ConversionHelper sharedInstance].unitRecognitionDict;
    //Trying to ignore all whitespaces and weird characters I can think of
    NSMutableCharacterSet *unitCharacterIgnoreSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [unitCharacterIgnoreSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [unitCharacterIgnoreSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    [unitCharacterIgnoreSet removeCharactersInString:@"\u200a"];
    [self.scanner setCharactersToBeSkipped:unitCharacterIgnoreSet];
    
    NSMutableString *secondMeasureCheckString = [NSMutableString new];
    NSString *firstMeasureCheckString;
    NSMutableCharacterSet *unitCharacterSet = [NSMutableCharacterSet letterCharacterSet];
    [unitCharacterSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"°\u200a"]];
    if ([self.scanner scanCharactersFromSet:unitCharacterSet intoString:&firstMeasureCheckString]) {
        [secondMeasureCheckString appendString:firstMeasureCheckString];
    }
    
    //Account for unit with spaces in them (eg fl oz)
    NSInteger originalScanLocation = self.scanner.scanLocation;
    {
        NSString *secondPartString;
        [self.scanner scanCharactersFromSet:unitCharacterSet intoString:&secondPartString];
        if (secondPartString) {
            [secondMeasureCheckString appendString:@" "];
            [secondMeasureCheckString appendString:secondPartString];
        }
    }
    
    NSString *check1stMeasureString = [[firstMeasureCheckString copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *check2ndMeasureString = [[secondMeasureCheckString copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //Checking for token and invalidating if class option has been set
    if (firstMeasureCheckString && [[checkDict allKeys] containsObject:[check1stMeasureString uppercaseString]]) {
        self.scanner.scanLocation = originalScanLocation;
        if (![self isValidUnitString:[checkDict objectForKey:firstMeasureCheckString]]) {
            return nil;
        }
        return [checkDict objectForKey:[check1stMeasureString uppercaseString]];
    } else if (secondMeasureCheckString && [[checkDict allKeys] containsObject:[check2ndMeasureString uppercaseString]]) {
        if (![self isValidUnitString:[checkDict objectForKey:[check2ndMeasureString uppercaseString]]]) {
            self.scanner.scanLocation = originalScanLocation;
            return nil;
        }
        return [checkDict objectForKey:[check2ndMeasureString uppercaseString]];
    } else {
        self.scanner.scanLocation = originalScanLocation;
        return nil;
    }
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
    NSInteger firstNumberLocation = self.scanner.scanLocation;
    BOOL foundSpace = [self.scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
    
    if (foundSpace) { //Found a space, this is definitely a whole number, need to look for a possible numerator
        wholeNumber = firstNumber;
        BOOL foundNumerator = [self.scanner scanFloat:&numerator];
        if (!foundNumerator) { //Didn't find a numerator
            self.scanner.scanLocation = firstNumberLocation;
            return wholeNumber;
        }
    } else { //Didn't find a space, this must be the numerator
        numerator = firstNumber;
    }
    //Looking for divide symbol
    NSCharacterSet *divideSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    BOOL foundDivide = [self.scanner scanCharactersFromSet:divideSet intoString:nil];
    //Looking for range of numbers
    
    //This might be a fraction since we found a divide symbol, is there a denominator?
    BOOL foundDenominator = NO;
    if (foundDivide) {
        
        foundDenominator = [self.scanner scanFloat:&denominator];
        if (foundDenominator && denominator > 0) { //Yup, got a denominator, treat as a fraction
            return wholeNumber + (numerator / denominator);
        }
    }
    
    //Found 2 numbers but they weren't a fraction
    if (wholeNumber && foundSpace && !foundDivide) {
        self.scanner.scanLocation = firstNumberLocation;
        return firstNumber;
    }
    
    // Need to check for range indicators
    NSCharacterSet *rangeSet = [NSCharacterSet characterSetWithCharactersInString:@"-"];
    NSInteger originalPosition = self.scanner.scanLocation;
    BOOL foundRange = [self.scanner scanCharactersFromSet:rangeSet intoString:nil];
    if (foundRange) {
        self.scanner.scanLocation = originalPosition; //Set scan location back so that scanRange can pick it up
        return foundDenominator && denominator > 0 ? wholeNumber + (numerator / denominator) : firstNumber;
    }
    // Only found 1 number, reset scanner location and return first number
    self.scanner.scanLocation = firstNumberLocation;
    return firstNumber;
}

- (NSString *)scanRange {
    NSInteger currentLocation = self.scanner.scanLocation;
    NSString *foundString;
    //Scanning ahead to next number
//    [self.scanner setCharactersToBeSkipped:nil];
    [self.scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&foundString];

    //Checking scanned string to see if it's a valid range indicator
    // - Can't be too big, max should be "%i to %i"
    // - Should have valid range strings in it like '-' or 'to'
    if (foundString && [foundString length] < 6 &&
        ([foundString rangeOfString:@"to"].location != NSNotFound ||
         [foundString rangeOfString:@"-"].location != NSNotFound ||
         [foundString rangeOfString:@"by"].location != NSNotFound ||
         [foundString rangeOfString:@"x"].location != NSNotFound))
    {
        return foundString;
    } else {
        [self.scanner setScanLocation:currentLocation];
        return @"";
    }
}

#pragma mark - Ingredient detection

//Returns all unit types from plist
- (NSDictionary *)unitTypes {
    if (self.isTokenOnly) {
        return [ConversionHelper sharedInstance].methodConversionsDict;
    }
    else {
        return [ConversionHelper sharedInstance].conversionsDict;
    }
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
    if (input < 0.1) {
        return @"< 0.1";
    }
    CGFloat rounded = roundf(input * 100)/ 100;
    return [self.tenthConverterFormatter stringFromNumber:@(rounded)];
}

- (NSString *)convertEights:(CGFloat)input {
    if (input < 0.125) {
        return @"< 1/8";
    }
    NSArray *array = @[@"",@"1/8",@"1/4",@"3/8",@"1/2",@"5/8",@"3/4",@"7/8",@""];
    return [self convertToFraction:input keyArray:array];
}

//For extra nice fuzzy eigths?
- (NSString *)convertSixteenths:(CGFloat)input {
    if (input < 0.125) {
        return @"< 1/8";
    }
    NSArray *array = @[@"",@"1/8",@"1/8",@"1/4",@"1/4",@"1/3",@"3/8",@"1/2",@"1/2",@"1/2",@"5/8",@"2/3",@"3/4",@"3/4",@"7/8",@"7/8",@""];
    return [self convertToFraction:input keyArray:array];
}

- (NSString *)convertFourths:(CGFloat)input {
    if (input < 0.25) {
        return @"< 1/4";
    }
    NSArray *array = @[@"", @"1/4", @"1/2", @"3/4", @""];
    return [self convertToFraction:input keyArray:array];
}

- (NSString *)convertHalf:(CGFloat)input {
    if (input < 0.5) {
        return @"< 1/2";
    }
    NSArray *array = @[@"", @"1/2", @""];
    return [self convertToFraction:input keyArray:array];
}

- (NSString *)convertWhole:(CGFloat)input {
    if (input < 1) {
        return @"< 1";
    }
    NSInteger outputInt = input + 0.5f;
    return [@(outputInt) stringValue];
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
