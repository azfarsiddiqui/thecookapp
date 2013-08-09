//
//  RecipeIngredientsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 9/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "RecipeIngredientsView.h"
#import "CKRecipe.h"
#import "Theme.h"
#import "Ingredient.h"

@interface RecipeIngredientsView ()

@property (nonatomic, strong) CKRecipe *recipe;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat layoutOffset;
@property (nonatomic, strong) NSDictionary *paragraphAttributes;

@end

@implementation RecipeIngredientsView

#define kRowGap 3.0

- (id)initWithRecipe:(CKRecipe *)recipe maxWidth:(CGFloat)maxWidth {
    if (self = [super initWithFrame:CGRectZero]) {
        self.recipe = recipe;
        self.maxWidth = maxWidth;
        self.layoutOffset = 0.0;
        [self updateIngredients];
        [self updateFrame];
    }
    return self;
}

#pragma mark - Properties

- (NSDictionary *)paragraphAttributes {
    if (!_paragraphAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        _paragraphAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [Theme ingredientsListFont], NSFontAttributeName,
                                [Theme ingredientsListColor], NSForegroundColorAttributeName,
                                paragraphStyle, NSParagraphStyleAttributeName,
                                nil];
    }
    return _paragraphAttributes;
}

#pragma mark - Private methods

- (void)updateIngredients {
    if ([self.recipe.ingredients count] > 0) {
        
        // for (Ingredient *ingredient in self.recipe.ingredients) {
        for (NSUInteger ingredientIndex = 0; ingredientIndex < [self.recipe.ingredients count]; ingredientIndex++) {
            
            Ingredient *ingredient = [self.recipe.ingredients objectAtIndex:ingredientIndex];
            NSAttributedString *ingredientAttributedText = [self attributedTextForIngredient:ingredient];
            
            UILabel *ingredientsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            ingredientsLabel.userInteractionEnabled = NO;
            ingredientsLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
            ingredientsLabel.backgroundColor = [UIColor clearColor];
            ingredientsLabel.numberOfLines = 0;
            ingredientsLabel.attributedText = ingredientAttributedText;
            CGSize size = [ingredientsLabel sizeThatFits:CGSizeMake(self.maxWidth, MAXFLOAT)];
            ingredientsLabel.frame = (CGRect){ 0.0, self.layoutOffset, size.width, size.height };
            [self addSubview:ingredientsLabel];
            
            self.layoutOffset += size.height;
            if (ingredientIndex < [self.recipe.ingredients count] - 1) {
                self.layoutOffset += kRowGap;
            }
        }
        
    }
}

- (void)updateFrame {
    CGRect frame = (CGRect){ 0.0, 0.0, 0.0, 0.0 };;
    for (UIView *subview in self.subviews) {
        frame = (CGRectUnion(frame, subview.frame));
    }
    self.frame = frame;
}

- (NSAttributedString *)attributedTextForIngredient:(Ingredient *)ingredient {
    NSString *ingredientString = [self ingredientAsString:ingredient];
    NSMutableAttributedString *ingredientDisplay = [[NSMutableAttributedString alloc] initWithString:ingredientString
                                                                                          attributes:self.paragraphAttributes];
    NSString *measurement = ingredient.measurement;
    if ([measurement length] > 0) {
        [ingredientDisplay addAttribute:NSFontAttributeName
                                  value:[Theme ingredientsListMeasurementFont]
                                  range:NSMakeRange(0, [measurement length])];
        [ingredientDisplay addAttribute:NSForegroundColorAttributeName
                                  value:[Theme ingredientsListMeasurementColor]
                                  range:NSMakeRange(0, [measurement length])];
    }
    
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
