//
//  BookCategoryImageView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryImageView.h"

@interface BookCategoryImageView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *whiteOverlayView;
@property (nonatomic, strong) UIToolbar *toolbarView;

@end

@implementation BookCategoryImageView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)applyOffset:(CGFloat)offset {
//    [self applyOffset:offset distance:500.0 view:self.whiteOverlayView];
    [self applyOffset:offset distance:300.0 view:self.toolbarView];
}

- (void)configureImage:(UIImage *)image {
    self.imageView.image = image;
}

#pragma mark - Properties

- (UIView *)whiteOverlayView {
    if (!_whiteOverlayView) {
        _whiteOverlayView = [[UIView alloc] initWithFrame:self.bounds];
        _whiteOverlayView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
        _whiteOverlayView.hidden = YES;
        [self addSubview:_whiteOverlayView];
    }
    return _whiteOverlayView;
}

- (UIToolbar *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[UIToolbar alloc] initWithFrame:self.bounds];
        _toolbarView.translucent = YES;
        _toolbarView.hidden = YES;
        [self addSubview:_toolbarView];
    }
    return _toolbarView;
}

#pragma mark - Private methods

- (void)applyOffset:(CGFloat)offset distance:(CGFloat)distance view:(UIView *)view {
    CGFloat alpha = 0.0;
    if (offset <= 0.0) {
        alpha = 0.0;
    } else {
        
        CGFloat ratio = offset / distance;
        alpha = MIN(ratio, 1.0);
    }
    [self applyAlpha:alpha view:view];
}

- (void)applyAlpha:(CGFloat)alpha view:(UIView *)view {
    if (alpha > 0) {
        view.hidden = NO;
        view.alpha = alpha;
    } else {
        view.hidden = YES;
    }
}

@end
