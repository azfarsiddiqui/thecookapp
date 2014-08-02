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
#import "AppHelper.h"

@interface BookContentTitleView ()

@property (nonatomic, strong) CKMaskedLabel *maskedLabel;
@property (nonatomic, strong) UIView *underlayView;
@property (nonatomic, strong) UIImageView *boxImageView;

@property (nonatomic, strong) NSString *title;

@end

@implementation BookContentTitleView

#define kCategoryFont       [Theme defaultFontWithSize:110.0]
#define kCategoryMinFont    [Theme defaultFontWithSize:90.0]
#define kCategoryInsets     (UIEdgeInsets){ 15.0, 50.0, 15.0, 50.0 }
#define kCategoryMinInsets  (UIEdgeInsets){ 15.0, 30.0, 15.0, 30.0 }
#define kBoxInsets          (UIEdgeInsets){ 12.0, 12.0, 12.0, 12.0 }
#define kContentInsets      (UIEdgeInsets){ 0.0, 42.0, 0.0, 42.0 }
#define kUnderlayColour     [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]
#define kEditUnderlayColour [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

- (id)initWithTitle:(NSString *)title {
    if (self = [super initWithFrame:CGRectZero]) {
        [self updateWithTitle:title];
        [self addSubview:self.boxImageView];
        [self addSubview:self.underlayView];
        [self addSubview:self.maskedLabel];
    }
    return self;
}

- (void)updateWithTitle:(NSString *)title {
    self.title = [title uppercaseString];
    
    UIFont *font = kCategoryFont;
    UIEdgeInsets insets = kCategoryInsets;
    UIEdgeInsets boxInsets = kBoxInsets;
    if ([self needsScaling]) {
        font = kCategoryMinFont;
        insets = kCategoryMinInsets;
    }
    
    NSDictionary *paragraphAttributes = [self paragraphAttributesForFont:font];
    NSAttributedString *titleDisplay = [[NSAttributedString alloc] initWithString:self.title attributes:paragraphAttributes];
    self.maskedLabel.attributedText = titleDisplay;
    
    CGSize fullscreenSize = [[AppHelper sharedInstance] fullScreenFrame].size;
    CGSize availableSize = (CGSize){
        fullscreenSize.width - kContentInsets.left - kContentInsets.right,
        fullscreenSize.height
    };
    CGSize size = [self.maskedLabel sizeThatFits:availableSize];
    size.width += insets.left + insets.right;
    size.height += insets.top + insets.bottom;
    
    // Update myself and my dependent views.
    self.maskedLabel.frame = CGRectIntegral((CGRect){ 0.0, 0.0, MIN(availableSize.width, size.width), size.height });
    self.underlayView.frame = self.maskedLabel.frame;
    self.frame = self.maskedLabel.frame;
    self.boxImageView.frame = (CGRect){
        -boxInsets.left,
        -boxInsets.top,
        boxInsets.left + self.bounds.size.width + boxInsets.right,
        boxInsets.top + self.bounds.size.height + boxInsets.bottom,
    };
}

- (void)enableEditMode:(BOOL)editMode {
    [self enableEditMode:editMode animated:YES];
}

- (void)enableEditMode:(BOOL)editMode animated:(BOOL)animated {
    self.underlayView.backgroundColor = editMode ? kEditUnderlayColour : kUnderlayColour;
    [self.maskedLabel enableEditMode:editMode];
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.boxImageView.alpha = editMode ? 0.0 : 1.0;
                         } completion:^(BOOL success) {
                         }];
    } else {
        self.boxImageView.alpha = editMode ? 0.0 : 1.0;
    }
}

#pragma mark - Properties

- (CKMaskedLabel *)maskedLabel {
    if (!_maskedLabel) {
        _maskedLabel = [[CKMaskedLabel alloc] initWithFrame:CGRectZero];
        _maskedLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _maskedLabel.numberOfLines = 1;
        _maskedLabel.textAlignment = NSTextAlignmentCenter;
        _maskedLabel.adjustsFontSizeToFitWidth = YES;
        _maskedLabel.insets = [self maskedLabelInsets];
    }
    return _maskedLabel;
}

- (UIView *)underlayView {
    if (!_underlayView) {
        _underlayView = [[UIView alloc] initWithFrame:CGRectZero];
        _underlayView.backgroundColor = kUnderlayColour;
        _underlayView.frame = self.maskedLabel.frame;
    }
    return _underlayView;
}

- (UIImageView *)boxImageView {
    if (!_boxImageView) {
        UIImage *boxImage = [[UIImage imageNamed:@"cook_book_inner_category_box.png"]
                             resizableImageWithCapInsets:(UIEdgeInsets){ 21.0, 21.0, 21.0, 21.0}];
        _boxImageView = [[UIImageView alloc] initWithImage:boxImage];
    }
    return _boxImageView;
}

#pragma mark - Private methods

- (NSDictionary *)paragraphAttributesForFont:(UIFont *)font {
    NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.lineSpacing = -10.0;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            [UIColor whiteColor], NSForegroundColorAttributeName,
            paragraphStyle, NSParagraphStyleAttributeName,
            nil];
}

- (UIEdgeInsets)maskedLabelInsets {
    return UIEdgeInsetsZero;
}

- (BOOL)needsScaling {
    return ([self.title length] > 14);
}

@end
