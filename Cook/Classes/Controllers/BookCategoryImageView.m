//
//  BookCategoryImageView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookCategoryImageView.h"
#import "UIColor+Expanded.h"
#import "Theme.h"

@interface BookCategoryImageView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *vignetteOverlayView;
@property (nonatomic, strong) UIView *whiteOverlayView;
@property (nonatomic, strong) UIToolbar *toolbarView;

@end

@implementation BookCategoryImageView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [Theme recipeGridImageBackgroundColour];
        [self addSubview:self.imageView];
        [self addSubview:self.vignetteOverlayView];
        [self addSubview:self.whiteOverlayView];
    }
    return self;
}

- (void)applyOffset:(CGFloat)offset {
    [self applyOffset:offset distance:500.0 view:self.whiteOverlayView];
}

- (void)configureImage:(UIImage *)image {
    [self configureImage:image placeholder:NO];
}

- (void)configureImage:(UIImage *)image placeholder:(BOOL)placeholder {
    self.imageView.image = image;
    self.vignetteOverlayView.hidden = placeholder;
}

#pragma mark - Properties

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:nil];
        _imageView.frame = self.bounds;
    }
    return _imageView;
}

- (UIImageView *)vignetteOverlayView {
    if (!_vignetteOverlayView) {
        _vignetteOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cook_book_inner_page_overlay.png"]];
    }
    return _vignetteOverlayView;
}

- (UIView *)whiteOverlayView {
    if (!_whiteOverlayView) {
        _whiteOverlayView = [[UIView alloc] initWithFrame:self.bounds];
        _whiteOverlayView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
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
