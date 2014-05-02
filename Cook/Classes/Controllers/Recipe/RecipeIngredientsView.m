//
//  RecipeIngredientsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeIngredientsView.h"
#import "Theme.h"
#import "Ingredient.h"
#import "NSString+Utilities.h"
#import "CKBook.h"
#import "CKBookCover.h"

@interface RecipeIngredientsView () <CKMeasureConverterDelegate>

@property (nonatomic, strong) CKBook *book;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) CGFloat layoutOffset;
@property (nonatomic, strong) NSDictionary *paragraphAttributes;
@property (nonatomic, assign) CKMeasurementType convertToType;
@property (nonatomic, assign) BOOL compact;

@end

@implementation RecipeIngredientsView

#define kRowGap         12.0
#define kCompactRowGap  0.0

- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxWidth:(CGFloat)maxWidth measureLocale:(CKMeasurementType)measureType isConvertible:(BOOL)isConvertible {
    return [self initWithIngredients:ingredients book:book maxSize:(CGSize){ maxWidth, MAXFLOAT } textAlignment:NSTextAlignmentLeft compact:NO measureLocale:measureType isConvertible:isConvertible];
}

- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize
            textAlignment:(NSTextAlignment)textAlignment measureLocale:(CKMeasurementType)measureType {
    return [self initWithIngredients:ingredients book:book maxSize:maxSize textAlignment:textAlignment compact:NO measureLocale:measureType isConvertible:YES];
}

- (id)initWithIngredients:(NSArray *)ingredients book:(CKBook *)book maxSize:(CGSize)maxSize
            textAlignment:(NSTextAlignment)textAlignment compact:(BOOL)compact measureLocale:(CKMeasurementType)measureType isConvertible:(BOOL)isConvertible {
    if (self = [super initWithFrame:CGRectZero]) {
        self.book = book;
        self.maxSize = maxSize;
        self.textAlignment = textAlignment;
        self.compact = compact;
        self.convertible = isConvertible;
        
        [self updateIngredients:ingredients book:book measureType:measureType convertible:isConvertible];
    }
    return self;
}

- (void)updateIngredients:(NSArray *)ingredients measureType:(CKMeasurementType)measureType convertible:(BOOL)isConvertible {
    [self updateIngredients:ingredients book:self.book measureType:measureType convertible:isConvertible];
}

- (void)updateIngredients:(NSArray *)ingredients book:(CKBook *)book measureType:(CKMeasurementType)measureType convertible:(BOOL)isConvertible {
    self.book = book;
    self.layoutOffset = 0.0;
    self.convertToType = measureType;
    self.convertible = isConvertible;
    
    if ([ingredients count] > 0) {
        for (UIView *ingredientLabel in self.subviews) {
            [ingredientLabel removeFromSuperview];
        }
        for (NSUInteger ingredientIndex = 0; ingredientIndex < [ingredients count]; ingredientIndex++) {
            
            Ingredient *ingredient = [ingredients objectAtIndex:ingredientIndex];
            NSAttributedString *ingredientAttributedText = [self attributedTextForIngredient:ingredient];
            
            UILabel *ingredientsLabel = nil;
            ingredientsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            ingredientsLabel.userInteractionEnabled = NO;
            ingredientsLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            ingredientsLabel.backgroundColor = [UIColor clearColor];
            ingredientsLabel.numberOfLines = 0;
            [self addSubview:ingredientsLabel];
            
            // Update the display text.
            ingredientsLabel.attributedText = ingredientAttributedText;
            CGSize size = [ingredientsLabel sizeThatFits:self.maxSize];
            
            // Have we exceeded the max height,then remove this label.
            if (self.layoutOffset + size.height > self.maxSize.height) {
                [ingredientsLabel removeFromSuperview];
                break;
            }
            
            ingredientsLabel.frame = CGRectIntegral((CGRect){ 0.0, self.layoutOffset, self.maxSize.width, size.height });
            self.layoutOffset += ingredientsLabel.frame.size.height;
            if (ingredientIndex < [ingredients count] - 1) {
                self.layoutOffset += self.compact ? kCompactRowGap : kRowGap;
            }
        }
        
    }
    
    [self updateFrame];
}

#pragma mark - CKMeasureConverter delegate

- (BOOL)isConvertible {
    return self.convertible;
}

#pragma mark - Properties

- (NSDictionary *)paragraphAttributes {
    if (!_paragraphAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.lineSpacing = self.compact ? 0.0 : 4.0;
        paragraphStyle.alignment = self.textAlignment;
        _paragraphAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [Theme ingredientsListFont], NSFontAttributeName,
                                [Theme ingredientsListColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    }
    return _paragraphAttributes;
}

#pragma mark - Private methods

- (void)updateFrame {
    CGRect frame = (CGRect){ 0.0, 0.0, 0.0, 0.0 };;
    for (UIView *subview in self.subviews) {
        frame = (CGRectUnion(frame, subview.frame));
    }
    
    // Retain the original frame.
    frame.origin.x = self.frame.origin.x;
    frame.origin.y = self.frame.origin.y;
    
    self.frame = frame;
}

- (NSAttributedString *)attributedTextForIngredient:(Ingredient *)ingredient {
    NSString *ingredientString = [self ingredientAsString:ingredient];
    NSMutableAttributedString *ingredientDisplay = [[NSMutableAttributedString alloc] initWithString:ingredientString
                                                                                          attributes:self.paragraphAttributes];
    NSString *measurement = ingredient.measurement;
    if ([measurement length] > 0) {
        [ingredientDisplay addAttribute:NSForegroundColorAttributeName
                                  value:[CKBookCover textColourForCover:self.book.cover]
                                  range:NSMakeRange(0, [measurement length])];
    }
    //Convert
    if (self.convertToType && self.convertToType != CKMeasureTypeNone) {
        CKMeasureConverter *ingredientConvert = [[CKMeasureConverter alloc] initWithAttributedString:ingredientDisplay
                                                                                          toMeasureType:self.convertToType
                                                                                      highlightColor:[CKBookCover textColourForCover:self.book.cover]
                                                                                            delegate:self
                                                                                           tokenOnly:NO];
        NSAttributedString *convertedIngredient = [ingredientConvert convert];
        _numIngredientsConvertible = [ingredientConvert numOfConvertibleElements];
//        DLog(@"converted ingredient: %@ from %i to %i", convertedIngredient.string, self.convertFromType, [CKUser currentUser].measurementType);
        return convertedIngredient;
    } else {
        return ingredientDisplay;
    }
}

- (NSString *)ingredientAsString:(Ingredient *)ingredient {
    NSMutableString *ingredientString = [NSMutableString stringWithString:[NSString CK_safeString:ingredient.name]];
    if ([ingredient.measurement length] > 0) {
        [ingredientString insertString:[NSString stringWithFormat:@"%@  ", ingredient.measurement] atIndex:0];
    }
    return ingredientString;
}

@end
