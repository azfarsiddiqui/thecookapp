//
//  AddRecipePageCell.m
//  Cook
//
//  Created by Jeff Tan-Ang on 18/10/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "AddRecipePageCell.h"

@interface AddRecipePageCell ()

@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIImageView *backgroundOverlayView;
@property (nonatomic, strong) UIImageView *backgroundOverlayHighlightedView;

@end

@implementation AddRecipePageCell

#define kPageFont       [UIFont fontWithName:@"BrandonGrotesque-Regular" size:22.0]
#define kPageColour     [UIColor blackColor]
#define kLabelInsets    (UIEdgeInsets){ 97.0, 33.0, 81.0, 33.0 }

+ (CGSize)cellSize {
    return [UIImage imageNamed:@"cook_book_addtobook_category_overlay.png"].size;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.backgroundView = self.backgroundOverlayView;
        [self.contentView addSubview:self.pageLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    self.backgroundView = selected ? self.backgroundOverlayHighlightedView : self.backgroundOverlayView;
}

- (void)setHighlighted:(BOOL)highlighted {
    self.backgroundView = highlighted ? self.backgroundOverlayHighlightedView : self.backgroundOverlayView;
}

- (void)configurePage:(NSString *)page {
    self.pageLabel.text = [page uppercaseString];
    CGSize labelSize = (CGSize){ self.contentView.bounds.size.width - kLabelInsets.left - kLabelInsets.right,
        self.contentView.bounds.size.height - kLabelInsets.top - kLabelInsets.bottom };
    CGSize size = [self.pageLabel sizeThatFits:labelSize];
    self.pageLabel.frame = (CGRect) {
        kLabelInsets.left + floorf((labelSize.width - size.width) / 2.0),
        kLabelInsets.top + floorf((labelSize.height - size.height) / 2.0),
        size.width,
        size.height
    };
}

#pragma mark - Properties

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _pageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        _pageLabel.numberOfLines = 0;
        _pageLabel.font = kPageFont;
        _pageLabel.textColor = kPageColour;
    }
    return _pageLabel;
}

- (UIImageView *)backgroundOverlayView {
    if (!_backgroundOverlayView) {
        _backgroundOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_addtobook_category_overlay.png"]];
    }
    return _backgroundOverlayView;
}

- (UIImageView *)backgroundOverlayHighlightedView {
    if (!_backgroundOverlayHighlightedView) {
        _backgroundOverlayHighlightedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_addtobook_category_overlay_onpress.png"]];
    }
    return _backgroundOverlayHighlightedView;
}


@end
