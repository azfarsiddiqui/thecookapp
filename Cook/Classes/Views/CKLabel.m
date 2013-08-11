//
//  CKLabel.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/05/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "CKLabel.h"
#import "Theme.h"
#import "NSString+Utilities.h"

@interface CKLabel ()

@property (nonatomic, strong) NSString *placeholderText;
@property (nonatomic, assign) CGSize minSize;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation CKLabel

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame placeholder:nil minSize:CGSizeZero];
}

- (id)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholderText minSize:(CGSize)minSize {
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, minSize.width, minSize.height)]) {
        self.placeholderText = placeholderText;
        self.minSize = minSize;
        self.placeholderFont = [Theme methodFont];
        self.placeholderColour = [Theme methodColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.width = sizeThatFits.width < self.minSize.width ? self.minSize.width : sizeThatFits.width;
    sizeThatFits.height = sizeThatFits.height < self.minSize.height ? self.minSize.height : sizeThatFits.height;
    return sizeThatFits;
}

#pragma mark - Properties

- (void)setDefaultText:(NSString *)defaultText {
    self.text = defaultText;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self applyPlaceholder];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self applyPlaceholder];
}

- (void)setFrame:(CGRect)frame {
    if ([self textIsEmpty]) {
        frame.size.width = frame.size.width < self.minSize.width ? self.minSize.width : frame.size.width;
        frame.size.height = frame.size.height < self.minSize.height ? self.minSize.height : frame.size.height;
    }
    [super setFrame:frame];
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = self.placeholderFont;
        _placeholderLabel.textColor = self.placeholderColour;
        _placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        _placeholderLabel.text = self.placeholderText;
        [_placeholderLabel sizeToFit];
        _placeholderLabel.frame = CGRectMake(floorf((self.bounds.size.width - _placeholderLabel.frame.size.width) / 2.0),
                                             floorf((self.bounds.size.height - _placeholderLabel.frame.size.height) / 2.0),
                                             _placeholderLabel.frame.size.width,
                                             _placeholderLabel.frame.size.height);
    }
    return _placeholderLabel;
}

#pragma mark - Private methods

- (void)applyPlaceholder {
    if ([self textIsEmpty]) {
        
        if ([self.defaultText length] > 0) {
            self.text = self.defaultText;
        } else {
            [self addSubview:self.placeholderLabel];
            
            // Adjusts minSize to be at least the placeholderLabel.
            CGSize minSize = self.minSize;
            minSize.width = minSize.width < self.placeholderLabel.frame.size.width ? self.placeholderLabel.frame.size.width : minSize.width;
            minSize.height = minSize.height < self.placeholderLabel.frame.size.height ? self.placeholderLabel.frame.size.height : minSize.height;
            self.minSize = minSize;
         
        }
        
    } else {
        [self.placeholderLabel removeFromSuperview];
    }
}

- (BOOL)textIsEmpty {
    return (!self.text || !self.attributedText || [self.text CK_containsText] || [self.attributedText.string CK_containsText]);
}

@end
