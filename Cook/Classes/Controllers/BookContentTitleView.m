//
//  BookContentTitleView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/08/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentTitleView.h"
#import "CKMaskedLabel.h"
#import "Theme.h"

@interface BookContentTitleView ()

@property (nonatomic, strong) CKMaskedLabel *maskedLabel;
@property (nonatomic, strong) NSString *title;

@end

@implementation BookContentTitleView

#define kCategoryFont       [Theme defaultFontWithSize:118.0]
#define kCategoryMinFont    [Theme defaultFontWithSize:110.0]
#define kCategoryInsets     UIEdgeInsetsMake(40.0, 40.0, 28.0, 40.0)

- (id)initWithTitle:(NSString *)title {
    if (self = [super initWithFrame:CGRectZero]) {
        self.title = [title uppercaseString];
        [self initMaskedLabel];
    }
    return self;
}

#pragma mark - Private methods

- (void)initMaskedLabel {
    
    // Pre-create the label.
    CKMaskedLabel *maskedLabel = [[CKMaskedLabel alloc] initWithFrame:CGRectZero];
    maskedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    maskedLabel.numberOfLines = 2;
    maskedLabel.font = kCategoryFont;
    maskedLabel.insets = kCategoryInsets;
    [self addSubview:maskedLabel];
    self.maskedLabel = maskedLabel;
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:kCategoryFont];
    NSAttributedString *titleDisplay = [[NSAttributedString alloc] initWithString:self.title attributes:paragraphAttributes];
    self.maskedLabel.attributedText = titleDisplay;
    
    // Figure out the required size with padding.
    CGSize availableSize = CGSizeMake(self.bounds.size.width - kCategoryInsets.left - kCategoryInsets.right, self.bounds.size.height);
    CGSize size = [self.maskedLabel sizeThatFits:availableSize];
    size.width += kCategoryInsets.left + kCategoryInsets.right;
    size.height += kCategoryInsets.top + kCategoryInsets.bottom;
    
    // Bump down font if exceeds maximum width.
    if (size.width >= availableSize.width) {
        paragraphAttributes = [self paragraphAttributesForFont:kCategoryMinFont];
        titleDisplay = [[NSAttributedString alloc] initWithString:self.title attributes:paragraphAttributes];
        self.maskedLabel.attributedText = titleDisplay;
        size = [self.maskedLabel sizeThatFits:availableSize];
        size.width += kCategoryInsets.left + kCategoryInsets.right;
        size.height += kCategoryInsets.top + kCategoryInsets.bottom;
    }
    
    // Anchor the frame at the bottom
    self.maskedLabel.frame = (CGRect){ 0.0, 0.0, size.width, size.height };
    self.frame = self.maskedLabel.frame;
    
    // Dark underlay.
    UIView *underlayView = [[UIView alloc] initWithFrame:CGRectZero];
    underlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.45];
    underlayView.frame = self.maskedLabel.frame;
    [self insertSubview:underlayView belowSubview:self.maskedLabel];

    // Outer box image.
    UIEdgeInsets boxInsets = (UIEdgeInsets) { 12.0, 12.0, 12.0, 12.0 };
    UIImage *boxImage = [[UIImage imageNamed:@"cook_book_inner_category_box.png"]
                         resizableImageWithCapInsets:(UIEdgeInsets){ 21.0, 21.0, 21.0, 21.0}];
    UIImageView *boxImageView = [[UIImageView alloc] initWithImage:boxImage];
    boxImageView.frame = (CGRect){
        -boxInsets.left,
        -boxInsets.top,
        boxInsets.left + self.bounds.size.width + boxInsets.right,
        boxInsets.top + self.bounds.size.height + boxInsets.bottom,
    };
    [self addSubview:boxImageView];
    [self sendSubviewToBack:boxImageView];
}

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font {
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = -10.0;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

@end
