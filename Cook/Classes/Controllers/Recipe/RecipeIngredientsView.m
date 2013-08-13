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

@interface RecipeIngredientsView ()

@property (nonatomic, assign) CGSize maxSize;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) CGFloat layoutOffset;
@property (nonatomic, strong) NSDictionary *paragraphAttributes;
@property (nonatomic, strong) NSMutableArray *ingredientLabels;

@end

@implementation RecipeIngredientsView

#define kRowGap 3.0

- (id)initWithIngredients:(NSArray *)ingredients maxWidth:(CGFloat)maxWidth {
    return [self initWithIngredients:ingredients maxSize:(CGSize){ maxWidth, MAXFLOAT }];
}

- (id)initWithIngredients:(NSArray *)ingredients maxSize:(CGSize)maxSize {
    return [self initWithIngredients:ingredients maxSize:maxSize textAlignment:NSTextAlignmentLeft];
}

- (id)initWithIngredients:(NSArray *)ingredients maxSize:(CGSize)maxSize textAlignment:(NSTextAlignment)textAlignment {
    if (self = [super initWithFrame:CGRectZero]) {
        self.maxSize = maxSize;
        self.textAlignment = textAlignment;
        self.ingredientLabels = [NSMutableArray arrayWithCapacity:[ingredients count]];
        [self updateIngredients:ingredients];
    }
    return self;
}

- (void)updateIngredients:(NSArray *)ingredients {
    self.layoutOffset = 0.0;
    
    if ([ingredients count] > 0) {
        
        // for (Ingredient *ingredient in self.recipe.ingredients) {
        for (NSUInteger ingredientIndex = 0; ingredientIndex < [ingredients count]; ingredientIndex++) {
            
            Ingredient *ingredient = [ingredients objectAtIndex:ingredientIndex];
            NSAttributedString *ingredientAttributedText = [self attributedTextForIngredient:ingredient];
            
            // Can we re-use an existing one?
            UILabel *ingredientsLabel = nil;
            if (ingredientIndex < [self.ingredientLabels count]) {
                ingredientsLabel = [self.ingredientLabels objectAtIndex:ingredientIndex];
            } else {
                ingredientsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                ingredientsLabel.userInteractionEnabled = NO;
                ingredientsLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                ingredientsLabel.backgroundColor = [UIColor clearColor];
                ingredientsLabel.numberOfLines = 0;
                [self.ingredientLabels addObject:ingredientsLabel];
                [self addSubview:ingredientsLabel];
            }
            
            // Update the display text.
            ingredientsLabel.attributedText = ingredientAttributedText;
            CGSize size = [ingredientsLabel sizeThatFits:self.maxSize];
            
            // Have we exceeded the max height,then remove this label.
            if (self.layoutOffset + size.height > self.maxSize.height) {
                [ingredientsLabel removeFromSuperview];
                break;
            }
            
            ingredientsLabel.frame = (CGRect){ 0.0, self.layoutOffset, size.width, size.height };
            self.layoutOffset += size.height;
            if (ingredientIndex < [ingredients count] - 1) {
                self.layoutOffset += kRowGap;
            }
        }
        
        // Remove any unused ingredientsLabel.
        if ([ingredients count] < [self.ingredientLabels count]) {
            for (NSUInteger unwantedIndex = [ingredients count]; unwantedIndex < [self.ingredientLabels count]; unwantedIndex++) {
                UILabel *unwantedLabel = [self.ingredientLabels objectAtIndex:unwantedIndex];
                [unwantedLabel removeFromSuperview];
                [self.ingredientLabels removeObjectAtIndex:unwantedIndex];
            }
        }
        
    }
    
    [self updateFrame];
}

#pragma mark - Properties

- (NSDictionary *)paragraphAttributes {
    if (!_paragraphAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
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
//    NSString *measurement = ingredient.measurement;
//    if ([measurement length] > 0) {
//        [ingredientDisplay addAttribute:NSFontAttributeName
//                                  value:[Theme ingredientsListMeasurementFont]
//                                  range:NSMakeRange(0, [measurement length])];
//        [ingredientDisplay addAttribute:NSForegroundColorAttributeName
//                                  value:[Theme ingredientsListMeasurementColor]
//                                  range:NSMakeRange(0, [measurement length])];
//    }
    
    return ingredientDisplay;
}

- (NSString *)ingredientAsString:(Ingredient *)ingredient {
    NSMutableString *ingredientString = [NSMutableString stringWithString:ingredient.name];
    if ([ingredient.measurement length] > 0) {
        [ingredientString insertString:[NSString stringWithFormat:@"%@ ", ingredient.measurement] atIndex:0];
    }
    return ingredientString;
}

@end
