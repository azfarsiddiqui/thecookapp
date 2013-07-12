//
//  BookCategoryHeaderView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 13/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookHeaderView.h"
#import "CKMaskedLabel.h"
#import "Theme.h"

@interface BookHeaderView ()

@property (nonatomic, strong) UIView *underlayView;
@property (nonatomic, strong) CKMaskedLabel *maskedLabel;
@property (nonatomic, strong) NSString *title;

@end

@implementation BookHeaderView

#define kCategoryFont       [Theme defaultFontWithSize:100.0]
#define kCategoryMinFont    [Theme defaultFontWithSize:90.0]
#define kCategoryInsets     UIEdgeInsetsMake(40.0, 40.0, 28.0, 40.0)

- (id)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        // Black overlay under the label.
        UIView *underlayView = [[UIView alloc] initWithFrame:CGRectZero];
        underlayView.backgroundColor = [UIColor blackColor];
        underlayView.alpha = 0.3;
        [self addSubview:underlayView];
        self.underlayView = underlayView;
        
        // Pre-create the label.
        CKMaskedLabel *maskedLabel = [[CKMaskedLabel alloc] initWithFrame:CGRectZero];
        maskedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        maskedLabel.numberOfLines = 2;
        maskedLabel.font = kCategoryFont;
        maskedLabel.insets = kCategoryInsets;
        [self addSubview:maskedLabel];
        self.maskedLabel = maskedLabel;
        
    }
    return self;
}

- (void)configureTitle:(NSString *)title {
    DLog(@"Title: %@", title);
    self.title = [title uppercaseString];
    
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
    
    // Set the frame in motion.
    self.maskedLabel.frame = (CGRect){
        floor((self.bounds.size.width - size.width) / 2.0),
        floor((self.bounds.size.height - size.height) / 2.0),
        size.width,
        size.height
    };
    self.underlayView.frame = self.maskedLabel.frame;
}

#pragma mark - Private methods

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
