//
//  BookCategoryImageView.m
//  Cook
//
//  Created by Jeff Tan-Ang on 15/07/13.
//  Copyright (c) 2013 Cook Apps Pty Ltd. All rights reserved.
//

#import "BookContentImageView.h"
#import "UIColor+Expanded.h"
#import "Theme.h"

@interface BookContentImageView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *vignetteOverlayView;
@property (nonatomic, strong) UIView *whiteOverlayView;
@property (nonatomic, strong) UIToolbar *toolbarView;

@end

@implementation BookContentImageView

#define kForceVisibleOffset         1.0

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        // The containerView is merely to serve as an opaque background for smooth scrolling without much of it clear.
        self.containerView = [[UIView alloc] initWithFrame:[self contentBoundsWithoutForceVisibleOffset]];
        self.containerView.backgroundColor = [Theme recipeGridImageBackgroundColour];
        [self.containerView addSubview:self.imageView];
        [self.containerView addSubview:self.vignetteOverlayView];
        [self.containerView addSubview:self.whiteOverlayView];
        [self addSubview:self.containerView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)applyOffset:(CGFloat)offset {
    [self applyOffset:offset distance:500.0 view:self.whiteOverlayView];
}

- (void)configureImage:(UIImage *)image {
    [self configureImage:image placeholder:NO];
}

- (void)configureImage:(UIImage *)image placeholder:(BOOL)placeholder {
    if (image) {
        self.imageView.image = image;
        self.vignetteOverlayView.hidden = NO;
    } else {
        self.imageView.image = nil;
        self.vignetteOverlayView.hidden = YES;
    }
}

#pragma mark - Properties

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.containerView.bounds];
    }
    return _imageView;
}

- (UIImageView *)vignetteOverlayView {
    if (!_vignetteOverlayView) {
        _vignetteOverlayView = [[UIImageView alloc] initWithFrame:self.containerView.bounds];
        _vignetteOverlayView.image = [UIImage imageNamed:@"cook_book_inner_page_overlay.png"];
    }
    return _vignetteOverlayView;
}

- (UIView *)whiteOverlayView {
    if (!_whiteOverlayView) {
        _whiteOverlayView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        _whiteOverlayView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
        _whiteOverlayView.hidden = YES;
    }
    return _whiteOverlayView;
}

- (UIToolbar *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[UIToolbar alloc] initWithFrame:self.containerView.bounds];
        _toolbarView.translucent = YES;
        _toolbarView.hidden = YES;
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

- (CGRect)contentBoundsWithoutForceVisibleOffset {
    return (CGRect){
        self.bounds.origin.x + kForceVisibleOffset,
        self.bounds.origin.y,
        self.bounds.size.width - (kForceVisibleOffset * 2.0),
        self.bounds.size.height
    };
}

@end
