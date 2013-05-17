//
//  IngredientsView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 17/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "IngredientsView.h"
#import "Theme.h"
#import "Ingredient.h"

@interface IngredientsView ()

@property (nonatomic, strong) UILabel *ingredientsLabel;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong, readonly) NSDictionary *paragraphAttributes;

@end

@implementation IngredientsView

@synthesize paragraphAttributes = _paragraphAttributes;

#define kNewLineCharacter @"\u2028"

- (id)initWithIngredients:(NSArray *)ingredients size:(CGSize)size {
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)]) {
        self.userInteractionEnabled = NO;
        self.ingredients = ingredients;
        [self displayData];
    }
    return self;
}

#pragma mark - Properties

- (void)setIngredients:(NSArray *)ingredients {
    _ingredients = ingredients;
    [self displayData];
}

- (NSDictionary *)paragraphAttributes {
    if (!_paragraphAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//        paragraphStyle.lineSpacing = -10.0;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        _paragraphAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               [Theme ingredientsListFont], NSFontAttributeName,
                               [Theme ingredientsListColor], NSForegroundColorAttributeName,
                               paragraphStyle, NSParagraphStyleAttributeName,
                               nil];
    }
    return _paragraphAttributes;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = [Theme ingredientsListFont];
        _placeholderLabel.textColor = [Theme ingredientsListColor];
        _placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        _placeholderLabel.text = @"INGREDIENTS";
        [_placeholderLabel sizeToFit];
        _placeholderLabel.frame = CGRectMake(floorf((self.bounds.size.width - _placeholderLabel.frame.size.width) / 2.0),
                                             floorf((self.bounds.size.height - _placeholderLabel.frame.size.height) / 2.0),
                                             _placeholderLabel.frame.size.width,
                                             _placeholderLabel.frame.size.height);
    }
    return _placeholderLabel;
}

#pragma mark - Private methods

- (void)displayData {
    if ([self.ingredients count] > 0) {
        [self.ingredientsLabel removeFromSuperview];
        
        NSMutableAttributedString *attributedText = nil;
        
        for (Ingredient *ingredient in self.ingredients) {
            NSAttributedString *ingredientAttributedText = [self attributedTextForIngredient:ingredient];
            if (attributedText == nil) {
                attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:ingredientAttributedText];
            } else {
                [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:kNewLineCharacter]];
                [attributedText appendAttributedString:ingredientAttributedText];
            }
        }
        
        UILabel *ingredientsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        ingredientsLabel.userInteractionEnabled = NO;
        ingredientsLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        ingredientsLabel.backgroundColor = [UIColor clearColor];
        ingredientsLabel.numberOfLines = 0;
        ingredientsLabel.attributedText = attributedText;
        CGSize size = [ingredientsLabel sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)];
        ingredientsLabel.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        [self addSubview:ingredientsLabel];
        self.ingredientsLabel = ingredientsLabel;
        
        // Update self frame.
        CGRect frame = self.frame;
        frame.size.height = ingredientsLabel.frame.size.height;
        if (ingredientsLabel.frame.size.height < self.frame.size.height) {
            frame.size.height = self.frame.size.height;
        }
        self.frame = frame;
        
    } else {
        [self addSubview:self.placeholderLabel];
    }
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
